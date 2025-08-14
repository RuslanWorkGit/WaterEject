//
//  PaywallVariant.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 13.08.2025.
//

import Foundation
import FirebaseRemoteConfig
import FirebaseAnalytics
import RevenueCat
import SwiftUI

enum PaywallVariant: String, Identifiable {
    case A, B
    var id: String { rawValue }
}

final class PaywallAB {
    static let shared = PaywallAB()

    private init() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0 // на проді зроби 3600+
        rc.configSettings = settings
        rc.setDefaults([
            "paywall_share_A": 50 as NSObject,   // % у варіант A
            "paywall_force": "" as NSObject      // "A"/"B" або ""
        ])
    }

    private let rc = RemoteConfig.remoteConfig()
    private let storageKey = "paywall_variant_v1"

    func fetchRemoteConfig(completion: (() -> Void)? = nil) {
        rc.fetchAndActivate { _, _ in completion?() }
    }

    private func stableUserID() -> String {
        let id = Purchases.shared.appUserID
        return id.isEmpty
            ? UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
            : id
    }

    // ❗️Єдина точка, що ставить user property + RC attributes
    private func applyTracking(_ v: PaywallVariant) {
        Analytics.setUserProperty(v.rawValue, forName: "paywall_variant")
        Purchases.shared.attribution.setAttributes(["paywall_variant": v.rawValue])
        
        let key = "variant_assigned_logged_v1"
            if !UserDefaults.standard.bool(forKey: key) {
                Analytics.logEvent("variant_assigned", parameters: ["variant": v.rawValue])
                UserDefaults.standard.set(true, forKey: key)
            }
    }

    func variant() -> PaywallVariant {
        // 1) уже є в кеші
        if let raw = UserDefaults.standard.string(forKey: storageKey),
           let v = PaywallVariant(rawValue: raw) {
            applyTracking(v) // <-- не забуваємо
            return v
        }

        // 2) форс із RC
        if let forced = PaywallVariant(rawValue: rc["paywall_force"].stringValue) {
            UserDefaults.standard.set(forced.rawValue, forKey: storageKey)
            applyTracking(forced)
            return forced
        }

        // 3) спліт за RC
        let rawShare = rc["paywall_share_A"].numberValue.intValue
        let shareA = min(max(rawShare, 0), 100) // clamp 0...100
        let bucket = abs(stableUserID().hashValue) % 100
        let v: PaywallVariant = (bucket < shareA) ? .A : .B

        UserDefaults.standard.set(v.rawValue, forKey: storageKey)
        applyTracking(v)
        return v
    }

    func assignedPaywallView(onFinish: @escaping () -> Void) -> AnyView {
        switch variant() {
        case .A: return AnyView(PaywallFirstView(onFinish: onFinish))
        case .B: return AnyView(PaywallSecondView(onFinish: onFinish))
        }
    }
}


enum PaywallRouter {
    static func presentAssigned(from presenter: UIViewController, onFinish: @escaping () -> Void = {}) {
        let view = PaywallAB.shared.assignedPaywallView(onFinish: onFinish)
        let vc = UIHostingController(rootView: view)
        Analytics.logEvent("paywall_exposure", parameters: ["variant": PaywallAB.shared.variant().rawValue])
        Purchases.shared.attribution.setAttributes(["paywall_variant": PaywallAB.shared.variant().rawValue])
        presenter.present(vc, animated: true)
    }
}

extension View {
    func presentAssignedPaywall(onFinish: @escaping () -> Void = {}) {
        guard let root = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?.rootViewController else { return }

        PaywallRouter.presentAssigned(from: root, onFinish: onFinish)
    }
}
