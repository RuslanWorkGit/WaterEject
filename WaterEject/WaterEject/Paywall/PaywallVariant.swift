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
    case A        = "A"
    case B        = "B"
    
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
            "paywall_force":   "third" as NSObject // <- ВСІ бачать PaywallThirdView
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
    // Допоміжний парсер RC-рядка (ігнорує регістр/пробіли)
    private func parseForcedVariant(_ s: String) -> PaywallVariant? {
        let t = s.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        switch t {
        case "A":      return .A
        case "B":      return .B
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
        let v: PaywallVariant = (bucket < shareA) ? .A : .B
        
        UserDefaults.standard.set(v.rawValue, forKey: storageKey)
        applyTracking(v)
        return v
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
        case .A:
            return AnyView(PaywallStubView(title: "Paywall A (stub)", onClose: onFinish))
        case .B:
            return AnyView(PaywallStubView(title: "Paywall B (stub)", onClose: onFinish))
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
