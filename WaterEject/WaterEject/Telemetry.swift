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
    case settimgExpose     = "setting_exposure"
    
    case modesExposure        = "modes_exposure"
    case modesModeTap         = "modes_mode_tap"
    case modesStartNavigate   = "modes_start_navigate"
    case modesPaywallRequested = "modes_paywall_requested"
    case modesPaywallDismissed = "modes_paywall_dismissed"
    case modesBackTap         = "modes_back_tap"
    
    
    case startExposure          = "start_exposure"
    case startBackTap           = "start_back_tap"
    case startPrimaryTap        = "start_primary_tap"      // натиск на “Start cleaning”
    case startPromptShown       = "start_prompt_shown"     // показали Alert про гучність
    case startPromptConfirm     = "start_prompt_confirm"   // OK в Alert
    case startPromptCancel      = "start_prompt_cancel"    // Cancel в Alert
    case startCleaningBegin     = "start_cleaning_begin"
    case startCleaningEnd       = "start_cleaning_end"     // reason: finished/cancelled/back
    case startTimerStart        = "start_timer_start"
    case startTimerEnd          = "start_timer_end"
    
    // Пейвол з цього екрана
    case startPaywallRequested  = "start_paywall_requested"
    case startPaywallDismissed  = "start_paywall_dismissed"
    
    case onboardingStart     = "onboarding_start"
    case onboardingExposure  = "onboarding_exposure"
    case onboardingContinue  = "onboarding_continue"
    case onboardingFinish    = "onboarding_finish"
    case onboardingStepChange = "onboarding_step_change"
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
//    func purchaseStart(plan: PaywallPlan) {
//        log(.purchaseStart, params: ["plan": plan.analyticsValue])
//    }
    
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
    
    func settingExposure() {
        log(.settimgExpose)
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
    
    func startExposure(device: CleaningDevice, mode: CleaningMode) {
        log(.startExposure, params: [
            "device": device.analyticsValue,
            "mode"  : mode.analyticsValue
        ])
    }
    
    func startBackTap(device: CleaningDevice, mode: CleaningMode, disabled: Bool) {
        log(.startBackTap, params: [
            "device": device.analyticsValue,
            "mode"  : mode.analyticsValue,
            "disabled": disabled
        ])
    }
    
    func startPrimaryTap(device: CleaningDevice, mode: CleaningMode) {
        log(.startPrimaryTap, params: [
            "device": device.analyticsValue,
            "mode"  : mode.analyticsValue
        ])
    }
    
    func startPromptShown(device: CleaningDevice, mode: CleaningMode) {
        log(.startPromptShown, params: [
            "device": device.analyticsValue,
            "mode"  : mode.analyticsValue
        ])
    }
    
    func startPromptConfirm(device: CleaningDevice, mode: CleaningMode) {
        log(.startPromptConfirm, params: [
            "device": device.analyticsValue,
            "mode"  : mode.analyticsValue
        ])
    }
    
    func startPromptCancel(device: CleaningDevice, mode: CleaningMode) {
        log(.startPromptCancel, params: [
            "device": device.analyticsValue,
            "mode"  : mode.analyticsValue
        ])
    }
    
    func startCleaningBegin(device: CleaningDevice, mode: CleaningMode, duration: Int) {
        log(.startCleaningBegin, params: [
            "device": device.analyticsValue,
            "mode"  : mode.analyticsValue,
            "duration_sec": duration
        ])
    }
    
    /// reason: finished / cancelled / back
    func startCleaningEnd(device: CleaningDevice, mode: CleaningMode, reason: String) {
        log(.startCleaningEnd, params: [
            "device": device.analyticsValue,
            "mode"  : mode.analyticsValue,
            "reason": reason
        ])
    }
    
    func startTimerStart(device: CleaningDevice, mode: CleaningMode, duration: Int) {
        log(.startTimerStart, params: [
            "device": device.analyticsValue,
            "mode"  : mode.analyticsValue,
            "duration_sec": duration
        ])
    }
    
    func startTimerEnd(device: CleaningDevice, mode: CleaningMode) {
        log(.startTimerEnd, params: [
            "device": device.analyticsValue,
            "mode"  : mode.analyticsValue
        ])
    }
    
    func startPaywallRequested(auto: Bool) {
        log(.startPaywallRequested, params: ["auto": auto])
    }
    
    func startPaywallDismissed(converted: Bool) {
        log(.startPaywallDismissed, params: ["converted": converted])
    }
    

}


extension Telemetry {
    //MARK: - Onboarding
    func onboardingStart(flow: String = "default") {
            var p = baseParams(); p["onboarding_flow"] = flow
            Analytics.logEvent("onboarding_start", parameters: p)
        }

    func onboardingExposure(step: OnboardingStep, flow: String = "default") {
        logOnboarding(action: "screen", extra: [
            "onboarding_step": stepName(step),
            "onboarding_flow": flow
        ])
    }

    func onboardingContinue(step: OnboardingStep, flow: String = "default") {
            var p = baseParams()
            p["onboarding_step"] = stepName(step)
            p["onboarding_flow"] = flow
            Analytics.logEvent("onboarding_continue", parameters: p)
        }

