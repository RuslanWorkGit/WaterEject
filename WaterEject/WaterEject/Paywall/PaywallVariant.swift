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
    case third    = "third"  // наш основний
    case fourth   = "fourth"  // НОВИЙ PaywallFourView
//    case A        = "A"
//    case B        = "B"
    
    var id: String { rawValue }
}

final class PaywallAB {
    static let shared = PaywallAB()
    
    private init() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 1800 // на проді зроби 3600+
        rc.configSettings = settings
        rc.setDefaults([
            "paywall_share_A": 50 as NSObject,   // якщо колись повернешся до спліта
            "paywall_force":   "" as NSObject, // <- ВСІ бачать PaywallThirdView
            
            // ⬇️ нові ключі
            "paywall3_enabled": true as NSObject,
            "paywall4_enabled": true as NSObject
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
    
    private func isEnabled(_ v: PaywallVariant) -> Bool {
        switch v {
        case .third:
            return rc["paywall3_enabled"].boolValue
        case .fourth:
            return rc["paywall4_enabled"].boolValue
//        case .A, .B:
//            return true
        }
    }
    
    private func primaryOnboardingVariant(for tag: OnboardTag) -> PaywallVariant {
        switch tag {
        case .v31, .v32, .v33, .v41:        // OnboardingFlowViewTwo / Three
            return .third       // старий пейвол основний
        case .v5, .v6, .v7, .v8, .v9: // нові флоу 5/6/7/8
            return .fourth      // новий пейвол основний
        default:
            return .fourth
        }
    }
    
    func onboardingPaywallVariant(for tag: OnboardTag) -> PaywallVariant {
        // 0) форс з RC — як і було, має абсолютний пріоритет
        let forceKey = rc["paywall_force"].stringValue
        if !forceKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
           let forced = parseForcedVariant(forceKey) {
            return forced
        }

        let primary  = primaryOnboardingVariant(for: tag)
        let fallback: PaywallVariant = (primary == .third ? .fourth : .third)

        let primaryEnabled  = isEnabled(primary)
        let fallbackEnabled = isEnabled(fallback)

        switch (primaryEnabled, fallbackEnabled) {
        case (true, false):
            // увімкнений тільки primary → показуємо його
            return primary

        case (false, true):
            // увімкнений тільки fallback → показуємо його
            return fallback

        case (false, false):
            // обидва вимкнені → безпечний фолбек (щоб не впасти)
            return primary

        case (true, true):
            // ⬅️ коли ОБИДВА true робимо стабільний “рандом” 50/50
            let seed = stableUserID() + "|\(tag.rawValue)|paywallAB"
            let bucket = abs(seed.hashValue) % 2
            return (bucket == 0) ? primary : fallback
        }
    }

    
    func onboardingPaywallView(
        for tag: OnboardTag,
        onFinish: @escaping () -> Void,
        startDelay: Double,
        stepsVisited: [String]?
    ) -> AnyView {
        let variant = onboardingPaywallVariant(for: tag)

        switch variant {
        case .third:
            return AnyView(
                PaywallThirdView(
                    onFinish: onFinish,
                    onboardId: tag.rawValue,
                    startDelay: startDelay,
                    summaryTag: tag,
                    stepsVisited: stepsVisited
                )
            )

        case .fourth:
            return AnyView(
                PaywallFourView(
                    onFinish: onFinish,
                    onboardId: tag.rawValue,
                    startDelay: startDelay,
                    summaryTag: tag,
                    stepsVisited: stepsVisited
                )
            )

//        case .A, .B:
//            // якщо колись захочеш ще варіанти – тут можна розширити
//            return AnyView(
//                PaywallStubView(title: "Paywall A/B (stub)", onClose: onFinish)
//            )
        }
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
    // Допоміжний парсер RC-рядка (ігнорує регістр/пробіли)
    private func parseForcedVariant(_ s: String) -> PaywallVariant? {
        let t = s.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        switch t {
//        case "A":      return .A
//        case "B":      return .B
        case "THIRD", "C", "PAYWALL3": return .third
        case "FOURTH", "PAYWALL4", "D":      // ⬅️ додали
            return .fourth
        default:       return nil
        }
    }
    
    func variant() -> PaywallVariant {
        // 1) Якщо у RC заданий форс — він має ПРІОРИТЕТ над кешем
        if let forced = parseForcedVariant(rc["paywall_force"].stringValue) {
            UserDefaults.standard.set(forced.rawValue, forKey: storageKey)
            applyTracking(forced)
            return forced
        }
        
        // 2) Інакше беремо з кешу
        if let raw = UserDefaults.standard.string(forKey: storageKey),
           let v = PaywallVariant(rawValue: raw) {
            applyTracking(v)
            return v
        }
        
        // 3) Якщо форсу немає і кешу немає — зробимо спліт (на майбутнє)
        let rawShare = rc["paywall_share_A"].numberValue.intValue
        let shareA = min(max(rawShare, 0), 100)
        let bucket = abs(stableUserID().hashValue) % 100
        //let v: PaywallVariant = (bucket < shareA) ? .A : .B
        
//        UserDefaults.standard.set(v.rawValue, forKey: storageKey)
//        applyTracking(v)
        return .fourth
    }
    
    
    func assignedPaywallView(onFinish: @escaping () -> Void) -> AnyView {
        switch variant() {
        case .third:
            return AnyView(PaywallThirdView(onFinish: onFinish))
        case .fourth:
            // НОВИЙ пейвол як варіант
            return AnyView(
                PaywallFourView(onFinish: onFinish)
            )
//        case .A:
//            return AnyView(PaywallStubView(title: "Paywall A (stub)", onClose: onFinish))
//        case .B:
//            return AnyView(PaywallStubView(title: "Paywall B (stub)", onClose: onFinish))
        }
    }
}


// Простенька заглушка, щоб не падало і було що показати
struct PaywallStubView: View {
    let title: String
    let onClose: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 16) {
                Text(title)
                    .foregroundStyle(.white)
                    .font(.title2.bold())
                Button("Close") { onClose() }
                    .buttonStyle(.borderedProminent)
            }
            .padding()
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
