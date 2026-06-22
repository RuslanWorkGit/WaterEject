//
//  OnboardingVariant.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 29.09.2025.
//

import Foundation
import FirebaseRemoteConfig
import FirebaseAnalytics
import SwiftUI

enum OnboardingVariant: String, Identifiable, CaseIterable {
    case A = "Onb_4" // зараз OnboardingFlowViewFour
    case B = "Onb_3_2" // OnboardingFlowViewTwo
    case C = "Onb_3_3" // OnboardingFlowViewThree

    case D = "Onb_5" // OnboardingFlowViewFive
    case E = "Onb_6" // OnboardingFlowViewSix
    case F = "Onb_7" // OnboardingFlowViewSeven
    case G = "onb_8_1" // OnboardAnimationView
    case H = "Onb_9" // OnboardAnimationView
    case J = "Onb_3_1" // OnboardingFlowViewOne
    case K = "onb_10_1" // OnboardingFlowViewTen
    case L = "new_onb_1"
    case M = "new_onb_2"
    case N = "new_onb_3"
    case O = "new_onb_4"
    case P = "new_onb_5"
    case Q = "new_onb_6"
    case R = "new_onb_7"

    var id: String { rawValue }
}

private struct OnboardRemoteConfig: Decodable {
    let version: Int
    let flows: [String: OnboardRemoteFlow]
}

private struct OnboardRemoteFlow: Decodable {
    let isOn: Bool
    let trafficPercent: Int
}

extension OnboardingVariant {
    var onboardTag: OnboardTag {
        switch self {
        case .A: return .v41
        case .B: return .v32
        case .C: return .v33
        case .D: return .v5
        case .E: return .v6
        case .F: return .v7
        case .G: return .v8
        case .H: return .v9
        case .J: return .v31
        case .K: return .v10
        case .L, .M, .N, .O, .P, .Q, .R: return .new21
        }
    }

    var flowFamily: String {
        switch self {
        case .A, .B, .C, .J:
            return "classic"
        case .D, .E, .F, .G, .H, .K:
            return "new"
        case .L, .M, .N, .O, .P, .Q, .R:
            return "new_custom"
        }
    }
}

final class OnboardingAB {
    static let shared = OnboardingAB()
    private static let defaultOnboardConfigJSON = """
    {
      "version": 1,
      "flows": {
        "Onb_4": { "isOn": false, "trafficPercent": 0 },
        "Onb_3_1": { "isOn": false, "trafficPercent": 0 },
        "Onb_3_2": { "isOn": false, "trafficPercent": 0 },
        "Onb_3_3": { "isOn": false, "trafficPercent": 0 },
        "Onb_5": { "isOn": false, "trafficPercent": 0 },
        "Onb_6": { "isOn": false, "trafficPercent": 0 },
        "Onb_7": { "isOn": false, "trafficPercent": 0 },
        "Onb_8": { "isOn": true, "trafficPercent": 50 },
        "Onb_9": { "isOn": false, "trafficPercent": 0 },
        "Onb_10": { "isOn": true, "trafficPercent": 50 },
        "Onb_new_first_black_annual": { "isOn": false, "trafficPercent": 0 },
        "Onb_new_second_black": { "isOn": false, "trafficPercent": 0 },
        "Onb_new_third_black": { "isOn": false, "trafficPercent": 0 },
        "Onb_new_fourth_white": { "isOn": false, "trafficPercent": 0 },
        "Onb_new_fifth_white": { "isOn": false, "trafficPercent": 0 },
        "Onb_new_sixth_black": { "isOn": false, "trafficPercent": 0 },
        "Onb_new_seventh_black": { "isOn": false, "trafficPercent": 0 }
      }
    }
    """

