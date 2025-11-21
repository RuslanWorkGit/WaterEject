//
//  Telemetry.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 21.08.2025.

import Foundation
import FirebaseAnalytics
import RevenueCat
import StoreKit

enum PaywallStatus: String { case success, error, close, abandon }

/// Єдині імена подій
enum TelemetryEvent: String {
    case paywallExposure   = "paywall_exposure"
    case paywallClose      = "paywallClose"
    
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
    
    case modesPaywall = "modes_paywall"
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
        Analytics.logEvent("onboarding_start_1.2", parameters: p)
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
        Analytics.logEvent("onboarding_continue_1.2", parameters: p)
    }
    
    func onboardingFinish(flow: String = "default") {
        var p = baseParams(); p["onboarding_flow"] = flow
        Analytics.logEvent("onboarding_finish_1.2", parameters: p)
    }
    
    
    /// Лог події з довільною назвою (для screen-маркерів)
    func onboardingStepChange(from: OnboardingStep, to: OnboardingStep, flow: String = "default") {
        var p = baseParams()
        p["onboarding_from_step"] = stepName(from)
        p["onboarding_to_step"]   = stepName(to)
        p["onboarding_flow"]      = flow
        Analytics.logEvent("onboarding_step_change_1.2", parameters: p)
    }
    
    func onboardingScreenMarker(step: OnboardingStep, flow: String = "default") {
        // 1) новий єдиний івент
        var p = baseParams()
        p["onboarding_action"] = "screen"
        p["onboarding_step"]   = stepName(step)
        p["onboarding_flow"]   = flow
        Analytics.logEvent("onboarding_1.2", parameters: p)
        
        // 2) legacy-івент для старих звітів
        Analytics.logEvent(onboardingRawEventName(step), parameters: baseParams())
    }
    
    /// Мапимо крок онбордингу у потрібну назву події
    private func onboardingRawEventName(_ step: OnboardingStep) -> String {
        switch step {
        case .hook:     return "onboarding_step_1"
        case .urgency:  return "onboarding_step_2"
        case .solution: return "onboarding_step_3"
        case .tests:    return "onboarding_step_4"
        case .paywall:  return "paywall"
        }
    }
    
    private func logOnboarding(action: String, extra: [String: Any] = [:]) {
        var params = baseParams()                // якщо у тебе є базові параметри — лишаємо
        params["onboarding_action"] = action     // start | screen | step_change | continue_tap | finish
        extra.forEach { params[$0.key] = $0.value }
        Analytics.logEvent("onboarding_1.2", parameters: params)
    }
    
    private func stepName(_ s: OnboardingStep) -> String {
        switch s {
        case .hook:     return "hook"
        case .urgency:  return "urgency"
        case .solution: return "solution"
        case .tests:    return "tests"
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
                        pricePaid: Double?, currency: String?, sessionId: String, onboardId: String?, paywallId: String) {
        
        var p = baseParams()
        p["variant"] = variant
        p["status"] = status
        p["rc_code"] = rcCode ?? -1
        p["package_id"] = packageId
        p["price_paid"] = pricePaid ?? 0
        p["currency"] = currency ?? "NA"
        p["paywall_session_id"] = sessionId
        if let onboardId { p["onboard_id"] = onboardId }  // зв’язок з онбордом
        p["paywall_id"] = paywallId                       // явна версія пейвола (3.0)
        
        logRaw("Purchase_Result", params: p)
        if status == "success", let v = pricePaid, let cur = currency {
            Analytics.logEvent("purchase", parameters: ["value": v, "currency": cur]) // revenue
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


// Telemetry.swift

import FirebaseAnalytics

extension Telemetry {
    // MARK: - Helpers
    private func base(_ extra: [String: Any]) -> [String: Any] {
        var p = baseParams()
        extra.forEach { p[$0.key] = $0.value }
        return p
    }
    
    // MARK: - Onboarding (flow-centric)
    func onbFlowStart(flowId: String) {
        Analytics.logEvent("onb_flow_start", parameters: base(["flow_id": flowId]))
    }
    
    func onbScreenView(flowId: String, screenId: String) {
        Analytics.logEvent("\(flowId)", parameters: base([
            "flow_id": flowId,
            "screen_id": screenId
        ]))
    }
    
    func logOnboardChoice(flowId: String, choiceInfo: String, choiceName: String) {
        Analytics.logEvent("\(flowId)", parameters: base([
            "flow_id": flowId,
            choiceName: choiceInfo
        ]))
    }
    
    func onbFlowFinish(flowId: String) {
        Analytics.logEvent("onb_flow_finish", parameters: base(["flow_id": flowId]))
    }
    
    // MARK: - Paywall
    func paywallExposure(flowId: String?, variant: String, entryPoint: String) {
        Analytics.logEvent("paywall_exposure", parameters: base([
            "flow_id": flowId ?? "unknown",
            "paywall_variant": variant,
            "entry_point": entryPoint
        ]))
    }
    
    func paywallCTATap(flowId: String?, variant: String, entryPoint: String, plan: String) {
        Analytics.logEvent("paywall_cta_tap", parameters: base([
            "flow_id": flowId ?? "unknown",
            "paywall_variant": variant,
            "entry_point": entryPoint,
            "plan": plan
        ]))
    }
    
    func purchaseSuccess(flowId: String?, variant: String, plan: String, packageId: String, sessionId: String) {
        Analytics.logEvent("purchase_success", parameters: base([
            "flow_id": flowId ?? "unknown",
            "paywall_variant": variant,
            "plan": plan,
            "package_id": packageId,
            "paywall_session_id": sessionId
        ]))
    }
    
    func purchaseError(flowId: String?, variant: String, plan: String, packageId: String, rcCode: Int?, message: String?, sessionId: String) {
        Analytics.logEvent("purchase_error", parameters: base([
            "flow_id": flowId ?? "unknown",
            "paywall_variant": variant,
            "plan": plan,
            "package_id": packageId,
            "rc_code": rcCode ?? -1,
            "message": message ?? "",
            "paywall_session_id": sessionId
        ]))
    }
}


// Telemetry.swift

enum OnboardTag: String, Codable {
    case v31 = "Onboard_3_1"
    case v32 = "Onboard_3_2"
    case v33 = "Onboard_3_3"
    case v41 = "Onboard_4_1"
    case v5 = "Onboard_5"
    case v6 = "Onboard_6"
    case v7 = "Onboard_7"
    case v8 = "Onboard_8"
    case modes = "Modes"
}

extension Telemetry {
    
//    // 1) Єдиний лог для конкретного онборд-флоу
//    func onboardFlowMark(_ tag: OnboardTag) {
//        var p = baseParams()
//        p["onboard_id"] = tag.rawValue            // щоб легко джойнити у воронці
//        Analytics.logEvent(tag.rawValue, parameters: p) // ІМ’Я ПОДІЇ = Onboard_3.x
//        Analytics.setUserProperty(tag.rawValue, forName: "onboard_last") // опційно
//    }
    
    // 2) Пейвол: експожер
    func paywallExposure(variant: String, entryPoint: String, onboardId: String?) {
        var p = baseParams()
        p["variant"] = variant
        p["entry_point"] = entryPoint
        if let onboardId { p["onboard_id"] = onboardId }
        Analytics.logEvent("paywall_exposure", parameters: p)
    }
    
    // 3) Пейвол: тап по CTA
    func paywallCTATap(variant: String, entryPoint: String, plan: String, onboardId: String?) {
        var p = baseParams()
        p["variant"] = variant
        p["entry_point"] = entryPoint
        p["plan"] = plan
        if let onboardId { p["onboard_id"] = onboardId }
        Analytics.logEvent("paywall_cta_tap", parameters: p)
    }
    
    // 4) Покупка: успіх
    func purchaseSuccess(variant: String,
                         plan: String,
                         packageId: String,
                         sessionId: String,
                         onboardId: String?) {
        var p = baseParams()
        p["variant"] = variant
        p["plan"] = plan
        p["package_id"] = packageId
        p["paywall_session_id"] = sessionId
        if let onboardId { p["onboard_id"] = onboardId }
        Analytics.logEvent("purchase_success", parameters: p)
    }
    
    // 5) Покупка: помилка
    func purchaseError(variant: String,
                       plan: String,
                       packageId: String,
                       rcCode: Int?,
                       message: String?,
                       sessionId: String,
                       onboardId: String?) {
        var p = baseParams()
        p["variant"] = variant
        p["plan"] = plan
        p["package_id"] = packageId
        p["rc_code"] = rcCode ?? -1
        p["message"] = message ?? ""
        p["paywall_session_id"] = sessionId
        if let onboardId { p["onboard_id"] = onboardId }
        Analytics.logEvent("purchase_error", parameters: p)
    }
}


//extension OnboardTag {
//    /// Ім’я події, яке просив керівник: Onbord_v_3.x
//    var summaryEventName: String {
//        switch self {
//        case .v31: return "Onboard_v_3_1"
//        case .v32: return "Onboard_v_3_2"
//        case .v33: return "Onboard_v_3_3"
//        }
//    }
//}

//extension Telemetry {
//    /// Єдиний “зведений” лог по онборду:
//    /// - steps: імена екранів у порядку проходження (через “|”)
//    /// - paywallId: напр., "paywall_v_3.0"
//    /// - status: success / error / close
//    func onbFlowSummary(onboard tag: OnboardTag,
//                        steps: [String],
//                        paywallId: String,
//                        plan: String?,
//                        status: PaywallStatus,
//                        variant: String? = nil,
//                        entryPoint: String? = nil,
//                        reason: String? = nil)
//    {
//        var p: [String: Any] = base(["steps": steps.joined(separator: "|"),
//                                     "paywall_id": paywallId,
//                                     "status": status.rawValue,
//                                     "onboard_id": tag.rawValue]) // ← ви вже це використовуєте :contentReference[oaicite:0]{index=0}
//        if let variant { p["variant"] = variant }
//        if let entryPoint { p["entry_point"] = entryPoint }
//        if let reason { p["reason"] = reason }
//        if status == .success, let plan {
//            p["plan"] = plan
//        }
//        
//        Analytics.logEvent(tag.summaryEventName, parameters: p)
//
//    }
//}
//extension Telemetry {
//    func onbFlowSummary(onboard tag: OnboardTag,
//                        steps: [String],
//                        paywallId: String,
//                        plan: String?,
//                        status: PaywallStatus,
//                        variant: String? = nil,
//                        entryPoint: String? = nil,
//                        reason: String? = nil)
//    {
//        // Базові параметри
//        var p: [String: Any] = base([
//            "paywall_id": paywallId,
//            "status": status.rawValue,
//            "onboard_id": tag.rawValue
//        ])
//        if let variant { p["variant"] = variant }
//        if let entryPoint { p["entry_point"] = entryPoint }
//        if let reason { p["reason"] = reason }
//
//        // Розкладаємо кроки
//        let cap = 12                         // захист від ліміту параметрів у GA4
//        let limited = Array(steps.prefix(cap))
//        for (idx, name) in limited.enumerated() {
//            p["step_\(idx + 1)"] = name
//        }
//        p["steps_count"] = steps.count
//
//        // Прапорці відвіданих кроків
//        let unique = Set(steps)
//        for raw in unique {
//            let safe = raw.replacingOccurrences(of: "[^a-zA-Z0-9_]",
//                                                with: "_",
//                                                options: .regularExpression)
//            p["visited_\(safe)"] = 1
//        }
//
//        // Legacy-рядок — залишимо для зворотної сумісності (опційно)
//        p["steps"] = steps.joined(separator: "|")
//
//        // План додаємо лише для успішної покупки
//        if status == .success, let plan {
//            p["plan"] = plan
//        }
//
//        Analytics.logEvent(tag.summaryEventName, parameters: p)
//    }
//}

//extension Telemetry {
//    func onbFlowSummary(
//        onboard tag: OnboardTag,
//        steps: [String],
//        paywallId: String,
//        plan: String?,
//        status: PaywallStatus,
//        variant: String? = nil,
//        entryPoint: String? = nil,
//        reason: String? = nil
//    ) {
//        // ❶ Спершу — на кожен крок окремий onb_step з параметром "steps"
//        //    Беремо унікальні в порядку появи, щоб не дублювати повернення назад
//        var seen = Set<String>()
//        var orderedUnique: [String] = []
//        for s in steps where !seen.contains(s) { orderedUnique.append(s); seen.insert(s) }
//        
//        var p: [String: Any] = base([
//            "paywall_id": paywallId,
//            "status": status.rawValue,
//            "onboard_id": tag.rawValue,
//            "steps_count": steps.count
//        ])
//
//        for (i, s) in orderedUnique.enumerated() {
//            logOnbStep(
//                onboard: tag,
//                step: s,
//                index: i + 1,
//                total: steps.count,
//                paywallId: paywallId,
//                variant: variant,
//                entryPoint: entryPoint
//            )
//            
//
//        }
//
//        // ❷ Далі — summary-івент без step_1/visited_*
//        
//        if let variant { p["variant"] = variant }
//        if let entryPoint { p["entry_point"] = entryPoint }
//        if let reason { p["reason"] = reason }
//
//        // План — ЛИШЕ при успішній покупці
//        if status == .success, let plan {
//            p["plan"] = plan
//        }
//
//        // Якщо хочеш — лиши рядок для дебагу, але з іншою назвою, щоб не конфліктував з dimension "steps"
//        // p["steps_str"] = steps.joined(separator: "|")
//
//        Analytics.logEvent(tag.summaryEventName, parameters: p)
//    }
//}


//extension Telemetry {
//    func onbFlowSummary(
//        onboard tag: OnboardTag,
//        steps: [String],
//        paywallId: String,
//        plan: String?,
//        status: PaywallStatus,
//        variant: String? = nil,
//        entryPoint: String? = nil,
//        reason: String? = nil
//    ) {
//        // унікальні в порядку появи
//        var seen = Set<String>()
//        let ordered = steps.filter { s in
//            if seen.contains(s) { return false }
//            seen.insert(s); return true
//        }
//
//        // 1) Івенти-«кроки» (та сама назва івенту!)
//        for (i, s) in ordered.enumerated() {
//            var stepParams = base([
//                "onboard_id": tag.rawValue,
//                "paywall_id": paywallId,
//                "event_role": "step",   // ← щоб фільтрувати
//                "steps": s,             // ← ЄДИНИЙ custom dimension
//                "step_index": i + 1,
//                "steps_count": steps.count
//            ])
//            if let variant { stepParams["variant"] = variant }
//            if let entryPoint { stepParams["entry_point"] = entryPoint }
//            Analytics.logEvent(tag.summaryEventName, parameters: stepParams)
//        }
//
//        // 2) Підсумковий івент (план тільки при success)
//        var summary = base([
//            "onboard_id": tag.rawValue,
//            "paywall_id": paywallId,
//            "event_role": "summary",
//            "status": status.rawValue,
//            "steps_count": steps.count
//        ])
//        if let variant { summary["variant"] = variant }
//        if let entryPoint { summary["entry_point"] = entryPoint }
//        if let reason { summary["reason"] = reason }
//        if status == .success, let plan { summary["plan"] = plan }
//
//        // (опційно, чисто для дебагу) summary["steps_str"] = steps.joined(separator: "|")
//
//        Analytics.logEvent(tag.summaryEventName, parameters: summary)
//    }
//}


extension OnboardTag {
    var summaryEventName: String {
        switch self {
        case .v31: return "Onboard_v_3_1"
        case .v32: return "Onboard_v_3_2"
        case .v33: return "Onboard_v_3_3"
        case .v41: return "Onboard_v_4_1"
        case .v5: return "Onboard_v_5"
        case .v6: return "Onboard_v_6"
        case .v7: return "Onboard_v_7"
        case .v8: return "Onboard_v_8"
        case .modes: return "Modes"
        }
    }
    var stepEventName: String { "\(summaryEventName)_step" } // ← подія для КРОКІВ
}

private let kOnboardLastTagKey = "onboard_last_tag_v1"

extension OnboardTag {
    /// Зберегти останній онборд, який показали юзеру
    static func saveAsLast(_ tag: OnboardTag) {
        UserDefaults.standard.set(tag.rawValue, forKey: kOnboardLastTagKey)
        // опційно — ще й user property в GA4
        Analytics.setUserProperty(tag.rawValue, forName: "onboard_last")
    }

    /// Прочитати останній онборд із UserDefaults
    static func lastFromUserDefaults() -> OnboardTag? {
        guard let raw = UserDefaults.standard.string(forKey: kOnboardLastTagKey) else {
            return nil
        }
        return OnboardTag(rawValue: raw)
    }
}


extension Telemetry {
    func onbFlowSummary(
        onboard tag: OnboardTag,
        steps: [String],
        paywallId: String,
        plan: String?,
        status: PaywallStatus,
        variant: String? = nil,
        entryPoint: String? = nil,
        reason: String? = nil
    ) {
        // унікальні кроки у порядку проходження (без дублів при поверненні назад)
        var seen = Set<String>()
        let ordered = steps.filter { s in
            if seen.contains(s) { return false }
            seen.insert(s); return true
        }
        
        // 2) Зведення: onboard_v_3_x (без step_1/visited_* і без steps-рядка)
        var summary = base([
            "onboard_id": tag.rawValue,
            "paywall_id": paywallId,
            "status": status.rawValue,
            "steps_count": steps.count
        ])
        //if let variant { summary["variant"] = variant }
        if let entryPoint { summary["entry_point"] = entryPoint }
        if let reason { summary["reason"] = reason }
        if let plan { summary["plan"] = plan } // ← тільки для success

        Analytics.logEvent(tag.summaryEventName, parameters: summary)
    }
}



extension Telemetry {
    func modesPaywall(status: PaywallStatus, plan: String?, paywallId: String, onboard tag: OnboardTag) {
        
        var summary = base([
            "onboard_id": tag.rawValue,
            "status": status.rawValue,
            "paywall_id": paywallId
        ])
        if let plan { summary["plan"] = plan }
        Analytics.logEvent(tag.summaryEventName, parameters: summary)
    }
}

//extension OnboardTag {
//    var stepEventName: String { "onb_step" }
//}


extension Telemetry {
    private func logOnbStep(
        onboard tag: OnboardTag,
        step: String,
        index: Int,
        total: Int,
        paywallId: String,
        variant: String?,
        entryPoint: String?
    ) {
        var p = base([
            "onboard_id": tag.rawValue,
            "paywall_id": paywallId,
            "steps": step,          // ← ЄДИНИЙ custom dimension (Item = значення кроку)
            "step_index": index,    // опційно, 2-й dimension
            "steps_count": total    // опційно
        ])
        if let variant { p["variant"] = variant }
        if let entryPoint { p["entry_point"] = entryPoint }
        Analytics.logEvent(tag.stepEventName, parameters: p)
    }
}

extension Telemetry {
    /// Єдиний стартовий маркер онбордингу з явним onboard_id
    func onboardStarted(onboardId: String) {
        Analytics.logEvent("onboardStarted", parameters: base(["onboard_id": onboardId]))
    }
    
}

