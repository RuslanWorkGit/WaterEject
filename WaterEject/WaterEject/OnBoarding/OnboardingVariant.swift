//
//  OnboardingVariant.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 29.09.2025.
//

import Foundation
import FirebaseRemoteConfig
import FirebaseAnalytics
import RevenueCat
import SwiftUI

enum OnboardingVariant: String, Identifiable, CaseIterable {
    case A = "Onb_4" // зараз OnboardingFlowViewFour
    case B = "Onb_3_2" // OnboardingFlowViewTwo
    case C = "Onb_3_3" // OnboardingFlowViewThree
    
    case D = "Onb_5" // OnboardingFlowViewFive
    case E = "Onb_6" // OnboardingFlowViewSix
    case F = "Onb_7" // OnboardingFlowViewSeven
    case G = "Onb_8" // OnboardAnimationView
    case H = "Onb_9" // OnboardAnimationView
    case J = "Onb_3_1" // OnboardingFlowViewOne
    case K = "Onb_10" // OnboardAnimationView
    
    var id: String { rawValue }
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
        }
    }

    var flowFamily: String {
        switch self {
        case .A, .B, .C, .J:
            return "classic"
        case .D, .E, .F, .G, .H, .K:
            return "new"
        }
    }
}

final class OnboardingAB {
    static let shared = OnboardingAB()
    
    private init() {
            let settings = RemoteConfigSettings()
            settings.minimumFetchInterval = 1800 // на проді зроби 3600+
            rc.configSettings = settings
            
            rc.setDefaults([
                "onb_force": "" as NSObject,
                
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
                "Onb_10_enabled": true as NSObject
            ])
        }
    
    private let rc = RemoteConfig.remoteConfig()
    private let storageKey = "onboarding_variant_v2"
    private let rcSignatureKey = "onboarding_rc_signature_v1"
    
    private func isEnabled(_ variant: OnboardingVariant) -> Bool {
        let key = "\(variant.rawValue)_enabled"   // наприклад "Onb_3.3_enabled"
        return rc[key].boolValue                  // якщо ключа нема – буде false
    }
    
    func fetchRemoteConfig(completion: (() -> Void)? = nil) {
        rc.fetchAndActivate { _, _ in completion?() }
    }
    
    private func stableUserID() -> String {
        // така ж логіка як у PaywallAB: беремо RC/RevenueCat user id або IDFV
        let id = Purchases.shared.appUserID
        return id.isEmpty
        ? UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        : id
    }
    
    private func applyTracking(_ v: OnboardingVariant) {
        Analytics.setUserProperty(v.rawValue, forName: "onboarding_variant")
        Purchases.shared.attribution.setAttributes(["onboarding_variant": v.rawValue])
        
        let key = "onboarding_variant_assigned_logged_v1"
        if !UserDefaults.standard.bool(forKey: key) {
            Analytics.logEvent("onboarding_variant_assigned", parameters: ["variant": v.rawValue])
            UserDefaults.standard.set(true, forKey: key)
        }
    }

    private func applyTelemetrySelection(_ variant: OnboardingVariant) {
        let tag = variant.onboardTag
        let bucket = abs((stableUserID() + "|\(variant.rawValue)|onboarding_variant_v2").hashValue) % 100
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

        // важливо: включаємо всі прапорці, щоб будь-яка зміна RC міняла signature
        let flags = OnboardingVariant.allCases
            .map { "\($0.rawValue)=\(isEnabled($0) ? 1 : 0)" }
            .joined(separator: "|")

        return "force=\(force)|flags=\(flags)"
    }

    @discardableResult
    func syncAssignmentIfRCChanged() -> Bool {
        let sig = currentRCSignature()
        let old = UserDefaults.standard.string(forKey: rcSignatureKey)

        guard old != sig else { return false }

        UserDefaults.standard.set(sig, forKey: rcSignatureKey)
        UserDefaults.standard.removeObject(forKey: storageKey)   // 👈 скидаємо кеш варіанта
        return true
    }
    
    func variant() -> OnboardingVariant {
        
        _ = syncAssignmentIfRCChanged()
        
            // 1) спроба взяти закешований варіант, але тільки якщо він ще enabled
            if let raw = UserDefaults.standard.string(forKey: storageKey),
               let v = OnboardingVariant(rawValue: raw),
               isEnabled(v) {
                applyTracking(v)
                applyTelemetrySelection(v)
                return v
            }
            
            // 2) форсований варіант із RC, якщо він існує і enabled
            if let forced = OnboardingVariant(rawValue: rc["onb_force"].stringValue),
               isEnabled(forced) {
                UserDefaults.standard.set(forced.rawValue, forKey: storageKey)
                applyTracking(forced)
                applyTelemetrySelection(forced)
                return forced
            }
            
            // 3) беремо тільки увімкнені онборди
            let enabled = OnboardingVariant.allCases.filter { isEnabled($0) }
            
            // 4) якщо раптом у RC усі вимкнули (або ще не підвантажилось) – фолбек на дефолтний пул
            let fallbackPool: [OnboardingVariant] = [.G, .K]
            let pool = enabled.isEmpty ? fallbackPool : enabled
//            let pool = enabled.isEmpty ? OnboardingVariant.allCases : enabled
            // тут дефолтний ти контролюєш тим, як будеш розподіляти або можеш явно вибрати, наприклад:
            // let fallback: OnboardingVariant = .G
            
            let bucket = abs(stableUserID().hashValue) % pool.count
            let v = pool[bucket]
            
            UserDefaults.standard.set(v.rawValue, forKey: storageKey)
            applyTracking(v)
            applyTelemetrySelection(v)
            return v
        }
    
    
    // Повертаємо конкретний флоу
    func assignedOnboardingView() -> AnyView {
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
        }
    }
}
