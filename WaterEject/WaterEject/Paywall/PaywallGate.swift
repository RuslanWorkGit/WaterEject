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

enum PaywallContext: String { case startViewAuto, modesTap, startButton, onboarding }

@MainActor
final class PaywallGate: ObservableObject {
    static let shared = PaywallGate()

    // що саме показати (A/B). Використовується для .fullScreenCover
    @Published var presentedVariant: PaywallVariant?   // ваш тип із PaywallVariant.swift

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

    /// Автопоказ (викликати в onAppear)
    func presentPaywallIfNeeded(context: PaywallContext) async {
        guard await shouldShowPaywall(context: context) else { return }
        presentedVariant = assignedVariant()
        shownThisSession = true
        UserDefaults.standard.set(Date(), forKey: lastShownKey)
    }

    /// Форсований показ (коли користувач тисне на pro-фічу)
    func requireProOrPresentPaywall(context: PaywallContext) async -> Bool {
        if await isPro() { return true }
        presentedVariant = assignedVariant()
        shownThisSession = true
        UserDefaults.standard.set(Date(), forKey: lastShownKey)
        return false
    }

    func dismissPaywall() { presentedVariant = nil }
}
