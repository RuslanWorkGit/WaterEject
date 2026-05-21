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
    case fifth     = "fifth"
//    case A        = "A"
//    case B        = "B"

    var id: String { rawValue }
}

struct PaywallProductSettings {
    let weeklyProductID: String
    let yearlyProductID: String
    let annualProductID: String
    let freeTest: Bool
}

private struct PaywallProductsRemoteConfig: Decodable {
    let version: Int?
    let paywalls: [String: PaywallProductRemoteConfig]
}

private struct PaywallProductRemoteConfig: Decodable {
    let weeklyProductId: String?
    let yearlyProductId: String?
    let annualProductId: String?
    let freeTest: Bool?
}

final class PaywallAB {
    static let shared = PaywallAB()

    static let defaultPaywallProductsJSON = """
    {
      "version": 1,
      "paywalls": {
        "first": {
          "weeklyProductId": "kyryloVoinov.WaterEject.subscription.weekly",
          "yearlyProductId": "kyryloVoinov.WaterEject.subscription.yearly",
          "freeTest": false
        },
        "second": {
          "weeklyProductId": "kyryloVoinov.WaterEject.subscription.weekly",
          "yearlyProductId": "kyryloVoinov.WaterEject.subscription.yearly",
          "freeTest": false
        },
        "third": {
          "weeklyProductId": "kyryloVoinov.WaterEject.subscription.weekly",
          "yearlyProductId": "kyryloVoinov.WaterEject.subscription.yearly",
          "freeTest": false
        },
        "fourth": {
          "weeklyProductId": "kyryloVoinov.WaterEject.subscription.weekly",
          "yearlyProductId": "kyryloVoinov.WaterEject.subscription.yearly",
          "freeTest": false
        },
        "fifth": {
          "weeklyProductId": "kyryloVoinov.WaterEject.subscription.weekly",
          "yearlyProductId": "kyryloVoinov.WaterEject.subscription.yearly",
          "freeTest": true
        },
        "special": {
          "weeklyProductId": "kyryloVoinov.WaterEject.subscription.weeklyPecialOffer",
          "freeTest": false
        },
        "paywall_new_black_1": {
          "weeklyProductId": "kyryloVoinov.WaterEject.subscription.weekly",
          "annualProductId": "KyryloVoinov.WaterEject.lifetime.access",
          "freeTest": false
        },
        "paywall_new_black_2": {
          "weeklyProductId": "kyryloVoinov.WaterEject.subscription.weekly",
          "annualProductId": "KyryloVoinov.WaterEject.lifetime.access",
          "freeTest": false
        },
        "paywall_new_black_3": {
          "annualProductId": "KyryloVoinov.WaterEject.lifetime.access",
          "freeTest": false
        },
        "paywall_new_black_4": {
          "annualProductId": "KyryloVoinov.WaterEject.lifetime.access",
          "freeTest": false
        },
        "paywall_new_black_5": {
          "annualProductId": "KyryloVoinov.WaterEject.lifetime.access",
          "freeTest": false
        },
        "paywall_new_white_1": {
          "weeklyProductId": "kyryloVoinov.WaterEject.subscription.weekly",
          "annualProductId": "KyryloVoinov.WaterEject.lifetime.access",
          "freeTest": false
        }
      }
    }
    """

    private init() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 1800 // на проді зроби 3600+
        rc.configSettings = settings
        rc.setDefaults([
            "paywall_share_A": 50 as NSObject,   // якщо колись повернешся до спліта
            "paywall_force":   "" as NSObject, // <- ВСІ бачать PaywallThirdView

            // ⬇️ нові ключі
            "paywall3_enabled": true as NSObject,
            "paywall4_enabled": true as NSObject,
            "paywall5_enabled": true as NSObject,
            "paywall_products_json": Self.defaultPaywallProductsJSON as NSObject
        ])
    }

    private let rc = RemoteConfig.remoteConfig()
    private let storageKey = "paywall_variant_v1"
    private let productsJSONKey = "paywall_products_json"

    private let allPaywalls: [PaywallVariant] = [.third, .fourth, .fifth]

    private func enabledPaywalls() -> [PaywallVariant] {
        allPaywalls.filter { isEnabled($0) }
    }

    func fetchRemoteConfig(completion: (() -> Void)? = nil) {
        rc.fetchAndActivate { _, _ in completion?() }
    }

    func productSettings(for variant: PaywallVariant) -> PaywallProductSettings {
        productSettings(forKey: variant.rawValue)
    }

    func productSettings(forKey key: String) -> PaywallProductSettings {
        let fallback = Self.defaultProductSettings(forKey: key)
        let json = rc[productsJSONKey].stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !json.isEmpty,
              let data = json.data(using: .utf8),
              let config = try? JSONDecoder().decode(PaywallProductsRemoteConfig.self, from: data),
              let remote = config.paywalls[key] else {
            return fallback
        }

        return PaywallProductSettings(
            weeklyProductID: cleanProductID(remote.weeklyProductId) ?? fallback.weeklyProductID,
            yearlyProductID: cleanProductID(remote.yearlyProductId) ?? fallback.yearlyProductID,
            annualProductID: cleanProductID(remote.annualProductId) ?? fallback.annualProductID,
            freeTest: remote.freeTest ?? fallback.freeTest
        )
    }

    private func cleanProductID(_ value: String?) -> String? {
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? nil : trimmed
    }

    private static func defaultProductSettings(forKey key: String) -> PaywallProductSettings {
        let weeklyProductID = key == "special"
            ? "kyryloVoinov.WaterEject.subscription.weeklyPecialOffer"
            : "kyryloVoinov.WaterEject.subscription.weekly"

        PaywallProductSettings(
            weeklyProductID: weeklyProductID,
            yearlyProductID: "kyryloVoinov.WaterEject.subscription.yearly",
            annualProductID: "KyryloVoinov.WaterEject.lifetime.access",
            freeTest: key == PaywallVariant.fifth.rawValue
        )
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
        case .fifth:
            return rc["paywall5_enabled"].boolValue
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
        case .v10:
            return .fifth
        default:
            return .fourth
        }
    }