    private init() {
            let settings = RemoteConfigSettings()
            #if DEBUG
            settings.minimumFetchInterval = 0
            #else
            settings.minimumFetchInterval = 1800 // на проді зроби 3600+
            #endif
            rc.configSettings = settings

            rc.setDefaults([
                "onb_force": "" as NSObject,
                "onboard_config_json": Self.defaultOnboardConfigJSON as NSObject,
                OnboardingControlProvider.remoteConfigKey: OnboardingControlProvider.shared.defaultControlJSON() as NSObject,

                // 🔹 прапорці для кожного онборду
                "Onb_4_enabled": false as NSObject,
                "Onb_3_1_enabled": false as NSObject,
                "Onb_3_2_enabled": false as NSObject,
                "Onb_3_3_enabled": false as NSObject,
                "Onb_5_enabled": false as NSObject,
                "Onb_6_enabled": false as NSObject,
                "Onb_7_enabled": false as NSObject,
                "Onb_8_enabled": true as NSObject,
                "Onb_9_enabled": false as NSObject,
                "Onb_10_enabled": true as NSObject,
                "Onb_new_first_black_annual_enabled": false as NSObject,
                "Onb_new_second_black_enabled": false as NSObject,
                "Onb_new_third_black_enabled": false as NSObject,
                "Onb_new_fourth_white_enabled": false as NSObject,
                "Onb_new_fifth_white_enabled": false as NSObject,
                "Onb_new_sixth_black_enabled": false as NSObject,
                "Onb_new_seventh_black_enabled": false as NSObject
            ])
        }

    private let rc = RemoteConfig.remoteConfig()
    private let storageKey = "onboarding_variant_v2"
    private let rcSignatureKey = "onboarding_rc_signature_v1"
    private let configJSONKey = "onboard_config_json"

    private func legacyIsEnabled(_ variant: OnboardingVariant) -> Bool {
        let key = "\(variant.rawValue)_enabled"   // наприклад "Onb_3.3_enabled"
        return rc[key].boolValue                  // якщо ключа нема – буде false
    }

