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

enum PaywallVariant: String { case A, B } // A = PaywallFirstView, B = PaywallSecondView

final class PaywallAB {
    static let shared = PaywallAB()
    private init() {
        // RC дефолти
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0 // на проді зроби 3600+
        rc.configSettings = settings
        rc.setDefaults([
            "paywall_share_A": 50 as NSObject,   // % користувачів у варіант A
            "paywall_force": "" as NSObject       // "A" або "B" щоб форснути, або "" щоб вимкнено
        ])
    }

    private let rc = RemoteConfig.remoteConfig()
    private let storageKey = "paywall_variant_v1"

    func fetchRemoteConfig(completion: (() -> Void)? = nil) {
        rc.fetchAndActivate { _, _ in completion?() }
    }

    /// Стабільний ID (однаковий для користувача між сесіями)
    private func stableUserID() -> String {
        let id = Purchases.shared.appUserID
        return id.isEmpty
            ? UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
            : id
    }

    /// Отримати призначений варіант (кешується у UserDefaults)
    func variant() -> PaywallVariant {
        if let raw = UserDefaults.standard.string(forKey: storageKey),
           let v = PaywallVariant(rawValue: raw) { return v }

        // 1) перевіряємо форс із RC
        if let forced = PaywallVariant(rawValue: rc["paywall_force"].stringValue) {
            UserDefaults.standard.set(forced.rawValue, forKey: storageKey)
            return forced
        }

        // 2) 50/50 (або інший %) за RC
        let shareA = rc["paywall_share_A"].numberValue.intValue  // 0..100
        let bucket = abs(stableUserID().hashValue) % 100
        let v: PaywallVariant = (bucket < shareA) ? .A : .B

        UserDefaults.standard.set(v.rawValue, forKey: storageKey)
        return v
    }

    /// Готовий SwiftUI-в’ю для призначеного пейвола
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
