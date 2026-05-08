//
//  OnboardingControlProvider.swift
//  WaterEject
//
//  Created by OpenAI on 07.05.2026.
//

import CryptoKit
import FirebaseAnalytics
import Foundation
import RevenueCat
import UIKit

struct OnboardingControlConfig: Codable {
    let version: Int
    let experimentId: String
    let defaultTier: OnboardingTierConfig?
    let tiers: [String: OnboardingTierConfig]?
}

struct OnboardingTierConfig: Codable {
    let flows: [String: OnboardingFlowConfig]
}

struct OnboardingFlowConfig: Codable {
    let isOn: Bool
    let trafficPercent: Int
    let enabledScreens: [String]?
    let disabledScreens: [String]?
}

struct OnboardingAssignment: Codable, Equatable {
    let experimentId: String
    let flowId: String
    let bucket: Int
    let assignedAtISO: String
    let tier: String
    let configFingerprint: String
}

final class OnboardingControlProvider {
    static let shared = OnboardingControlProvider()

    static let remoteConfigKey = "onboarding_control_json"

    private let defaults = UserDefaults.standard
    private let storedJSONKey = "onboarding_control_json_cached_v1"
    private let assignmentKey = "onboarding_control_assignment_v1"
    private let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private var runtimeConfig: OnboardingControlConfig?
    private var memoryAssignment: OnboardingAssignment?
    private var lastLoggedDistributionKey: String?

    private let defaultScreensByFlow: [String: [String]] = [
        "new_onb_1": ["step1", "step2", "paywall"],
        "new_onb_2": ["step1", "step2", "step3", "paywall"],
        "new_onb_3": ["step1", "step2", "paywall"],
        "new_onb_4": ["step1", "step2", "step3", "paywall"],
        "new_onb_5": ["step1", "step2", "step3", "paywall"],
        "new_onb_6": ["step1", "step2", "paywall"],
        "onb_8_1": ["step1", "step2", "step3", "paywall"],
        "onb_10_1": ["step1", "step2", "step3", "paywall"]
    ]

    private let fallbackConfig = OnboardingControlConfig(
        version: 1,
        experimentId: "onboarding_control_fallback_v1",
        defaultTier: OnboardingTierConfig(flows: [
            "onb_8_1": OnboardingFlowConfig(
                isOn: true,
                trafficPercent: 50,
                enabledScreens: nil,
                disabledScreens: nil
            ),
            "onb_10_1": OnboardingFlowConfig(
                isOn: true,
                trafficPercent: 50,
                enabledScreens: nil,
                disabledScreens: nil
            ),
            "new_onb_1": OnboardingFlowConfig(isOn: false, trafficPercent: 0, enabledScreens: nil, disabledScreens: nil),
            "new_onb_2": OnboardingFlowConfig(isOn: false, trafficPercent: 0, enabledScreens: nil, disabledScreens: nil),
            "new_onb_3": OnboardingFlowConfig(isOn: false, trafficPercent: 0, enabledScreens: nil, disabledScreens: nil),
            "new_onb_4": OnboardingFlowConfig(isOn: false, trafficPercent: 0, enabledScreens: nil, disabledScreens: nil),
            "new_onb_5": OnboardingFlowConfig(isOn: false, trafficPercent: 0, enabledScreens: nil, disabledScreens: nil),
            "new_onb_6": OnboardingFlowConfig(isOn: false, trafficPercent: 0, enabledScreens: nil, disabledScreens: nil)
        ]),
        tiers: nil
    )

    private var countryTierMapping = OnboardingCountryTierMapping()

    private init() {}

    func updateFromRemoteConfig(_ jsonString: String) {
        let trimmed = jsonString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              let data = trimmed.data(using: .utf8),
              let config = try? JSONDecoder().decode(OnboardingControlConfig.self, from: data) else {
            runtimeConfig = nil
            return
        }

        runtimeConfig = config
        defaults.set(trimmed, forKey: storedJSONKey)
    }

