//
//  SubscriptionMonitor.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 31.10.2025.
//

import Foundation
import RevenueCat

/// Збережений сніпшот, щоб не слати дублікати
private struct SavedState: Codable, Equatable {
    var isActive: Bool
    var willRenew: Bool
    var expirationTs: TimeInterval?      // seconds
    var latestPurchaseTs: TimeInterval?   // seconds
    var billingIssue: Bool
    var unsubscribed: Bool
}

final class SubscriptionMonitor {

    static let shared = SubscriptionMonitor(entitlementID: "pro_user")

    private let entitlementID: String
    private let storageKey = "rc_saved_state_v1"

    private init(entitlementID: String) {
        self.entitlementID = entitlementID
    }

    // Зчитати/зберегти попередній стан
    private func load() -> SavedState? {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return nil }
        return try? JSONDecoder().decode(SavedState.self, from: data)
    }

    private func save(_ s: SavedState) {
        if let data = try? JSONEncoder().encode(s) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    /// Викликай на лаунчі, при поверненні у фокус, після покупки і коли RC оновлює CustomerInfo
    func process(customerInfo: CustomerInfo) {
        guard let ent = customerInfo.entitlements[entitlementID] else { return }

        let new = SavedState(
            isActive: ent.isActive,
            willRenew: ent.willRenew,
            expirationTs: ent.expirationDate?.timeIntervalSince1970,
            latestPurchaseTs: ent.latestPurchaseDate?.timeIntervalSince1970,
            billingIssue: ent.billingIssueDetectedAt != nil,
            unsubscribed: ent.unsubscribeDetectedAt != nil
        )
        let old = load()

        // ---- Виявлення подій ----

        // 1) Скасування авто-пролонгації (user turned off renewal)
        if new.unsubscribed, old?.unsubscribed == false || (old == nil && new.unsubscribed) {
            AF.log(.subscription_cancelled, [
                "af_content_id": entitlementID
            ])
        }

        // 2) Ренювал (новий період почався): коли зросла expiration або з’явилась нова latestPurchase
        if let newExp = new.expirationTs,
           let oldExp = old?.expirationTs,
           new.isActive,            // підписка активна
           newExp > oldExp + 1 {    // +1 сек — антидребезг
            AF.log(.subscription_renewed, [
                "af_content_id": entitlementID
            ])
        } else if let newLP = new.latestPurchaseTs,
                  let oldLP = old?.latestPurchaseTs,
                  new.isActive,
                  newLP > oldLP + 1 {
            AF.log(.subscription_renewed, [
                "af_content_id": entitlementID
            ])
        }

        // 3) Закінчення (вже не активна, і термін минув)
        if old?.isActive == true,
           new.isActive == false,
           (new.expirationTs ?? 0) < Date().timeIntervalSince1970 {
            AF.log(.subscription_expired, [
                "af_content_id": entitlementID
            ])
        }

        // 4) Billing issue (помилка білінгу)
        if new.billingIssue, old?.billingIssue == false || (old == nil && new.billingIssue) {
            AF.log(.billing_issue_detected, [
                "af_content_id": entitlementID
            ])
        }

        // Зберегти новий стан
        save(new)
    }
}
