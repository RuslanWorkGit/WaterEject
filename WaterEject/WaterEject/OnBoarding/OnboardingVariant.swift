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
    case A = "Onb_4.1"
    case B = "Onb_3.2"
    case C = "Onb_3.3"
    var id: String { rawValue }
}

final class OnboardingAB {
    static let shared = OnboardingAB()

    private init() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0 // на проді зроби 3600+ або більше
        rc.configSettings = settings
        rc.setDefaults([
            // Розподіл у %, A + B + (100 - A - B) = 100
            "onb_share_A": 34 as NSObject,
            "onb_share_B": 33 as NSObject,
            "onb_force": "" as NSObject // "A"/"B"/"C" або ""
        ])
    }

    private let rc = RemoteConfig.remoteConfig()
    private let storageKey = "onboarding_variant_v1"

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

    func variant() -> OnboardingVariant {
        // 1) кеш у UserDefaults
        if let raw = UserDefaults.standard.string(forKey: storageKey),
           let v = OnboardingVariant(rawValue: raw) {
            applyTracking(v)
            return v
        }

        // 2) форс через RC
        if let forced = OnboardingVariant(rawValue: rc["onb_force"].stringValue) {
            UserDefaults.standard.set(forced.rawValue, forKey: storageKey)
            applyTracking(forced)
            return forced
        }

        // 3) стабільний спліт за RC частками
        let shareA = min(max(rc["onb_share_A"].numberValue.intValue, 0), 100)
        let shareB = min(max(rc["onb_share_B"].numberValue.intValue, 0), 100)
        let clampedSum = min(shareA + shareB, 100)
        let shareC = 100 - clampedSum

        let bucket = abs(stableUserID().hashValue) % 100
        let v: OnboardingVariant
        if bucket < shareA {
            v = .A
        } else if bucket < (shareA + shareB) {
            v = .B
        } else {
            v = .C
        }

        UserDefaults.standard.set(v.rawValue, forKey: storageKey)
        applyTracking(v)
        return v
    }

    // Повертаємо конкретний флоу
    func assignedOnboardingView() -> AnyView {
        switch variant() {
        case .A:
            // Флоу 1
            //return AnyView(OnboardingFlowViewOne())
            return AnyView(OnboardingFlowViewFour())
        case .B:
            // Флоу 2
            return AnyView(OnboardingFlowViewTwo())
        case .C:
            // Флоу 3
            return AnyView(OnboardingFlowViewThree())
        }
    }
}
