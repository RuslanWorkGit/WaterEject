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
    case A = "Onb_4.1" // зараз OnboardingFlowViewFour
    case B = "Onb_3.2" // OnboardingFlowViewTwo
    case C = "Onb_3.3" // OnboardingFlowViewThree
    
    case D = "Onb_5.0" // OnboardingFlowViewFive
    case E = "Onb_6.0" // OnboardingFlowViewSix
    case F = "Onb_7.0" // OnboardingFlowViewSeven
    case G = "Onb_8.0" // OnboardAnimationView
    case H = "Onb_9.0" // OnboardAnimationView
    
    var id: String { rawValue }
}

final class OnboardingAB {
    static let shared = OnboardingAB()
    
    private init() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0 // на проді зроби 3600+ або більше
        rc.configSettings = settings
        rc.setDefaults([
            "onb_force": "" as NSObject // "Onb_4.1", "Onb_5.0" тощо або ""
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
        
        // 2) форс через RC (залишаємо)
        if let forced = OnboardingVariant(rawValue: rc["onb_force"].stringValue) {
            UserDefaults.standard.set(forced.rawValue, forKey: storageKey)
            applyTracking(forced)
            return forced
        }
        
        // 3) рівномірний спліт по всіх варіантах
        let all = OnboardingVariant.allCases
        let bucket = abs(stableUserID().hashValue) % all.count
        let v = all[bucket]
        
        UserDefaults.standard.set(v.rawValue, forKey: storageKey)
        applyTracking(v)
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
        }
    }
}