//    func onboardingPaywallVariant(for tag: OnboardTag) -> PaywallVariant {
//        // 0) форс з RC — як і було, має абсолютний пріоритет
//        let forceKey = rc["paywall_force"].stringValue
//        if !forceKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
//           let forced = parseForcedVariant(forceKey) {
//            return forced
//        }
//
//        let primary  = primaryOnboardingVariant(for: tag)
//        let fallback: PaywallVariant = (primary == .third ? .fourth : .third)
//
//        let primaryEnabled  = isEnabled(primary)
//        let fallbackEnabled = isEnabled(fallback)
//
//        switch (primaryEnabled, fallbackEnabled) {
//        case (true, false):
//            // увімкнений тільки primary → показуємо його
//            return primary
//
//        case (false, true):
//            // увімкнений тільки fallback → показуємо його
//            return fallback
//
//        case (false, false):
//            // обидва вимкнені → безпечний фолбек (щоб не впасти)
//            return primary
//
//        case (true, true):
//            // ⬅️ коли ОБИДВА true робимо стабільний “рандом” 50/50
//            let seed = stableUserID() + "|\(tag.rawValue)|paywallAB"
//            let bucket = abs(seed.hashValue) % 2
//            return (bucket == 0) ? primary : fallback
//        }
//    }

    func onboardingPaywallVariant(for tag: OnboardTag) -> PaywallVariant {
        // 0) RC force
        let forceKey = rc["paywall_force"].stringValue
        if !forceKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
           let forced = parseForcedVariant(forceKey) {
            return forced
        }

        // ✅ 1) якщо увімкнений лише 1 пейвол — він для всіх онбордів
        let enabled = enabledPaywalls()
        if enabled.count == 1 { return enabled[0] }

        let primary = primaryOnboardingVariant(for: tag)

        // якщо раптом всі вимкнені
        guard !enabled.isEmpty else { return primary }

        // fallback = перший увімкнений, який не primary
        let fallback = enabled.first(where: { $0 != primary }) ?? primary

        let primaryEnabled = enabled.contains(primary)
        let fallbackEnabled = enabled.contains(fallback)

        switch (primaryEnabled, fallbackEnabled) {
        case (true, false): return primary
        case (false, true): return fallback
        case (false, false):
            return enabled[0] // ✅ не повертаємо primary, якщо він вимкнений
        case (true, true):
            // стабільний вибір (див. пункт про hashValue нижче)
            let seed = stableUserID() + "|\(tag.rawValue)|paywallAB"
            let bucket = abs(seed.hashValue) % 2

            return (bucket == 0) ? primary : fallback
        }
    }


    func onboardingPaywallView(
        for tag: OnboardTag,
        onFinish: @escaping () -> Void,
        startDelay: Double,
        stepsVisited: [String]?,
        onboardIdOverride: String? = nil
    ) -> AnyView {
        let variant = onboardingPaywallVariant(for: tag)
        let onboardId = onboardIdOverride ?? tag.rawValue

        switch variant {
        case .third:
            return AnyView(
                PaywallThirdView(
                    onFinish: onFinish,
                    onboardId: onboardId,
                    startDelay: startDelay,
                    summaryTag: tag,
                    stepsVisited: stepsVisited
                )
            )

        case .fourth:
            return AnyView(
                PaywallFourView(
                    onFinish: onFinish,
                    onboardId: onboardId,
                    startDelay: startDelay,
                    summaryTag: tag,
                    stepsVisited: stepsVisited
                )
            )

        case .fifth:
            return AnyView(
                PaywallFiveView(
                    onFinish: onFinish,
                    onboardId: onboardId,
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
        case "FIFTH", "PAYWALL5":  return .fifth
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
        case .fifth:
            return  AnyView(
                PaywallFiveView(onFinish: onFinish)
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
                Text(LocalizedStringKey(title))
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