    func currentAssignment(userId: String) -> OnboardingAssignment {
        let resolution = resolveAssignment(userId: userId)
        memoryAssignment = resolution.assignment
        saveAssignment(resolution.assignment)
        logDistribution(resolution)
        return resolution.assignment
    }

    func selectedFlowId(userId: String) -> String {
        currentAssignment(userId: userId).flowId
    }

    func visibleScreens(for flowId: String) -> [String] {
        let context = activeConfigContext()
        let flow = context.tierConfig.flows[flowId]
        let defaultScreens = defaultScreensByFlow[flowId] ?? flow?.enabledScreens ?? []

        if let enabledScreens = flow?.enabledScreens {
            let enabled = Set(enabledScreens)
            return defaultScreens.filter { enabled.contains($0) }
        }

        if let disabledScreens = flow?.disabledScreens {
            let disabled = Set(disabledScreens)
            return defaultScreens.filter { !disabled.contains($0) }
        }

        return defaultScreens
    }

    func activeTier() -> String {
        countryTierMapping.tier(for: currentCountryCode())
    }

    func debugSummary() -> String {
        let context = activeConfigContext()
        let enabled = activeFlows(in: context.tierConfig)
            .map { "\($0.id):\($0.config.trafficPercent)" }
            .joined(separator: ",")
        let assignment = loadAssignment()
        return [
            "experimentId=\(context.config.experimentId)",
            "version=\(context.config.version)",
            "tier=\(context.tier)",
            "path=\(context.selectedPath)",
            "fingerprint=\(context.configFingerprint)",
            "enabled=[\(enabled)]",
            "assignment=\(assignment?.flowId ?? "none")"
        ].joined(separator: " ")
    }

    func stableUserId() -> String {
        let rcUserId = Purchases.shared.appUserID
        if !rcUserId.isEmpty {
            return rcUserId
        }
        return UIDevice.current.identifierForVendor?.uuidString ?? "unknown_user"
    }

    func defaultControlJSON() -> String {
        (try? String(data: JSONEncoder().encode(fallbackConfig), encoding: .utf8)) ?? "{}"
    }

    private func resolveAssignment(userId: String) -> OnboardingControlResolution {
        let context = activeConfigContext()
        let configuredActive = activeFlows(in: context.tierConfig)
        let fallbackActive = activeFlows(in: fallbackConfig.defaultTier ?? OnboardingTierConfig(flows: [:]))
        let effectiveActive = configuredActive.isEmpty ? fallbackActive : configuredActive

        if let memoryAssignment,
           memoryAssignment.experimentId == context.config.experimentId,
           memoryAssignment.tier == context.tier,
           memoryAssignment.configFingerprint == context.configFingerprint,
           effectiveActive.contains(where: { $0.id == memoryAssignment.flowId }) {
            return makeResolution(
                assignment: memoryAssignment,
                context: context,
                activeFlows: effectiveActive,
                reason: "reused_saved_assignment"
            )
        }

        if let stored = loadAssignment(),
           stored.experimentId == context.config.experimentId,
           stored.tier == context.tier,
           stored.configFingerprint == context.configFingerprint,
           effectiveActive.contains(where: { $0.id == stored.flowId }) {
            return makeResolution(
                assignment: stored,
                context: context,
                activeFlows: effectiveActive,
                reason: "reused_saved_assignment"
            )
        }

        let hadPreviousAssignment = loadAssignment() != nil
        let reason: String
        if configuredActive.isEmpty {
            reason = "fallback_no_active_flows"
        } else if context.usesFallbackConfig {
            reason = "fallback_default_config"
        } else if hadPreviousAssignment {
            reason = "reassigned_config_changed"
        } else {
            reason = "selected_by_weight"
        }

        let bucket = stableBucket(userId: userId, experimentId: context.config.experimentId)
        let selected = selectFlow(from: effectiveActive, bucket: bucket) ?? effectiveActive.first
        let selectedFlowId = selected?.id ?? "onb_8_1"

        let assignment = OnboardingAssignment(
            experimentId: context.config.experimentId,
            flowId: selectedFlowId,
            bucket: bucket,
            assignedAtISO: isoFormatter.string(from: Date()),
            tier: context.tier,
            configFingerprint: context.configFingerprint
        )

        return makeResolution(
            assignment: assignment,
            context: context,
            activeFlows: effectiveActive,
            reason: reason
        )
    }

