//
//  Telemetry.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 21.08.2025.

import Foundation
import FirebaseAnalytics
import RevenueCat
import StoreKit

/// Єдині імена подій
enum TelemetryEvent: String {
    case paywallExposure   = "paywall_exposure"
    case paywallClose      = "paywall_close"
    case purchaseSuccess   = "purchase_success"
    case purchaseError     = "purchase_error"
    case purchaseCancelled = "purchase_cancelled"
    case restoreSuccess    = "restore_success"
    case restoreError      = "restore_error"
}

/// Обгортка над Firebase Analytics
final class Telemetry {
    static let shared = Telemetry()
    private init() {}

    /// Все, що хочемо підмішувати автоматично у КОЖНУ подію
    private func baseParams() -> [String: Any] {
        [
            "variant": PaywallAB.shared.variant().rawValue // AB-варіант пейволу
        ]
    }

    /// Низькорівневий логер
    func log(_ event: TelemetryEvent, params: [String: Any] = [:]) {
        var merged = baseParams()
        params.forEach { merged[$0.key] = $0.value }
        Analytics.logEvent(event.rawValue, parameters: merged)
    }
}

// MARK: - Спеціалізовані хелпери
extension Telemetry {

    func paywallExposure(source: String? = nil) {
        var p: [String: Any] = [:]
        if let source { p["source"] = source }
        log(.paywallExposure, params: p)
    }

    func paywallClosed(source: String) {
        log(.paywallClose, params: ["source": source])
    }

    func purchaseSuccess(plan: PaywallPlan, product: StoreProduct, transactionId: String?) {
        let price = NSDecimalNumber(decimal: product.price).doubleValue
        log(.purchaseSuccess, params: [
            "plan"          : plan.analyticsValue,
            "product_id"    : product.productIdentifier,
            "price"         : price,                       // numeric
            "currency"      : product.currencyCode ?? "",  // ISO 4217
            "transaction_id": transactionId ?? ""
        ])
    }

    func purchaseError(plan: PaywallPlan?,
                       reason: String? = nil,
                       error: Error? = nil)
    {
        var p: [String: Any] = [:]
        if let plan { p["plan"] = plan.analyticsValue }
        if let reason { p["reason"] = reason }
        if let ns = error as NSError? {
            p["domain"]  = ns.domain
            p["code"]    = ns.code
            p["message"] = ns.localizedDescription
        }
        log(.purchaseError, params: p)
    }

    func purchaseCancelled(plan: PaywallPlan) {
        log(.purchaseCancelled, params: ["plan": plan.analyticsValue])
    }

    func restoreSuccess() {
        log(.restoreSuccess)
    }

    func restoreError(_ error: Error) {
        let ns = error as NSError
        log(.restoreError, params: [
            "domain": ns.domain,
            "code"  : ns.code,
            "message": ns.localizedDescription
        ])
    }
}
