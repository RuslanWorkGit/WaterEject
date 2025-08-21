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
    
    case purchaseStart     = "purchase_start"
    case purchaseSuccess   = "purchase_success"
    case purchaseError     = "purchase_error"
    case purchaseCancelled = "purchase_cancelled"
    
    case restoreStart      = "restore_start"
    case restoreSuccess    = "restore_success"
    case restoreError      = "restore_error"
    
    case homeExposure      = "home_exposure"
    case homeDeviceTap     = "home_device_tap"
    case homeNavigateModes = "home_navigate_modes"
    
    case modesExposure        = "modes_exposure"
    case modesModeTap         = "modes_mode_tap"
    case modesStartNavigate   = "modes_start_navigate"
    case modesPaywallRequested = "modes_paywall_requested"
    case modesPaywallDismissed = "modes_paywall_dismissed"
    case modesBackTap         = "modes_back_tap"
}

enum PaywallCloseSource: String {
    case closeButton   = "close_button"
    case systemDismiss = "system_dismiss"
    case backSwipe     = "back_swipe"
}

/// Обгортка над Firebase Analytics
final class Telemetry {
    static let shared = Telemetry()
    private init() {}
    
    /// Все, що підмішуємо у кожну подію (напр., AB-варіант)
    private func baseParams() -> [String: Any] {
        ["variant": PaywallAB.shared.variant().rawValue]
    }
    
    /// Низькорівневий логер
    func log(_ event: TelemetryEvent, params: [String: Any] = [:]) {
        var merged = baseParams()
        params.forEach { merged[$0.key] = $0.value }
        Analytics.logEvent(event.rawValue, parameters: merged)
    }
}


// MARK: - Спеціалізовані хелпери
// MARK: - Спеціалізовані хелпери
extension Telemetry {
    
    // PAYWALL
    func paywallExposure(source: String? = nil) {
        var p: [String: Any] = [:]
        if let source { p["source"] = source }
        log(.paywallExposure, params: p)
    }
    
    func paywallClosed(source: PaywallCloseSource) {
        log(.paywallClose, params: ["source": source.rawValue])
    }
    
    // PURCHASE
    func purchaseStart(plan: PaywallPlan) {
        log(.purchaseStart, params: ["plan": plan.analyticsValue])
    }
    
    func purchaseSuccess(plan: PaywallPlan,
                         product: StoreProduct,
                         transactionId: String?)
    {
        let price = NSDecimalNumber(decimal: product.price).doubleValue
        log(.purchaseSuccess, params: [
            "plan"          : plan.analyticsValue,
            "product_id"    : product.productIdentifier,
            "price"         : price,                          // numeric
            "currency"      : product.currencyCode ?? "",     // ISO 4217
            "transaction_id": transactionId ?? ""
        ])
    }
    
    func purchaseError(plan: PaywallPlan?,
                       reason: String? = nil,
                       error: Error? = nil)
    {
        var p: [String: Any] = [:]
        if let plan   { p["plan"]   = plan.analyticsValue }
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
    
    // RESTORE
    func restoreStart() {
        log(.restoreStart)
    }
    
    func restoreSuccess(entitlementActive: Bool) {
        log(.restoreSuccess, params: ["entitlement_active": entitlementActive])
    }
    
    func restoreError(_ error: Error) {
        let ns = error as NSError
        log(.restoreError, params: [
            "domain": ns.domain,
            "code"  : ns.code,
            "message": ns.localizedDescription
        ])
    }
    
    
    func homeExposure() {
        log(.homeExposure)
    }
    
    func homeDeviceTap(device: CleaningDevice) {
        log(.homeDeviceTap, params: ["device": device.analyticsValue])
    }
    
    func homeNavigateToModes(device: CleaningDevice) {
        log(.homeNavigateModes, params: ["device": device.analyticsValue])
    }
    
    
    func modesExposure(device: CleaningDevice) {
            log(.modesExposure, params: ["device": device.analyticsValue])
        }

        func modesModeTap(device: CleaningDevice, mode: CleaningMode) {
            log(.modesModeTap, params: [
                "device": device.analyticsValue,
                "mode"  : mode.analyticsValue
            ])
        }

        func modesStartNavigate(device: CleaningDevice, mode: CleaningMode) {
            log(.modesStartNavigate, params: [
                "device": device.analyticsValue,
                "mode"  : mode.analyticsValue
            ])
        }

        func modesPaywallRequested(device: CleaningDevice, mode: CleaningMode) {
            log(.modesPaywallRequested, params: [
                "device": device.analyticsValue,
                "mode"  : mode.analyticsValue
            ])
        }

        /// converted = true, якщо після закриття пейволу у юзера з’явився Entitlement
        func modesPaywallDismissed(device: CleaningDevice, mode: CleaningMode, converted: Bool) {
            log(.modesPaywallDismissed, params: [
                "device": device.analyticsValue,
                "mode"  : mode.analyticsValue,
                "converted": converted
            ])
        }

        func modesBackTap(device: CleaningDevice) {
            log(.modesBackTap, params: ["device": device.analyticsValue])
        }
}