    private func activeConfigContext() -> OnboardingControlContext {
        let loaded = loadConfig()
        let config = loaded.config
        let tier = activeTier()

        if let tierConfig = config.tiers?[tier] {
            return OnboardingControlContext(
                config: config,
                tier: tier,
                tierConfig: tierConfig,
                selectedPath: tier,
                configFingerprint: fingerprint(for: tierConfig),
                usesFallbackConfig: loaded.usesFallback
            )
        }

        if let defaultTier = config.defaultTier {
            return OnboardingControlContext(
                config: config,
                tier: tier,
                tierConfig: defaultTier,
                selectedPath: "defaultTier",
                configFingerprint: fingerprint(for: defaultTier),
                usesFallbackConfig: loaded.usesFallback
            )
        }

        let fallbackTier = fallbackConfig.defaultTier ?? OnboardingTierConfig(flows: [:])
        return OnboardingControlContext(
            config: fallbackConfig,
            tier: tier,
            tierConfig: fallbackTier,
            selectedPath: "fallback_default_config",
            configFingerprint: fingerprint(for: fallbackTier),
            usesFallbackConfig: true
        )
    }

    private func loadConfig() -> (config: OnboardingControlConfig, usesFallback: Bool) {
        if let runtimeConfig {
            return (runtimeConfig, false)
        }

        if let json = defaults.string(forKey: storedJSONKey),
           let data = json.data(using: .utf8),
           let config = try? JSONDecoder().decode(OnboardingControlConfig.self, from: data) {
            runtimeConfig = config
            return (config, false)
        }

        return (fallbackConfig, true)
    }

    private func activeFlows(in tierConfig: OnboardingTierConfig) -> [(id: String, config: OnboardingFlowConfig)] {
        tierConfig.flows
            .filter { $0.value.isOn && $0.value.trafficPercent > 0 }
            .sorted { $0.key < $1.key }
            .map { (id: $0.key, config: $0.value) }
    }

    private func selectFlow(
        from flows: [(id: String, config: OnboardingFlowConfig)],
        bucket: Int
    ) -> (id: String, config: OnboardingFlowConfig)? {
        let totalWeight = flows.reduce(0) { $0 + max($1.config.trafficPercent, 0) }
        guard totalWeight > 0 else { return nil }

        let target = (Double(bucket) / 10000.0) * Double(totalWeight)
        var cumulative = 0.0

        for flow in flows {
            cumulative += Double(max(flow.config.trafficPercent, 0))
            if target < cumulative {
                return flow
            }
        }

        return flows.last
    }

    private func stableBucket(userId: String, experimentId: String) -> Int {
        let input = "\(userId)|\(experimentId)"
        let digest = SHA256.hash(data: Data(input.utf8))
        let value = digest.prefix(8).reduce(UInt64(0)) { partial, byte in
            (partial << 8) | UInt64(byte)
        }
        return Int(value % 10000)
    }

