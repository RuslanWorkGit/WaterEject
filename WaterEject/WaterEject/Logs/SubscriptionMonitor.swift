//
//  SubscriptionMonitor.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 31.10.2025.
//

import Foundation
import RevenueCat

enum RCPriceCache {
    static func save(entitlementID: String, price: Double, currency: String) {
        UserDefaults.standard.set(price,    forKey: "rc_last_price_\(entitlementID)")
        UserDefaults.standard.set(currency, forKey: "rc_last_curr_\(entitlementID)")
    }
    static func read(entitlementID: String) -> (price: Double, currency: String)? {
        let p = UserDefaults.standard.double(forKey: "rc_last_price_\(entitlementID)")
        let c = UserDefaults.standard.string(forKey: "rc_last_curr_\(entitlementID)")
        if p > 0, let c { return (p, c) }
        return nil
    }
}

private extension SubscriptionMonitor {
    func afPayload(revenue: Double?, currency: String?, productId: String? = nil) -> [String: Any] {
        var d: [String: Any] = [
            "af_content_id": entitlementID,
            "af_currency": currency ?? "USD"
        ]
        if let productId, !productId.isEmpty {
            let plan = resolvePlan(from: productId)
            d["product_id"] = productId
            d["plan"] = plan
            d["subscription_type"] = plan
        }
        d["af_revenue"] = revenue ?? 0.0
        return d
    }
}

/// Збережений сніпшот, щоб не слати дублікати
private struct SavedState: Codable, Equatable {
    var isActive: Bool
    var willRenew: Bool
    var expirationTs: TimeInterval?      // seconds
    var latestPurchaseTs: TimeInterval?   // seconds
    var billingIssue: Bool
    var unsubscribed: Bool
    var productId: String?
    var periodType: String
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

    private func sendJ2D(_ event: J2DEvent, type: J2DSubscriptionType, plan: String?, date: Date? = nil) {
        Task {
            do {
                try await J2DSubscriptionReporter.shared.sendSubscriptionEvent(
                    platform: .watereject,
                    userId: Purchases.shared.appUserID,
                    event: event,
                    type: type,
                    plan: resolvePlan(from: plan),
                    date: date ?? Date()
                )
            } catch {
                print("❌ J2D state event failed:", event, error)
            }
        }
    }
    
    /// Викликай на лаунчі, при поверненні у фокус, після покупки і коли RC оновлює CustomerInfo
    func process(customerInfo: CustomerInfo) {
        AppNotificationPolicy.updateForSubscription(
            isActive: customerInfo.entitlements[entitlementID]?.isActive == true
        )

        guard let ent = customerInfo.entitlements[entitlementID] else { return }
        
        let isSubscriptionProduct = (ent.expirationDate != nil)

        let new = SavedState(
            isActive: ent.isActive,
            willRenew: ent.willRenew,
            expirationTs: ent.expirationDate?.timeIntervalSince1970,
            latestPurchaseTs: ent.latestPurchaseDate?.timeIntervalSince1970,
            billingIssue: ent.billingIssueDetectedAt != nil,
            unsubscribed: ent.unsubscribeDetectedAt != nil,
            productId: ent.productIdentifier,
            periodType: String(describing: ent.afSubscriptionPeriodKind)
        )
        let old = load()

        // ---- Виявлення подій ----

        // 1) Скасування авто-пролонгації (user turned off renewal)
        if isSubscriptionProduct, new.unsubscribed, old?.unsubscribed == false || (old == nil && new.unsubscribed) {
            let cached = RCPriceCache.read(entitlementID: entitlementID)
            AF.log(.subscription_cancelled, afPayload(revenue: 0.0, currency: cached?.currency, productId: new.productId ?? old?.productId))
            sendJ2D(.unsubscribed, type: .subscription, plan: new.productId ?? old?.productId, date: ent.unsubscribeDetectedAt)
        }


        // 2) Ренювал (новий період почався): коли зросла expiration або з’явилась нова latestPurchase
        let hasRenewalByExpiration =
            old != nil &&
            isSubscriptionProduct &&
            new.isActive &&
            (new.expirationTs ?? 0) > ((old?.expirationTs ?? 0) + 1)

        let hasRenewalByPurchaseDate =
            old != nil &&
            isSubscriptionProduct &&
            new.isActive &&
            (new.latestPurchaseTs ?? 0) > ((old?.latestPurchaseTs ?? 0) + 1)

        if hasRenewalByExpiration || hasRenewalByPurchaseDate {
            let cached = RCPriceCache.read(entitlementID: entitlementID)
            let oldWasTrial = old?.periodType == String(describing: AFSubscriptionPeriodKind.trial)

            AF.log(
                oldWasTrial ? .trial_success : .subscription_renewed,
                afPayload(
                    revenue: cached?.price,
                    currency: cached?.currency,
                    productId: new.productId ?? old?.productId
                )
            )
            sendJ2D(.renewed, type: .subscription, plan: new.productId ?? old?.productId, date: ent.latestPurchaseDate ?? Date())
        }


        // 3) Закінчення (вже не активна, і термін минув)
        if old?.isActive == true,
           new.isActive == false,
           (new.expirationTs ?? 0) < Date().timeIntervalSince1970 {
            let cached = RCPriceCache.read(entitlementID: entitlementID)
            AF.log(.subscription_expired, afPayload(revenue: 0.0, currency: cached?.currency, productId: new.productId ?? old?.productId))
        }

        // 4) Billing issue (помилка білінгу)
        if new.billingIssue, old?.billingIssue == false || (old == nil && new.billingIssue) {
            let cached = RCPriceCache.read(entitlementID: entitlementID)
            AF.log(.billing_issue_detected, afPayload(revenue: 0.0, currency: cached?.currency, productId: new.productId ?? old?.productId))
        }

        // Зберегти новий стан
        save(new)
    }
    
    private func resolvePlan(from productId: String?) -> String {
        guard let id = productId else { return "unknown" }
        if id == NewPaywallPlan.weekly.productID   { return NewPaywallPlan.weekly.rawValue }
        if id == NewPaywallPlan.yearly.productID   { return NewPaywallPlan.yearly.rawValue }
        if id == NewPaywallPlan.annual.productID   { return NewPaywallPlan.annual.rawValue }
        return id // fallback: якщо раптом інший продукт
    }
}