    private func remoteConfigJSON() -> String {
        rc[configJSONKey].stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func onboardConfig() -> OnboardRemoteConfig? {
        let json = remoteConfigJSON()
        guard !json.isEmpty, let data = json.data(using: .utf8) else {
            return nil
        }
        return try? JSONDecoder().decode(OnboardRemoteConfig.self, from: data)
    }

    private func flowConfig(for variant: OnboardingVariant, in config: OnboardRemoteConfig) -> OnboardRemoteFlow? {
        config.flows[variant.rawValue]
    }

    private func isEnabled(_ variant: OnboardingVariant, config: OnboardRemoteConfig?) -> Bool {
        if let config, let flow = flowConfig(for: variant, in: config) {
            return flow.isOn && flow.trafficPercent > 0
        }
        return legacyIsEnabled(variant)
    }

    private func enabledVariants(config: OnboardRemoteConfig?) -> [(variant: OnboardingVariant, trafficPercent: Int)] {
        if let config {
            return OnboardingVariant.allCases.compactMap { variant in
                guard let flow = flowConfig(for: variant, in: config),
                      flow.isOn,
                      flow.trafficPercent > 0 else {
                    return nil
                }
                return (variant, min(max(flow.trafficPercent, 0), 100))
            }
        }

        return OnboardingVariant.allCases
            .filter { legacyIsEnabled($0) }
            .map { ($0, 1) }
    }

    private func stableBucket(seed: String, modulo: Int) -> Int {
        guard modulo > 0 else { return 0 }
        var hash: UInt64 = 14695981039346656037
        for byte in seed.utf8 {
            hash ^= UInt64(byte)
            hash &*= 1099511628211
        }
        return Int(hash % UInt64(modulo))
    }

    private func weightedVariant(from pool: [(variant: OnboardingVariant, trafficPercent: Int)], seed: String) -> OnboardingVariant? {
        let total = pool.reduce(0) { $0 + max($1.trafficPercent, 0) }
        guard total > 0 else { return nil }

        var bucket = stableBucket(seed: seed, modulo: total)
        for item in pool {
            let weight = max(item.trafficPercent, 0)
            if bucket < weight {
                return item.variant
            }
            bucket -= weight
        }
        return pool.last?.variant
    }

    func fetchRemoteConfig(completion: (() -> Void)? = nil) {
        rc.fetchAndActivate { [weak self] _, _ in
            self?.updateControlProviderFromRemoteConfig()
            completion?()
        }
    }

    private func stableUserID() -> String {
        let key = "onboarding_ab_stable_user_id"
        if let storedId = UserDefaults.standard.string(forKey: key), !storedId.isEmpty {
            return storedId
        }

        let newId = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        UserDefaults.standard.set(newId, forKey: key)
        return newId
    }

    private func applyTracking(_ v: OnboardingVariant) {
        Analytics.setUserProperty(v.rawValue, forName: "onboarding_variant")

        let key = "onboarding_variant_assigned_logged_v1"
        if !UserDefaults.standard.bool(forKey: key) {
            Analytics.logEvent("onboarding_variant_assigned", parameters: ["variant": v.rawValue])
            UserDefaults.standard.set(true, forKey: key)
        }
    }

    private func applyTelemetrySelection(_ variant: OnboardingVariant) {
        let tag = variant.onboardTag
        let bucket = stableBucket(seed: stableUserID() + "|\(variant.rawValue)|onboarding_variant_v2", modulo: 100)
        let keywordId = UserDefaults.standard.string(forKey: "asaKeywordId")
        let keywordText = UserDefaults.standard.string(forKey: "asaKeywordText")

        Telemetry.shared.setPresentedOnboardingContext(
            brand: nil,
            onboardId: tag.rawValue,
            flowKey: variant.rawValue,
            flowId: nil,
            brandedFlow: nil,
            onbExperimentId: "onboarding_variant_v2",
            onbVariantId: variant.rawValue,
            onbBucket: String(bucket)
        )

        Telemetry.shared.markOnboardingDistribution(
            selectedOnboardId: tag.rawValue,
            selectedFlowKey: variant.rawValue,
            genericVariantId: variant.rawValue,
            genericFlowFamily: variant.flowFamily,
            decisionReason: "remote_config_assignment",
            selectedPath: "generic",
            brand: nil,
            selectedBrand: nil,
            detectedBrand: nil,
            keywordId: keywordId,
            keywordText: keywordText
        )
    }

    private func currentRCSignature() -> String {
        let force = rc["onb_force"].stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let configJSON = remoteConfigJSON()

        // важливо: включаємо всі прапорці, щоб будь-яка зміна RC міняла signature
        let flags = OnboardingVariant.allCases
            .map { "\($0.rawValue)=\(legacyIsEnabled($0) ? 1 : 0)" }
            .joined(separator: "|")

        return "force=\(force)|json=\(configJSON)|legacy_flags=\(flags)"
    }

    @discardableResult
    func syncAssignmentIfRCChanged() -> Bool {
        updateControlProviderFromRemoteConfig()
        return true
    }

    func variant() -> OnboardingVariant {
        switch currentControlAssignment().flowId {
        case "new_onb_1": return .L
        case "new_onb_2": return .M
        case "new_onb_3": return .N
        case "new_onb_4": return .O
        case "new_onb_5": return .P
        case "new_onb_6": return .Q
        case "new_onb_7": return .R
        case "onb_10_1": return .K
        case "onb_8_1": return .G
        default: return .G
        }
    }

    func currentControlAssignment() -> OnboardingAssignment {
        updateControlProviderFromRemoteConfig()
        let assignment = OnboardingControlProvider.shared.currentAssignment(userId: stableUserID())
        applyControlTelemetry(assignment)
        return assignment
    }

    func selectedControlFlowId() -> String {
        currentControlAssignment().flowId
    }

    func debugControlSummary() -> String {
        OnboardingControlProvider.shared.debugSummary()
    }

    private func updateControlProviderFromRemoteConfig() {
        OnboardingControlProvider.shared.updateFromRemoteConfig(
            rc[OnboardingControlProvider.remoteConfigKey].stringValue
        )
    }

    private func applyControlTelemetry(_ assignment: OnboardingAssignment) {
        Analytics.setUserProperty(assignment.flowId, forName: "onboarding_variant")

        Telemetry.shared.setPresentedOnboardingContext(
            brand: nil,
            onboardId: assignment.flowId,
            flowKey: assignment.flowId,
            flowId: assignment.flowId,
            brandedFlow: nil,
            onbExperimentId: assignment.experimentId,
            onbVariantId: assignment.flowId,
            onbBucket: String(assignment.bucket)
        )
    }

    // Повертаємо конкретний флоу
    func assignedOnboardingView() -> AnyView {
        let assignment = currentControlAssignment()

        switch assignment.flowId {
        case "new_onb_1":
            return AnyView(NewFirstBlackAnnualOnboardingFlowView(flowKey: assignment.flowId, assignment: assignment))
        case "new_onb_2":
            return AnyView(NewSecondBlackOnboardingFlowView(flowKey: assignment.flowId, assignment: assignment))
        case "new_onb_3":
            return AnyView(NewThirdBlackOnboardingFlowView(flowKey: assignment.flowId, assignment: assignment))
        case "new_onb_4":
            return AnyView(NewFourthWhiteOnboardingFlowView(flowKey: assignment.flowId, assignment: assignment))
        case "new_onb_5":
            return AnyView(NewFifthWhiteOnboardingFlowView(flowKey: assignment.flowId, assignment: assignment))
        case "new_onb_6":
            return AnyView(NewSixthBlackOnboardingFlowView(flowKey: assignment.flowId, assignment: assignment))
        case "new_onb_7":
            return AnyView(NewSeventhBlackOnboardingFlowView(flowKey: assignment.flowId, assignment: assignment))
        case "onb_8_1":
            return AnyView(OnboardAnimationView(controlFlowId: assignment.flowId, assignment: assignment))
        case "onb_10_1":
            return AnyView(OnboardingFlowViewTen(controlFlowId: assignment.flowId, assignment: assignment))
        default:
            return AnyView(OnboardAnimationView())
        }
    }

    func legacyAssignedOnboardingView() -> AnyView {
        switch variant() {
        case .A:
            // старий флоу 4.1
            return AnyView(OnboardingFlowViewFour())

        case .B:
            return AnyView(OnboardingFlowViewTwo())

        case .C:
            return AnyView(OnboardingFlowViewThree())

        case .D:
            return AnyView(OnboardingFlowViewFive())

        case .E:
            return AnyView(OnboardingFlowViewSix())

        case .F:
            return AnyView(OnboardingFlowViewSeven())

        case .G:
            return AnyView(OnboardAnimationView())
        case .H:
            return AnyView(OnboardingFlowViewNine())
        case .J:
            return AnyView(OnboardingFlowViewOne())
        case .K:
            return AnyView(OnboardingFlowViewTen())
        case .L:
            return AnyView(NewFirstBlackAnnualOnboardingFlowView(flowKey: OnboardingVariant.L.rawValue))
        case .M:
            return AnyView(NewSecondBlackOnboardingFlowView(flowKey: OnboardingVariant.M.rawValue))
        case .N:
            return AnyView(NewThirdBlackOnboardingFlowView(flowKey: OnboardingVariant.N.rawValue))
        case .O:
            return AnyView(NewFourthWhiteOnboardingFlowView(flowKey: OnboardingVariant.O.rawValue))
        case .P:
            return AnyView(NewFifthWhiteOnboardingFlowView(flowKey: OnboardingVariant.P.rawValue))
        case .Q:
            return AnyView(NewSixthBlackOnboardingFlowView(flowKey: OnboardingVariant.Q.rawValue))
        case .R:
            return AnyView(NewSeventhBlackOnboardingFlowView(flowKey: OnboardingVariant.R.rawValue))
        }
    }
}