    private func fingerprint(for tierConfig: OnboardingTierConfig) -> String {
        let raw = tierConfig.flows
            .sorted { $0.key < $1.key }
            .map { flowId, config in
                [
                    flowId,
                    config.isOn ? "1" : "0",
                    String(config.trafficPercent),
                    config.enabledScreens?.joined(separator: ",") ?? "nil",
                    config.disabledScreens?.joined(separator: ",") ?? "nil"
                ].joined(separator: ":")
            }
            .joined(separator: "|")

        let digest = SHA256.hash(data: Data(raw.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    private func makeResolution(
        assignment: OnboardingAssignment,
        context: OnboardingControlContext,
        activeFlows: [(id: String, config: OnboardingFlowConfig)],
        reason: String
    ) -> OnboardingControlResolution {
        let selectedWeight = activeFlows.first(where: { $0.id == assignment.flowId })?.config.trafficPercent ?? 0
        let totalWeight = activeFlows.reduce(0) { $0 + max($1.config.trafficPercent, 0) }
        let normalizedPercent = totalWeight > 0 ? (Double(selectedWeight) / Double(totalWeight)) * 100.0 : 0.0

        return OnboardingControlResolution(
            assignment: assignment,
            context: context,
            activeFlows: activeFlows,
            decisionReason: reason,
            selectedFlowWeight: selectedWeight,
            selectedFlowNormalizedPercent: normalizedPercent
        )
    }

    private func logDistribution(_ resolution: OnboardingControlResolution) {
        let logKey = [
            resolution.assignment.experimentId,
            resolution.assignment.flowId,
            String(resolution.assignment.bucket),
            resolution.assignment.tier,
            resolution.assignment.configFingerprint,
            resolution.decisionReason
        ].joined(separator: "|")
        guard lastLoggedDistributionKey != logKey else { return }
        lastLoggedDistributionKey = logKey

        let enabledFlowIds = resolution.activeFlows.map(\.id)
        Analytics.logEvent("onboarding_distribution", parameters: [
            "experiment_id": resolution.assignment.experimentId,
            "selected_flow_id": resolution.assignment.flowId,
            "selected_path": resolution.context.selectedPath,
            "bucket": resolution.assignment.bucket,
            "tier": resolution.assignment.tier,
            "config_version": resolution.context.config.version,
            "config_fingerprint": resolution.assignment.configFingerprint,
            "enabled_flow_count": enabledFlowIds.count,
            "enabled_flows": enabledFlowIds.joined(separator: ","),
            "selected_flow_weight": resolution.selectedFlowWeight,
            "selected_flow_normalized_percent": resolution.selectedFlowNormalizedPercent,
            "has_seen_onboarding": defaults.bool(forKey: "hasSeenOnboarding"),
            "decision_reason": resolution.decisionReason
        ])
    }

    private func loadAssignment() -> OnboardingAssignment? {
        guard let data = defaults.data(forKey: assignmentKey) else { return nil }
        return try? JSONDecoder().decode(OnboardingAssignment.self, from: data)
    }

    private func saveAssignment(_ assignment: OnboardingAssignment) {
        guard let data = try? JSONEncoder().encode(assignment) else { return }
        defaults.set(data, forKey: assignmentKey)
    }

    private func currentCountryCode() -> String {
        if #available(iOS 16.0, *) {
            return Locale.current.region?.identifier ?? Locale.current.regionCode ?? "unknown"
        }
        return Locale.current.regionCode ?? "unknown"
    }
}

private struct OnboardingControlContext {
    let config: OnboardingControlConfig
    let tier: String
    let tierConfig: OnboardingTierConfig
    let selectedPath: String
    let configFingerprint: String
    let usesFallbackConfig: Bool
}

private struct OnboardingControlResolution {
    let assignment: OnboardingAssignment
    let context: OnboardingControlContext
    let activeFlows: [(id: String, config: OnboardingFlowConfig)]
    let decisionReason: String
    let selectedFlowWeight: Int
    let selectedFlowNormalizedPercent: Double
}

private struct OnboardingCountryTierMapping {
    var tier1Countries: Set<String> = ["US", "CA"]
    var tier2Countries: Set<String> = [
        "AL", "AD", "AT", "BY", "BE", "BA", "BG", "HR", "CY", "CZ",
        "DK", "EE", "FI", "FR", "DE", "GR", "HU", "IS", "IE", "IT",
        "XK", "LV", "LI", "LT", "LU", "MT", "MD", "MC", "ME", "NL",
        "MK", "NO", "PL", "PT", "RO", "RU", "SM", "RS", "SK", "SI",
        "ES", "SE", "CH", "TR", "UA", "GB", "VA"
    ]

    func tier(for countryCode: String) -> String {
        let code = countryCode.uppercased()
        if tier1Countries.contains(code) {
            return "tier_1"
        }
        if tier2Countries.contains(code) {
            return "tier_2"
        }
        return "tier_3"
    }
}