    func onboardingFinish(flow: String = "default") {
            var p = baseParams(); p["onboarding_flow"] = flow
            Analytics.logEvent("onboarding_finish", parameters: p)
        }
    
    
    /// Лог події з довільною назвою (для screen-маркерів)
    func onboardingStepChange(from: OnboardingStep, to: OnboardingStep, flow: String = "default") {
            var p = baseParams()
            p["onboarding_from_step"] = stepName(from)
            p["onboarding_to_step"]   = stepName(to)
            p["onboarding_flow"]      = flow
            Analytics.logEvent("onboarding_step_change", parameters: p)
        }
    
    func onboardingScreenMarker(step: OnboardingStep, flow: String = "default") {
            // 1) новий єдиний івент
            var p = baseParams()
            p["onboarding_action"] = "screen"
            p["onboarding_step"]   = stepName(step)
            p["onboarding_flow"]   = flow
            Analytics.logEvent("onboarding", parameters: p)

            // 2) legacy-івент для старих звітів
            Analytics.logEvent(onboardingRawEventName(step), parameters: baseParams())
        }

    /// Мапимо крок онбордингу у потрібну назву події
    private func onboardingRawEventName(_ step: OnboardingStep) -> String {
        switch step {
        case .hook:     return "onboarding_step_1"
        case .urgency:  return "onboarding_step_2"
        case .solution: return "onboarding_step_3"
        case .paywall:  return "paywall"
        }
    }
    
    private func logOnboarding(action: String, extra: [String: Any] = [:]) {
        var params = baseParams()                // якщо у тебе є базові параметри — лишаємо
        params["onboarding_action"] = action     // start | screen | step_change | continue_tap | finish
        extra.forEach { params[$0.key] = $0.value }
        Analytics.logEvent("onboarding", parameters: params)
    }
    
    private func stepName(_ s: OnboardingStep) -> String {
        switch s {
        case .hook:     return "hook"
        case .urgency:  return "urgency"
        case .solution: return "solution"
        case .paywall:  return "paywall"
        }
    }
}


extension Telemetry {
    
    /// Лог події з довільною назвою (для screen-маркерів) func logRaw(_ name: String, params: [String: Any] = [:]) { var merged = baseParams() params.forEach { merged[$0.key] = $0.value } Analytics.logEvent(name, parameters: merged) }
     func logRaw(_ name: String, params: [String: Any] = [:]) {
         var merged = baseParams()
         params.forEach {
             merged[$0.key] = $0.value
         }
         Analytics.logEvent(name, parameters: merged)
     }
    // Одноразовий маркер старту тестів
    func testStart() {
        logRaw("Test_Start")
    }

    // Маркер відкриття конкретного екрану тесту
    func testScreenOpen(_ mode: TestMode) {
        logRaw(testEventName(for: mode))
    }

    private func testEventName(for mode: TestMode) -> String {
        switch mode {
        case .stereo: return "Test_StereoView"
        case .bass:   return "Test_BassView"
        case .micro:  return "Test_MicroView"
        case .vibro:  return "Test_VibroView"
        }
    }
}

extension Telemetry {
    func paywallAOpen() { logRaw("Paywall_A_Open") }
    func paywallBOpen() { logRaw("Paywall_B_Open") }
}

extension Telemetry {
    func paywallClose(variant: String, entryPoint: String, reason: String, sessionId: String) {
        logRaw("Paywall_Close", params: [
            "variant": variant, "entry_point": entryPoint,
            "reason": reason, "paywall_session_id": sessionId
        ])
    }
    func purchaseStart(variant: String, packageId: String, offeringId: String?,
                       price: Double?, currency: String?, sessionId: String) {
        logRaw("Purchase_Start", params: [
            "variant": variant, "package_id": packageId, "offering_id": offeringId ?? "na",
            "price_shown": price ?? 0, "paywall_currency": currency ?? "NA", "paywall_session_id": sessionId
        ])
    }
    func purchaseResult(variant: String, status: String, rcCode: Int?, packageId: String,
                        pricePaid: Double?, currency: String?, sessionId: String) {
        logRaw("Purchase_Result", params: [
            "variant": variant, "status": status, "rc_code": rcCode ?? -1,
            "package_id": packageId, "price_paid": pricePaid ?? 0,
            "currency": currency ?? "NA", "paywall_session_id": sessionId
        ])
        if status == "success", let value = pricePaid, let cur = currency {
            // стандартний GA4 purchase (дає revenue-метрики)
            Analytics.logEvent("purchase", parameters: ["value": value, "currency": cur])
        }
    }
}

extension Telemetry {
    func paywallPurchaseSuccess(variant: String,
                                entryPoint: String,
                                packageId: String,
                                price: Double?,            // показана/сплачена ціна
                                currency: String?,         // ISO 4217
                                transactionId: String?,    // якщо є
                                sessionId: String) {
        logRaw("Paywall_Purchase_Success", params: [
            "variant": variant,
            "entry_point": entryPoint,
            "package_id": packageId,
            "price_paid": price ?? 0,
            "currency": currency ?? "NA",
            "transaction_id": transactionId ?? "",
            "paywall_session_id": sessionId
        ])
    }

    func paywallPurchaseError(variant: String,
                              entryPoint: String,
                              packageId: String,
                              rcCode: Int?,
                              message: String?,
                              sessionId: String) {
        logRaw("Paywall_Purchase_Error", params: [
            "variant": variant,
            "entry_point": entryPoint,
            "package_id": packageId,
            "rc_code": rcCode ?? -1,
            "message": message ?? "",
            "paywall_session_id": sessionId
        ])
    }
}
