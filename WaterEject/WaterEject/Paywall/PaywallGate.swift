//
//  PaywallGate.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 14.08.2025.
//

// PaywallGate.swift
import Foundation
import SwiftUI
import RevenueCat

enum PaywallContext: String { case startViewAuto, modesTap, startButton, onboarding, testTab}

@MainActor
final class PaywallGate: ObservableObject {
    static let shared = PaywallGate()

    // що саме показати (A/B). Використовується для .fullScreenCover
    @Published var presentedVariant: PaywallVariant?   // ваш тип із PaywallVariant.swift
    @Published var currentContext: PaywallContext?

    private let entitlementID = "pro_user"
    private let variantKey    = "paywall_variant"      // зберігаємо обраний варіант
    private let lastShownKey  = "paywall_last_shown"
    private let cooldown: TimeInterval = 60 * 30       // напр., не частіше ніж раз на 30 хв
    private var shownThisSession = false

    private init() {
        // Зафіксувати варіант A/B один раз і назавжди
        if UserDefaults.standard.string(forKey: variantKey) == nil {
            let v = PaywallAB.shared.variant()                 // ваш існуючий механізм
            UserDefaults.standard.set(v.rawValue, forKey: variantKey)
            // необов'язково: атрибут у RC для аналітики
            try? Purchases.shared.attribution.setAttributes(["paywall_variant": v.rawValue])
        }
    }

    func assignedVariant() -> PaywallVariant {
        // 0) Якщо юзеру видали один з НОВИХ онбордів (D/E/F/G),
        //    завжди показуємо новий пейвол (.fourth)
        if let rawOnb = UserDefaults.standard.string(forKey: "onboarding_variant_v2"),
           let onbVariant = OnboardingVariant(rawValue: rawOnb) {
            switch onbVariant {
            case .A, .B, .C, .D, .E, .F, .G, .H:
                return .fourth        // ⬅️ тут жорстко форсим PaywallFourView
//            case .A, .B, .C:
//                break                 // для старих онбордів — стара логіка
            }
        }

        // 1) Далі — як було: читаємо paywall_variant із UserDefaults
        if let raw = UserDefaults.standard.string(forKey: variantKey),
           let v = PaywallVariant(rawValue: raw) {
            return v
        } else {
            let v = PaywallAB.shared.variant()
            UserDefaults.standard.set(v.rawValue, forKey: variantKey)
            return v
        }
    }

    func isPro() async -> Bool {
        do {
            let info = try await Purchases.shared.customerInfo()
            return info.entitlements[entitlementID]?.isActive == true
        } catch {
            return false
        }
    }

    // Проста логіка: показувати, якщо не Pro і не порушуємо кулдаун/one-per-session
    func shouldShowPaywall(context: PaywallContext) async -> Bool {
        if await isPro() { return false }
        if shownThisSession { return false }
        let last = (UserDefaults.standard.object(forKey: lastShownKey) as? Date) ?? .distantPast
        if Date().timeIntervalSince(last) < cooldown { return false }
        return true
    }

    func dismissPaywall() { presentedVariant = nil }
    
    func presentPaywallIfNeeded(context: PaywallContext) async {
        guard await shouldShowPaywall(context: context) else { return }
        currentContext = context
        presentedVariant = assignedVariant()
        shownThisSession = true
        UserDefaults.standard.set(Date(), forKey: lastShownKey)
    }

    func requireProOrPresentPaywall(context: PaywallContext) async -> Bool {
        if await isPro() { return true }
        currentContext = context
        presentedVariant = assignedVariant()
        shownThisSession = true
        UserDefaults.standard.set(Date(), forKey: lastShownKey)
        return false
    }
}
