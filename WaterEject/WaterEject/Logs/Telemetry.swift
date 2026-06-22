//
//  Telemetry.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 21.08.2025.
//

import Foundation
import FirebaseAnalytics
import RevenueCat
import StoreKit

enum PaywallStatus: String {
    case success
    case error
    case close
    case abandon
}

enum TelemetryEvent: String {
    case paywallExposure = "paywall_exposure"
    case paywallClose = "paywall_close"
    case purchaseStart = "purchase_start"
    case purchaseSuccess = "purchase_success"
    case purchaseError = "purchase_error"
    case purchaseCancelled = "purchase_cancelled"
    case restoreStart = "restore_start"
    case restoreSuccess = "restore_success"
    case restoreError = "restore_error"
    case homeExposure = "home_exposure"
    case homeDeviceTap = "home_device_tap"
    case homeNavigateModes = "home_navigate_modes"
    case settimgExpose = "setting_exposure"
    case modesExposure = "modes_exposure"
    case modesModeTap = "modes_mode_tap"
    case modesStartNavigate = "modes_start_navigate"
    case modesPaywallRequested = "modes_paywall_requested"
    case modesPaywallDismissed = "modes_paywall_dismissed"
    case modesBackTap = "modes_back_tap"
    case startExposure = "start_exposure"
    case startBackTap = "start_back_tap"
    case startPrimaryTap = "start_primary_tap"
    case startPromptShown = "start_prompt_shown"
    case startPromptConfirm = "start_prompt_confirm"
    case startPromptCancel = "start_prompt_cancel"
    case startCleaningBegin = "start_cleaning_begin"
    case startCleaningEnd = "start_cleaning_end"
    case startTimerStart = "start_timer_start"
    case startTimerEnd = "start_timer_end"
    case startPaywallRequested = "start_paywall_requested"
    case startPaywallDismissed = "start_paywall_dismissed"
    case onboardingStart = "onboarding_start"
    case onboardingExposure = "onboarding_exposure"
    case onboardingContinue = "onboarding_continue"
    case onboardingFinish = "onboarding_finish"
    case onboardingStepChange = "onboarding_step_change"
    case modesPaywall = "modes_paywall"
}

enum PaywallCloseSource: String {
    case closeButton = "close_button"
    case systemDismiss = "system_dismiss"
    case backSwipe = "back_swipe"
}

enum PurchaseSource: String, Codable {
    case onboarding = "onboarding"
    case modesTap = "modes_tap"
    case startViewAuto = "start_view_auto"
    case startButton = "start_button"
    case testTab = "test_tab"
    case specialOfferAfterTransactionAbandon = "special_offer_after_transaction_abandon"
    case specialOfferPushNotification = "special_offer_push_notification"
    case specialOfferPushNotification5Min = "special_offer_push_notification_5_min"
    case specialOfferPushNotification30Min = "special_offer_push_notification_30_min"
    case specialOfferPushNotification1Day = "special_offer_push_notification_1_day"
    case specialOfferPushNotification3Days = "special_offer_push_notification_3_days"
    case specialOfferPushNotification7Days = "special_offer_push_notification_7_days"
    case specialOfferAfterOnboarding = "special_offer_after_onboarding"
    case specialOfferAfterDevicesScreen = "special_offer_after_devices_screen"
    case specialOfferAfterPlayerScreen = "special_offer_after_player_screen"
    case specialOfferAfterDJPultScreen = "special_offer_after_dj_pult_screen"
    case specialOfferAfterEqualizerScreen = "special_offer_after_equalizer_screen"
    case specialOfferAfterFreeTest = "special_offer_after_free_test"
    case specialOfferOther = "special_offer_other"
    case otherScreen = "other_screen"
}

enum TelemetryPurchaseFailureReason: String {
    case userCancelled = "user_cancelled"
    case error = "error"
    case productNotFound = "product_not_found"
    case inactiveAfterPurchase = "inactive_after_purchase"
    case unknown = "unknown"
}

enum TelemetryPurchaseAttemptStatus {
    case success
    case cancelled
    case failed
}

struct TelemetryPurchaseAttemptResult {
    let status: TelemetryPurchaseAttemptStatus
    let packageId: String
    let transactionId: String?
    let rcCode: Int?
    let message: String?
    let reasonWhy: TelemetryPurchaseFailureReason?

    var isSuccess: Bool { status == .success }
    var isCancelled: Bool { status == .cancelled }
}

struct TelemetryOnboardingContext: Codable, Equatable {
    var brand: String?
    var onboardId: String?
    var flowKey: String?
    var flowId: String?
    var brandedFlow: String?
    var onbExperimentId: String?
    var onbVariantId: String?
    var onbBucket: String?
}

private struct ActiveOnboardingState: Codable, Equatable {
    var flowId: String
    var stepId: String
    var screenId: String
    var startedAt: TimeInterval
}

private struct PendingOnboardingStart: Codable, Equatable {
    var flowId: String
    var startedAt: TimeInterval
}

private struct KeywordAttributionState: Codable, Equatable {
    var startedAt: TimeInterval
    var resolvedAt: TimeInterval?
    var keywordId: String?
    var keywordText: String?
    var keywordSource: String?
}

private struct PurchaseTelemetryContext {
    var paywallId: String
    var entryPoint: String
    var purchaseSource: PurchaseSource
    var onboardId: String?
    var brand: String?
    var selectedDevice: String?
    var placeWhereBuy: String?
    var specialOfferVariant: String?
    var offerText: String?
}

enum OnboardTag: String, Codable {
    case new21 = "Onboard_new_2_1"
    case branded2 = "Branded_Onboard_2"
    case v31 = "Onboard_3_1"
    case v32 = "Onboard_3_2"
    case v33 = "Onboard_3_3"
    case v41 = "Onboard_4_1"
    case v5 = "Onboard_5"
    case v6 = "Onboard_6"
    case v7 = "Onboard_7"
    case v8 = "Onboard_8_1"
    case v9 = "Onboard_9"
    case v10 = "Onboard_10_1"
    case modes = "Modes"
}

private let kOnboardLastTagKey = "onboard_last_tag_v1"

extension OnboardTag {
    var summaryEventName: String {
        switch self {
        case .new21: return "Onboard_new_v_2_1"
        case .branded2: return "Onboard_branded_v_2"
        case .v31: return "Onboard_v_3_1"
        case .v32: return "Onboard_v_3_2"
        case .v33: return "Onboard_v_3_3"
        case .v41: return "Onboard_v_4_1"
        case .v5: return "Onboard_v_5"
        case .v6: return "Onboard_v_6"
        case .v7: return "Onboard_v_7"
        case .v8: return "Onboard_v_8_1"
        case .v9: return "Onboard_v_9"
        case .v10: return "Onboard_v_10_1"
        case .modes: return "Modes"
        }
    }

    var stepEventName: String { "\(summaryEventName)_step" }

    static func saveAsLast(_ tag: OnboardTag) {
        UserDefaults.standard.set(tag.rawValue, forKey: kOnboardLastTagKey)
        Analytics.setUserProperty(tag.rawValue, forName: "onboard_last")
    }

    static func lastFromUserDefaults() -> OnboardTag? {
        guard let raw = UserDefaults.standard.string(forKey: kOnboardLastTagKey) else {
            return nil
        }
        return OnboardTag(rawValue: raw)
    }
}

final class Telemetry {
    static let shared = Telemetry()

    private let defaults = UserDefaults.standard
    private let userUUIDKey = "telemetry_user_uuid_v1"
    private let presentedOnboardingContextKey = "telemetry_presented_onboarding_context_v1"
    private let activeOnboardingKey = "telemetry_active_onboarding_v1"
    private let pendingOnboardingStartKey = "telemetry_pending_onboarding_start_v1"
    private let firstTimeOpenLoggedKey = "telemetry_first_time_open_logged_v1"
    private let distributionLoggedPrefix = "telemetry_distribution_logged_v1_"
    private let txSuccessPrefix = "telemetry_tx_success_v1_"
    private let keywordStateKey = "telemetry_keyword_state_v1"
    private let paywallContextKey = "telemetry_paywall_context_v1"

    private init() {}

    private var userUUID: String {
        if let stored = defaults.string(forKey: userUUIDKey), !stored.isEmpty {
            return stored
        }

        let value = UUID().uuidString
        defaults.set(value, forKey: userUUIDKey)
        return value
    }

    private var currentCountryCode: String {
        if #available(iOS 16.0, *) {
            return Locale.current.region?.identifier ?? Locale.current.regionCode ?? "unknown"
        }
        return Locale.current.regionCode ?? "unknown"
    }

    private var currentTierSuffix: String {
        let code = currentCountryCode.uppercased()
        if ["US", "CA"].contains(code) {
            return "tier_1"
        }
        if europeanCountryCodes.contains(code) {
            return "tier_2"
        }
        return "tier_3"
    }

    private func baseParams(
        explicitOnboardId: String? = nil,
        explicitBrand: String? = nil,
        variant: String? = nil,
        includeOnboardingContext: Bool = true
    ) -> [String: Any] {
        let storedContext = includeOnboardingContext ? presentedOnboardingContext() : nil
        let resolvedOnboardId = resolveOnboardId(explicitOnboardId, brand: explicitBrand ?? storedContext?.brand)
        let resolvedBrand = explicitBrand ?? brand(fromOnboardId: resolvedOnboardId) ?? storedContext?.brand

        var params: [String: Any] = [
            "user_uuid": userUUID,
            "country": currentCountryCode
        ]

        if let resolvedBrand, !resolvedBrand.isEmpty {
            params["brand"] = resolvedBrand
        }

        if let variant, !variant.isEmpty {
            params["variant"] = variant
        }

        if let resolvedOnboardId, !resolvedOnboardId.isEmpty {
            params["onboard_id"] = resolvedOnboardId
            params.merge(assignedPaywallProductParams(onboardId: resolvedOnboardId)) { current, _ in current }
        }

        if let resolvedBrand,
           !resolvedBrand.isEmpty,
           let resolvedOnboardId,
           !resolvedOnboardId.isEmpty {
            params["funnel_key"] = "\(resolvedBrand)|\(resolvedOnboardId)"
        }

        if let storedContext {
            if let flowKey = storedContext.flowKey, !flowKey.isEmpty {
                params["onboarding_flow_key"] = flowKey
            }
            if let brandedFlow = storedContext.brandedFlow, !brandedFlow.isEmpty {
                params["branded_flow"] = brandedFlow
                params["branded_flow_flag"] = true
            }
            if let experimentId = storedContext.onbExperimentId, !experimentId.isEmpty {
                params["onb_experiment_id"] = experimentId
            }
            if let variantId = storedContext.onbVariantId, !variantId.isEmpty {
                params["onb_variant_id"] = variantId
            }
            if let bucket = storedContext.onbBucket, !bucket.isEmpty {
                params["onb_bucket"] = bucket
            }
        }

        return params
    }

    private func mergedParams(
        explicitOnboardId: String? = nil,
        explicitBrand: String? = nil,
        variant: String? = nil,
        includeOnboardingContext: Bool = true,
        extra: [String: Any] = [:]
    ) -> [String: Any] {
        var params = baseParams(
            explicitOnboardId: explicitOnboardId,
            explicitBrand: explicitBrand,
            variant: variant,
            includeOnboardingContext: includeOnboardingContext
        )
        extra.forEach { params[$0.key] = $0.value }
        return params
    }

    private func logEvent(
        _ name: String,
        explicitOnboardId: String? = nil,
        explicitBrand: String? = nil,
        variant: String? = nil,
        includeOnboardingContext: Bool = true,
        extra: [String: Any] = [:]
    ) {
        Analytics.logEvent(
            name,
            parameters: mergedParams(
                explicitOnboardId: explicitOnboardId,
                explicitBrand: explicitBrand,
                variant: variant,
                includeOnboardingContext: includeOnboardingContext,
                extra: extra
            )
        )
    }

    private func logTieredEvent(
        _ baseName: String,
        explicitOnboardId: String? = nil,
        explicitBrand: String? = nil,
        variant: String? = nil,
        extra: [String: Any] = [:]
    ) {
        let name = "\(baseName)_\(currentTierSuffix)"
        logEvent(
            name,
            explicitOnboardId: explicitOnboardId,
            explicitBrand: explicitBrand,
            variant: variant,
            extra: extra
        )
    }

    private func paywallId(for variant: String?) -> String {
        switch variant {
        case "third":
            return "paywall_v_3.0"
        case "fourth":
            return "paywall_v_4.0"
        case "fifth":
            return "paywall_v_5.0"
        default:
            return "paywall_unknown"
        }
    }

    private func assignedPaywallKey(for onboardId: String?) -> String? {
        let resolvedOnboardId = resolveOnboardId(onboardId)
        let candidates = [
            resolvedOnboardId,
            onboardId,
            presentedOnboardingContext()?.flowKey,
            presentedOnboardingContext()?.flowId
        ].compactMap { $0 }

        for candidate in candidates {
            if let tag = OnboardTag(rawValue: candidate) {
                return PaywallAB.shared.assignedOnboardingPaywallKey(for: tag)
            }

            if let variant = OnboardingVariant(rawValue: candidate) {
                return PaywallAB.shared.assignedOnboardingPaywallKey(for: variant.onboardTag)
            }

            switch candidate {
            case "onb_10_1":
                return PaywallAB.shared.assignedOnboardingPaywallKey(for: .v10)
            case "onb_8_1", "onboard_8_1_steps":
                return PaywallAB.shared.assignedOnboardingPaywallKey(for: .v8)
            case "new_onb_1":
                return "paywall_new_black_3"
            case "new_onb_2":
                return "paywall_new_black_2"
            case "new_onb_3":
                return "paywall_new_black_1"
            case "new_onb_4", "new_onb_5":
                return "paywall_new_white_1"
            case "new_onb_6":
                return "paywall_new_black_4"
            case "new_onb_7":
                return "paywall_new_black_5"
            default:
                continue
            }
        }

        return nil
    }

    private func firstTimeOpenPaywallProductParams(onboardId: String?) -> [String: Any] {
        guard let paywallKey = assignedPaywallKey(for: onboardId) else {
            return [:]
        }

        let productSettingsKey = assignedPaywallProductSettingsKey(paywallKey)
        let settings = PaywallAB.shared.productSettings(forKey: productSettingsKey)
        var params: [String: Any] = [
            "assigned_paywall_key": paywallKey,
            "assigned_paywall_product_key": productSettingsKey,
            "assigned_weekly_product_id": settings.weeklyProductID,
            "assigned_yearly_product_id": settings.yearlyProductID,
            "assigned_annual_product_id": settings.annualProductID,
            "assigned_yearly_card_plan": settings.yearlyCardPlan.rawValue,
            "assigned_free_trial_enabled": settings.freeTest
        ]

        if let variantID = settings.variantID {
            params["assigned_product_variant_id"] = variantID
        }

        return params
    }

    private func assignedPaywallProductParams(onboardId: String?) -> [String: Any] {
        firstTimeOpenPaywallProductParams(onboardId: onboardId)
    }

    private func assignedPaywallProductSettingsKey(_ assignedPaywallKey: String) -> String {
        switch assignedPaywallKey {
        case AssignedOnboardingPaywall.newSecondBlack.rawValue:
            return AssignedOnboardingPaywall.newSecondBlack.productSettingsKey
        case AssignedOnboardingPaywall.newFirstWhite.rawValue:
            return AssignedOnboardingPaywall.newFirstWhite.productSettingsKey
        case AssignedOnboardingPaywall.paywallFive.rawValue:
            return AssignedOnboardingPaywall.paywallFive.productSettingsKey
        case AssignedOnboardingPaywall.paywallFourth.rawValue:
            return AssignedOnboardingPaywall.paywallFourth.productSettingsKey
        case AssignedOnboardingPaywall.paywallThird.rawValue:
            return AssignedOnboardingPaywall.paywallThird.productSettingsKey
        default:
            return assignedPaywallKey
        }
    }

    private func productSettingsKey(paywallId: String?, variant: String?, onboardId: String?) -> String? {
        let trimmedPaywallId = paywallId?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let rcPaywallKeys: Set<String> = ["first", "second", "third", "fourth", "fifth", "special"]
        if rcPaywallKeys.contains(trimmedPaywallId) ||
            trimmedPaywallId == AssignedOnboardingPaywall.newSecondBlack.rawValue ||
            trimmedPaywallId == AssignedOnboardingPaywall.newFirstWhite.rawValue ||
            trimmedPaywallId.hasPrefix("paywall_new_") {
            return trimmedPaywallId
        }

        let trimmedVariant = variant?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !trimmedVariant.isEmpty {
            return trimmedVariant
        }

        return assignedPaywallKey(for: onboardId)
    }

    private func selectedProductParams(paywallKey: String?, onboardId: String?, plan: String) -> [String: Any] {
        let resolvedPaywallKey = paywallKey ?? assignedPaywallKey(for: onboardId)
        guard let resolvedPaywallKey else { return [:] }

        let productSettingsKey = assignedPaywallProductSettingsKey(resolvedPaywallKey)
        let settings = PaywallAB.shared.productSettings(forKey: productSettingsKey)
        let normalizedPlan = plan.lowercased()
        var params: [String: Any] = [
            "selected_paywall_key": resolvedPaywallKey,
            "selected_paywall_product_key": productSettingsKey,
            "selected_product_plan": normalizedPlan
        ]

        switch normalizedPlan {
        case "weekly":
            params["selected_product_id"] = settings.weeklyProductID
            params["weekly_product_id"] = settings.weeklyProductID
        case "yearly":
            params["selected_product_id"] = settings.yearlyProductID
            params["yearly_product_id"] = settings.yearlyProductID
        case "annual":
            params["selected_product_id"] = settings.annualProductID
            params["annual_product_id"] = settings.annualProductID
        default:
            break
        }

        if let variantID = settings.variantID {
            params["product_variant_id"] = variantID
        }

        return params
    }

    private func purchaseSource(for context: PaywallContext?) -> PurchaseSource {
        switch context {
        case .onboarding:
            return .onboarding
        case .modesTap:
            return .modesTap
        case .testTab:
            return .testTab
        case .startButton:
            return .startButton
        case .startViewAuto:
            return .startViewAuto
        case .none:
            return .otherScreen
        }
    }

    private func specialOfferPurchaseSource(from placeWhereBuy: String?) -> PurchaseSource {
        guard let placeWhereBuy else { return .specialOfferOther }
        let value = placeWhereBuy.lowercased()

        if value.contains("30") {
            return .specialOfferPushNotification30Min
        }
        if value.contains("1 day") || value.contains("1day") {
            return .specialOfferPushNotification1Day
        }
        if value.contains("3 day") || value.contains("3day") {
            return .specialOfferPushNotification3Days
        }
        if value.contains("7 day") || value.contains("7day") {
            return .specialOfferPushNotification7Days
        }
        if value.contains("5 min") || value.contains("5min") {
            return .specialOfferPushNotification5Min
        }
        if value.contains("push") || value.contains("notification") {
            return .specialOfferPushNotification
        }
        if value.contains("after onboarding") {
            return .specialOfferAfterOnboarding
        }
        if value.contains("devices screen") {
            return .specialOfferAfterDevicesScreen
        }
        if value.contains("player screen") {
            return .specialOfferAfterPlayerScreen
        }
        if value.contains("dj pult screen") {
            return .specialOfferAfterDJPultScreen
        }
        if value.contains("equalizer screen") {
            return .specialOfferAfterEqualizerScreen
        }
        if value.contains("free test") {
            return .specialOfferAfterFreeTest
        }
        if value.contains("transaction abandon") || value.contains("abandon") {
            return .specialOfferAfterTransactionAbandon
        }
        return .specialOfferOther
    }

    func setPaywallContext(_ context: PaywallContext?) {
        if let context {
            defaults.set(context.rawValue, forKey: paywallContextKey)
        } else {
            defaults.removeObject(forKey: paywallContextKey)
        }
    }

    func currentPaywallContext() -> PaywallContext? {
        guard let raw = defaults.string(forKey: paywallContextKey) else {
            return nil
        }
        return PaywallContext(rawValue: raw)
    }

    func resolveOnboardId(_ onboardId: String?, brand: String? = nil) -> String? {
        let storedContext = presentedOnboardingContext()
        let source = onboardId ?? storedContext?.onboardId ?? OnboardTag.lastFromUserDefaults()?.rawValue
        guard let source, !source.isEmpty else { return nil }

        guard source.hasPrefix("Branded_Onboard_") else {
            return source
        }

        let resolvedBrand = (brand ?? storedContext?.brand)?.lowercased()
        guard let resolvedBrand, !resolvedBrand.isEmpty else {
            return source
        }

        switch source {
        case "Branded_Onboard_1":
            return "\(resolvedBrand)_4_v1"
        case "Branded_Onboard_2":
            return "\(resolvedBrand)_3_v2"
        case "Branded_Onboard_3":
            return "\(resolvedBrand)_5_v3"
        case "Branded_Onboard_4":
            return "\(resolvedBrand)_5_v4"
        default:
            return source
        }
    }

    func resolvedPurchaseSource(for context: PaywallContext?) -> PurchaseSource {
        purchaseSource(for: context ?? currentPaywallContext())
    }

    func resolvedSpecialOfferPurchaseSource(from placeWhereBuy: String?) -> PurchaseSource {
        specialOfferPurchaseSource(from: placeWhereBuy)
    }

    func brand(fromOnboardId onboardId: String?) -> String? {
        guard let onboardId, !onboardId.isEmpty else { return nil }
        let pattern = #"^([A-Za-z0-9]+)_(4_v1|3_v2|5_v3|5_v4)$"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(onboardId.startIndex..<onboardId.endIndex, in: onboardId)
        guard let match = regex.firstMatch(in: onboardId, options: [], range: range),
              let brandRange = Range(match.range(at: 1), in: onboardId) else {
            return nil
        }
        return String(onboardId[brandRange]).lowercased()
    }

    func presentedOnboardingContext() -> TelemetryOnboardingContext? {
        guard let data = defaults.data(forKey: presentedOnboardingContextKey) else {
            return nil
        }
        return try? JSONDecoder().decode(TelemetryOnboardingContext.self, from: data)
    }

    func setPresentedOnboardingContext(
        brand: String?,
        onboardId: String?,
        flowKey: String?,
        flowId: String? = nil,
        brandedFlow: String? = nil,
        onbExperimentId: String? = nil,
        onbVariantId: String? = nil,
        onbBucket: String? = nil
    ) {
        let resolvedOnboardId = resolveOnboardId(onboardId, brand: brand)
        let resolvedBrand = brand ?? self.brand(fromOnboardId: resolvedOnboardId)

        let context = TelemetryOnboardingContext(
            brand: resolvedBrand,
            onboardId: resolvedOnboardId,
            flowKey: flowKey,
            flowId: flowId,
            brandedFlow: brandedFlow,
            onbExperimentId: onbExperimentId,
            onbVariantId: onbVariantId,
            onbBucket: onbBucket
        )

        if let data = try? JSONEncoder().encode(context) {
            defaults.set(data, forKey: presentedOnboardingContextKey)
        }

        if let resolvedOnboardId, !resolvedOnboardId.isEmpty {
            Analytics.setUserProperty(resolvedOnboardId, forName: "onboard_last")
        }
    }

    func clearPresentedOnboardingContext() {
        defaults.removeObject(forKey: presentedOnboardingContextKey)
    }

    func setActiveOnboarding(flowId: String, stepId: String, screenId: String? = nil) {
        let state = ActiveOnboardingState(
            flowId: flowId,
            stepId: stepId,
            screenId: screenId ?? stepId,
            startedAt: Date().timeIntervalSince1970
        )
        if let data = try? JSONEncoder().encode(state) {
            defaults.set(data, forKey: activeOnboardingKey)
        }
    }

    func clearActiveOnboarding() {
        defaults.removeObject(forKey: activeOnboardingKey)
        defaults.removeObject(forKey: pendingOnboardingStartKey)
    }

    func logOnboardingAbandonIfActive(reason: String) {
        guard let data = defaults.data(forKey: activeOnboardingKey),
              let active = try? JSONDecoder().decode(ActiveOnboardingState.self, from: data) else {
            return
        }

        logEvent(
            "onboarding_abandon",
            extra: [
                "flow_id": active.flowId,
                "step_id": active.stepId,
                "reason": reason
            ]
        )

        clearActiveOnboarding()
    }

    func appMovedToBackground() {
        logOnboardingAbandonIfActive(reason: "app_background")
    }

    func log(_ event: TelemetryEvent, params: [String: Any] = [:]) {
        logEvent(event.rawValue, extra: params)
    }
}

// MARK: - Legacy Generic Analytics
extension Telemetry {
    func paywallExposure(source: String? = nil) {
        var params: [String: Any] = [:]
        if let source {
            params["source"] = source
        }
        log(.paywallExposure, params: params)
    }

    func paywallClosed(source: PaywallCloseSource) {
        log(.paywallClose, params: ["source": source.rawValue])
    }

    func purchaseSuccess(plan: PaywallPlan, product: StoreProduct, transactionId: String?) {
        let price = NSDecimalNumber(decimal: product.price).doubleValue
        log(.purchaseSuccess, params: [
            "plan": plan.analyticsValue,
            "product_id": product.productIdentifier,
            "price": price,
            "currency": product.currencyCode ?? "",
            "transaction_id": transactionId ?? ""
        ])
    }

    func purchaseError(plan: PaywallPlan?, reason: String? = nil, error: Error? = nil) {
        var params: [String: Any] = [:]
        if let plan {
            params["plan"] = plan.analyticsValue
        }
        if let reason {
            params["reason"] = reason
        }
        if let error {
            let nsError = error as NSError
            params["domain"] = nsError.domain
            params["code"] = nsError.code
            params["message"] = nsError.localizedDescription
        }
        log(.purchaseError, params: params)
    }

    func purchaseCancelled(plan: PaywallPlan) {
        log(.purchaseCancelled, params: ["plan": plan.analyticsValue])
    }

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
            "code": ns.code,
            "message": ns.localizedDescription
        ])
    }

    func homeExposure() { log(.homeExposure) }
    func settingExposure() { log(.settimgExpose) }

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
            "mode": mode.analyticsValue
        ])
    }

    func modesStartNavigate(device: CleaningDevice, mode: CleaningMode) {
        log(.modesStartNavigate, params: [
            "device": device.analyticsValue,
            "mode": mode.analyticsValue
        ])
    }

    func modesPaywallRequested(device: CleaningDevice, mode: CleaningMode) {
        log(.modesPaywallRequested, params: [
            "device": device.analyticsValue,
            "mode": mode.analyticsValue
        ])
    }

    func modesPaywallDismissed(device: CleaningDevice, mode: CleaningMode, converted: Bool) {
        log(.modesPaywallDismissed, params: [
            "device": device.analyticsValue,
            "mode": mode.analyticsValue,
            "converted": converted
        ])
    }

    func modesBackTap(device: CleaningDevice) {
        log(.modesBackTap, params: ["device": device.analyticsValue])
    }

    func startExposure(device: CleaningDevice, mode: CleaningMode) {
        log(.startExposure, params: [
            "device": device.analyticsValue,
            "mode": mode.analyticsValue
        ])
    }

    func startBackTap(device: CleaningDevice, mode: CleaningMode, disabled: Bool) {
        log(.startBackTap, params: [
            "device": device.analyticsValue,
            "mode": mode.analyticsValue,
            "disabled": disabled
        ])
    }

    func startPrimaryTap(device: CleaningDevice, mode: CleaningMode) {
        log(.startPrimaryTap, params: [
            "device": device.analyticsValue,
            "mode": mode.analyticsValue
        ])
    }

    func startPromptShown(device: CleaningDevice, mode: CleaningMode) {
        log(.startPromptShown, params: [
            "device": device.analyticsValue,
            "mode": mode.analyticsValue
        ])
    }

    func startPromptConfirm(device: CleaningDevice, mode: CleaningMode) {
        log(.startPromptConfirm, params: [
            "device": device.analyticsValue,
            "mode": mode.analyticsValue
        ])
    }

    func startPromptCancel(device: CleaningDevice, mode: CleaningMode) {
        log(.startPromptCancel, params: [
            "device": device.analyticsValue,
            "mode": mode.analyticsValue
        ])
    }

    func startCleaningBegin(device: CleaningDevice, mode: CleaningMode, duration: Int) {
        log(.startCleaningBegin, params: [
            "device": device.analyticsValue,
            "mode": mode.analyticsValue,
            "duration_sec": duration
        ])
    }

    func startCleaningEnd(device: CleaningDevice, mode: CleaningMode, reason: String) {
        log(.startCleaningEnd, params: [
            "device": device.analyticsValue,
            "mode": mode.analyticsValue,
            "reason": reason
        ])
    }

    func startTimerStart(device: CleaningDevice, mode: CleaningMode, duration: Int) {
        log(.startTimerStart, params: [
            "device": device.analyticsValue,
            "mode": mode.analyticsValue,
            "duration_sec": duration
        ])
    }

    func startTimerEnd(device: CleaningDevice, mode: CleaningMode) {
        log(.startTimerEnd, params: [
            "device": device.analyticsValue,
            "mode": mode.analyticsValue
        ])
    }

    func startPaywallRequested(auto: Bool) {
        log(.startPaywallRequested, params: ["auto": auto])
    }

    func startPaywallDismissed(converted: Bool) {
        log(.startPaywallDismissed, params: ["converted": converted])
    }
}

// MARK: - Onboarding Funnel
extension Telemetry {
    func onboardingStart(flow: String = "default") {
        logEvent("onboarding_start", extra: ["flow_id": flow])
    }

    func onboardingExposure(step: OnboardingStep, flow: String = "default") {
        logEvent("onboarding_step_view", extra: [
            "flow_id": flow,
            "step_id": step.analyticsValue,
            "screen_id": step.analyticsValue
        ])
    }

    func onboardingContinue(step: OnboardingStep, flow: String = "default") {
        logEvent("onboarding_step_action", extra: [
            "flow_id": flow,
            "step_id": step.analyticsValue,
            "action": "continue"
        ])
    }

    func onboardingFinish(flow: String = "default") {
        let activeFlowId = activeOnboardingFlowId() ?? flow
        let activeStep = activeOnboardingStepId()
        logEvent("onboarding_complete", extra: [
            "flow_id": activeFlowId,
            "step_id": activeStep ?? "complete"
        ])
        clearActiveOnboarding()
    }

    func onboardingStepChange(from: OnboardingStep, to: OnboardingStep, flow: String = "default") {
        logEvent("onboarding_step_change", extra: [
            "flow_id": flow,
            "onboarding_from_step": from.analyticsValue,
            "onboarding_to_step": to.analyticsValue
        ])
    }

    func onboardingScreenMarker(step: OnboardingStep, flow: String = "default") {
        logEvent("onboarding_1_2", extra: [
            "flow_id": flow,
            "step_id": step.analyticsValue,
            "screen_id": step.analyticsValue,
            "onboarding_action": "screen"
        ])
    }

    func onbFlowStart(flowId: String) {
        let state = PendingOnboardingStart(flowId: flowId, startedAt: Date().timeIntervalSince1970)
        if let data = try? JSONEncoder().encode(state) {
            defaults.set(data, forKey: pendingOnboardingStartKey)
        }
        logEvent("onb_flow_start", extra: ["flow_id": flowId])
    }

    func onbScreenView(flowId: String, screenId: String) {
        if let pending = pendingOnboardingStart(), pending.flowId == flowId {
            logEvent("onboarding_start", extra: [
                "flow_id": flowId,
                "step_id": screenId
            ])
            defaults.removeObject(forKey: pendingOnboardingStartKey)
        }

        if let activeFlowId = activeOnboardingFlowId(),
           let activeStepId = activeOnboardingStepId(),
           activeFlowId == flowId,
           activeStepId != screenId {
            logEvent("onboarding_step_action", extra: [
                "flow_id": flowId,
                "step_id": activeStepId,
                "action": "continue"
            ])
        }

        setActiveOnboarding(flowId: flowId, stepId: screenId, screenId: screenId)
        logEvent(flowId, extra: [
            "flow_id": flowId,
            "screen_id": screenId
        ])
        logEvent("onboarding_step_view", extra: [
            "flow_id": flowId,
            "step_id": screenId,
            "screen_id": screenId,
            "variant": resolveOnboardId(nil) ?? ""
        ])
    }

    func logOnboardingStepAction(flowId: String, stepId: String, action: String) {
        logEvent("onboarding_step_action", extra: [
            "flow_id": flowId,
            "step_id": stepId,
            "action": action
        ])
    }

    func logOnboardChoice(flowId: String, choiceInfo: String, choiceName: String) {
        let stepId = activeOnboardingStepId() ?? "unknown"
        logEvent(flowId, extra: [
            "flow_id": flowId,
            choiceName: choiceInfo
        ])
        logEvent("onboarding_step_action", extra: [
            "flow_id": flowId,
            "step_id": stepId,
            "action": choiceName,
            choiceName: choiceInfo
        ])
    }

    func logOnboardChoiceSummary(flowId: String, device: String, reasonWet: String, sound: String, period: String) {
        logEvent(flowId, extra: [
            "flow_id": flowId,
            "device": device,
            "reasonWet": reasonWet,
            "sound": sound,
            "period": period
        ])
    }

    func onbFlowFinish(flowId: String) {
        logEvent("onb_flow_finish", extra: ["flow_id": flowId])
        logEvent("onboarding_complete", extra: [
            "flow_id": flowId,
            "step_id": activeOnboardingStepId() ?? "complete"
        ])
        clearActiveOnboarding()
    }

    func onboardStarted(onboardId: String) {
        let resolvedOnboardId = resolveOnboardId(onboardId)
        setPresentedOnboardingContext(
            brand: brand(fromOnboardId: resolvedOnboardId),
            onboardId: resolvedOnboardId,
            flowKey: resolvedOnboardId,
            flowId: nil
        )
        if let tag = OnboardTag(rawValue: onboardId) {
            OnboardTag.saveAsLast(tag)
        } else if let resolvedOnboardId {
            Analytics.setUserProperty(resolvedOnboardId, forName: "onboard_last")
        }
        logEvent("onboardStarted", explicitOnboardId: resolvedOnboardId)
    }

    func sceneDidBecomeActive(onboardId: String) {
        let resolvedOnboardId = resolveOnboardId(onboardId)
        logTieredEvent(
            "app_open",
            explicitOnboardId: resolvedOnboardId,
            extra: ["event_version": "1"]
        )

        if !defaults.bool(forKey: firstTimeOpenLoggedKey) {
            var params = firstTimeOpenPaywallProductParams(onboardId: resolvedOnboardId)
            params["event_version"] = "1"

            logTieredEvent(
                "first_time_open",
                explicitOnboardId: resolvedOnboardId,
                extra: params
            )
            defaults.set(true, forKey: firstTimeOpenLoggedKey)
        }
    }

    func funnelOnboardStart(onboardId: String) {
        let resolvedOnboardId = resolveOnboardId(onboardId)
        var params = assignedPaywallProductParams(onboardId: resolvedOnboardId)
        params["event_version"] = "1"

        logTieredEvent(
            "start_onboard",
            explicitOnboardId: resolvedOnboardId,
            extra: params
        )
    }

    func funnelPlanChosen(onboardId: String, plan: String, selectionMethod: String = "tap") {
        let resolvedOnboardId = resolveOnboardId(onboardId)
        var params = assignedPaywallProductParams(onboardId: resolvedOnboardId)
        params.merge(selectedProductParams(paywallKey: nil, onboardId: resolvedOnboardId, plan: plan)) { _, new in new }
        params["event_version"] = "1"
        params["plan"] = plan
        params["selection_method"] = selectionMethod

        logTieredEvent(
            "choose_plan",
            explicitOnboardId: resolvedOnboardId,
            extra: params
        )
    }

    func funnelGoToPurchase(onboardId: String, plan: String) {
        let resolvedOnboardId = resolveOnboardId(onboardId)
        var params = assignedPaywallProductParams(onboardId: resolvedOnboardId)
        params.merge(selectedProductParams(paywallKey: nil, onboardId: resolvedOnboardId, plan: plan)) { _, new in new }
        params["event_version"] = "1"
        params["plan"] = plan

        logTieredEvent(
            "go_to_purchase",
            explicitOnboardId: resolvedOnboardId,
            extra: params
        )
    }

    func funnelPurchaseSuccess(
        onboardId: String,
        plan: String,
        productId: String? = nil,
        purchaseSource: PurchaseSource? = nil
    ) {
        let resolvedOnboardId = resolveOnboardId(onboardId)
        var extra: [String: Any] = [
            "event_version": "1",
            "plan": plan
        ]
        extra.merge(assignedPaywallProductParams(onboardId: resolvedOnboardId)) { _, new in new }
        extra.merge(selectedProductParams(paywallKey: nil, onboardId: resolvedOnboardId, plan: plan)) { _, new in new }
        if let productId, !productId.isEmpty {
            extra["product_id"] = productId
            extra["selected_product_id"] = productId
        }
        if let purchaseSource {
            extra["purchase_source"] = purchaseSource.rawValue
        }
        logTieredEvent(
            "purchase_success",
            explicitOnboardId: resolvedOnboardId,
            extra: extra
        )
    }

    func markOnboardingDistribution(
        selectedOnboardId: String,
        selectedFlowKey: String,
        genericVariantId: String,
        genericFlowFamily: String,
        decisionReason: String,
        selectedPath: String = "generic",
        brand: String? = nil,
        selectedBrand: String? = nil,
        detectedBrand: String? = nil,
        keywordId: String? = nil,
        keywordText: String? = nil
    ) {
        let resolvedOnboardId = resolveOnboardId(selectedOnboardId, brand: brand)
        let key = "\(distributionLoggedPrefix)\(selectedFlowKey)|\(genericVariantId)|\(currentTierSuffix)"

        guard !defaults.bool(forKey: key) else { return }
        defaults.set(true, forKey: key)

        var params: [String: Any] = [
            "event_version": "1",
            "selected_path": selectedPath,
            "selected_flow_key": selectedFlowKey,
            "decision_reason": decisionReason,
            "show_branded_animation_rc": false,
            "branded_onboarding_percent": 0,
            "branded_percent_bucket": "0",
            "branded_percent_pass": false,
            "branded_final_eligible": false,
            "branded_has_enabled_flows": false,
            "branded_enabled_flow_count": 0,
            "branded_config_version": "none",
            "branded_config_summary": "disabled",
            "generic_experiment_id": "onboarding_variant_v2",
            "generic_variant_id": genericVariantId,
            "generic_bucket": stableBucket(seed: "\(userUUID)|\(genericVariantId)", modulo: 100),
            "generic_flow_family": genericFlowFamily,
            "has_seen_onboarding": defaults.bool(forKey: "hasSeenOnboarding"),
            "keyword_present": keywordText != nil || keywordId != nil,
            "brand_allowed": false
        ]

        if let selectedBrand {
            params["selected_brand"] = selectedBrand
        }
        if let detectedBrand {
            params["detected_brand"] = detectedBrand
        }
        if let keywordId {
            params["keyword_id"] = keywordId
        }
        if let keywordText {
            params["keyword_text"] = keywordText
            params["keyword"] = keywordText
        }

        logTieredEvent(
            "distribution_user",
            explicitOnboardId: resolvedOnboardId,
            explicitBrand: brand,
            extra: params
        )
    }
}

// MARK: - Paywall Analytics
extension Telemetry {
    func configurePaywallPresentation(
        paywallId: String,
        variant: String? = nil,
        entryPoint: String,
        purchaseSource: PurchaseSource,
        onboardId: String?,
        selectedDevice: String? = nil,
        placeWhereBuy: String? = nil,
        specialOfferVariant: String? = nil,
        offerText: String? = nil
    ) {
        let context = PurchaseTelemetryContext(
            paywallId: paywallId,
            entryPoint: entryPoint,
            purchaseSource: purchaseSource,
            onboardId: resolveOnboardId(onboardId),
            brand: brand(fromOnboardId: onboardId) ?? presentedOnboardingContext()?.brand,
            selectedDevice: selectedDevice,
            placeWhereBuy: placeWhereBuy,
            specialOfferVariant: specialOfferVariant,
            offerText: offerText
        )

        var params: [String: Any] = [
            "paywall_id": paywallId,
            "entry_point": entryPoint,
            "purchase_source": purchaseSource.rawValue
        ]
        params.merge(assignedPaywallProductParams(onboardId: context.onboardId)) { _, new in new }

        if let selectedDevice {
            params["selected_device"] = selectedDevice
        }
        if let specialOfferVariant {
            params["special_offer_variant"] = specialOfferVariant
        }
        if let offerText {
            params["offer_text"] = offerText
        }
        if let placeWhereBuy {
            params["place_where_open"] = placeWhereBuy
        }

        logEvent(
            "paywall_exposure",
            explicitOnboardId: context.onboardId,
            explicitBrand: context.brand,
            variant: variant,
            extra: params
        )
    }

    func paywallClose(
        variant: String,
        entryPoint: String,
        reason: String,
        sessionId: String,
        paywallId explicitPaywallId: String? = nil,
        onboardId explicitOnboardId: String? = nil
    ) {
        let paywallId = explicitPaywallId ?? paywallId(for: variant)
        let onboardId = resolveOnboardId(explicitOnboardId)
        let source = purchaseSource(for: currentPaywallContext())
        let assignedParams = assignedPaywallProductParams(onboardId: onboardId)

        logEvent(
            "paywall_close",
            explicitOnboardId: onboardId,
            variant: variant,
            extra: assignedParams.merging([
                "paywall_id": paywallId,
                "entry_point": entryPoint,
                "reason": reason,
                "paywall_session_id": sessionId,
                "purchase_source": source.rawValue
            ]) { _, new in new }
        )
        logEvent(
            "paywall_summary",
            explicitOnboardId: onboardId,
            variant: variant,
            extra: assignedParams.merging([
                "paywall_id": paywallId,
                "status": PaywallStatus.close.rawValue,
                "reason": reason,
                "purchase_source": source.rawValue
            ]) { _, new in new }
        )
    }

    func purchaseStart(
        variant: String,
        packageId: String,
        offeringId: String?,
        price: Double?,
        currency: String?,
        sessionId: String,
        paywallId explicitPaywallId: String? = nil,
        onboardId explicitOnboardId: String? = nil
    ) {
        let resolvedOnboardId = resolveOnboardId(explicitOnboardId)
        var params = assignedPaywallProductParams(onboardId: resolvedOnboardId)
        params.merge([
            "paywall_id": explicitPaywallId ?? paywallId(for: variant),
            "product_id": packageId,
            "selected_product_id": packageId,
            "package_id": packageId,
            "offering_id": offeringId ?? "na",
            "price_shown": price ?? 0,
            "paywall_currency": currency ?? "NA",
            "paywall_session_id": sessionId,
            "purchase_source": purchaseSource(for: currentPaywallContext()).rawValue
        ]) { _, new in new }

        logEvent(
            "Purchase_Start",
            explicitOnboardId: resolvedOnboardId,
            variant: variant,
            extra: params
        )
    }

    func purchaseResult(
        variant: String,
        status: String,
        rcCode: Int?,
        packageId: String,
        pricePaid: Double?,
        currency: String?,
        sessionId: String,
        onboardId: String?,
        paywallId: String
    ) {
        logEvent(
            "Purchase_Result",
            explicitOnboardId: onboardId,
            variant: variant,
            extra: [
                "status": status,
                "rc_code": rcCode ?? -1,
                "package_id": packageId,
                "price_paid": pricePaid ?? 0,
                "currency": currency ?? "NA",
                "paywall_session_id": sessionId,
                "paywall_id": paywallId,
                "purchase_source": purchaseSource(for: currentPaywallContext()).rawValue
            ]
        )
    }

    func paywallPurchaseSuccess(
        variant: String,
        entryPoint: String,
        packageId: String,
        price: Double?,
        currency: String?,
        transactionId: String?,
        sessionId: String
    ) {
        let paywallId = paywallId(for: variant)
        logEvent(
            "success_Buy",
            explicitOnboardId: resolveOnboardId(nil),
            variant: variant,
            extra: [
                "package_id": packageId,
                "paywall_id": paywallId,
                "purchase_source": purchaseSource(for: currentPaywallContext()).rawValue,
                "place_where_buy": entryPoint,
                "price_paid": price ?? 0,
                "currency": currency ?? "NA",
                "transaction_id": transactionId ?? "",
                "paywall_session_id": sessionId
            ]
        )
    }

    func paywallPurchaseError(
        variant: String,
        entryPoint: String,
        packageId: String,
        rcCode: Int?,
        message: String?,
        sessionId: String
    ) {
        let paywallId = paywallId(for: variant)
        let reasonWhy = normalizeReason(rcCode: rcCode, message: message, fallback: .error)
        logEvent(
            "Paywall_Purchase_Error",
            explicitOnboardId: resolveOnboardId(nil),
            variant: variant,
            extra: [
                "paywall_id": paywallId,
                "package_id": packageId,
                "rc_code": rcCode ?? -1,
                "message": message ?? "",
                "reasonWhy": reasonWhy.rawValue,
                "entry_point": entryPoint,
                "paywall_session_id": sessionId
            ]
        )
    }

    func paywallExposure(flowId: String?, variant: String, entryPoint: String) {
        let resolvedOnboardId = resolveOnboardId(nil)
        var params = assignedPaywallProductParams(onboardId: resolvedOnboardId)
        params.merge([
            "flow_id": flowId ?? "unknown",
            "paywall_id": paywallId(for: variant),
            "entry_point": entryPoint,
            "purchase_source": purchaseSource(for: currentPaywallContext()).rawValue
        ]) { _, new in new }

        logEvent(
            "paywall_exposure",
            explicitOnboardId: resolvedOnboardId,
            variant: variant,
            extra: params
        )
    }

    func paywallCTATap(flowId: String?, variant: String, entryPoint: String, plan: String, paywallId explicitPaywallId: String? = nil) {
        let resolvedOnboardId = resolveOnboardId(nil)
        var params = assignedPaywallProductParams(onboardId: resolvedOnboardId)
        let paywallKey = productSettingsKey(paywallId: explicitPaywallId, variant: variant, onboardId: resolvedOnboardId)
        params.merge(selectedProductParams(paywallKey: paywallKey, onboardId: resolvedOnboardId, plan: plan)) { _, new in new }
        params.merge([
            "flow_id": flowId ?? "unknown",
            "paywall_id": explicitPaywallId ?? paywallId(for: variant),
            "entry_point": entryPoint,
            "plan": plan,
            "purchase_source": purchaseSource(for: currentPaywallContext()).rawValue
        ]) { _, new in new }

        logEvent(
            "paywall_cta_tap",
            explicitOnboardId: resolvedOnboardId,
            variant: variant,
            extra: params
        )
    }

    func purchaseSuccess(flowId: String?, variant: String, plan: String, packageId: String, sessionId: String) {
        let resolvedOnboardId = resolveOnboardId(nil)
        var params = assignedPaywallProductParams(onboardId: resolvedOnboardId)
        let paywallKey = productSettingsKey(paywallId: nil, variant: variant, onboardId: resolvedOnboardId)
        params.merge(selectedProductParams(paywallKey: paywallKey, onboardId: resolvedOnboardId, plan: plan)) { _, new in new }
        params.merge([
            "flow_id": flowId ?? "unknown",
            "plan": plan,
            "product_id": packageId,
            "selected_product_id": packageId,
            "package_id": packageId,
            "paywall_session_id": sessionId,
            "paywall_id": paywallId(for: variant),
            "purchase_source": purchaseSource(for: currentPaywallContext()).rawValue
        ]) { _, new in new }

        logEvent(
            "purchase_success",
            explicitOnboardId: resolvedOnboardId,
            variant: variant,
            extra: params
        )
    }

    func purchaseError(
        flowId: String?,
        variant: String,
        plan: String,
        packageId: String,
        rcCode: Int?,
        message: String?,
        sessionId: String
    ) {
        logEvent(
            "purchase_error",
            explicitOnboardId: resolveOnboardId(nil),
            variant: variant,
            extra: [
                "flow_id": flowId ?? "unknown",
                "plan": plan,
                "package_id": packageId,
                "rc_code": rcCode ?? -1,
                "message": message ?? "",
                "paywall_session_id": sessionId,
                "paywall_id": paywallId(for: variant),
                "purchase_source": purchaseSource(for: currentPaywallContext()).rawValue
            ]
        )
    }

    func paywallExposure(variant: String, entryPoint: String, onboardId: String?) {
        let purchaseSource = purchaseSource(for: currentPaywallContext())
        let resolvedOnboardId = resolveOnboardId(onboardId)
        logEvent(
            "paywall_exposure",
            explicitOnboardId: resolvedOnboardId,
            variant: variant,
            extra: [
                "paywall_id": paywallId(for: variant),
                "entry_point": entryPoint,
                "purchase_source": purchaseSource.rawValue
            ]
        )
    }

    func onboardPaywallOpen(
        variant: String,
        entryPoint: String,
        onboardId: String?,
        paywallId explicitPaywallId: String? = nil,
        weeklyProductId: String? = nil,
        yearlyProductId: String? = nil,
        annualProductId: String? = nil,
        defaultProductId: String,
        displayedPlans: String,
        defaultPlan: String,
        secondaryPlan: String? = nil,
        productVariantId: String? = nil,
        freeTrialEnabled: Bool
    ) {
        let purchaseSource = purchaseSource(for: currentPaywallContext())
        let resolvedOnboardId = resolveOnboardId(onboardId)

        var params: [String: Any] = [
            "paywall_id": explicitPaywallId ?? paywallId(for: variant),
            "entry_point": entryPoint,
            "purchase_source": purchaseSource.rawValue,
            "default_product_id": defaultProductId,
            "displayed_plans": displayedPlans,
            "default_plan": defaultPlan,
            "free_trial_enabled": freeTrialEnabled
        ]

        if let weeklyProductId {
            params["weekly_product_id"] = weeklyProductId
        }
        if let yearlyProductId {
            params["yearly_product_id"] = yearlyProductId
        }
        if let annualProductId {
            params["annual_product_id"] = annualProductId
        }
        if let secondaryPlan {
            params["secondary_plan"] = secondaryPlan
        }
        if let productVariantId {
            params["product_variant_id"] = productVariantId
        }

        logEvent(
            "onboard_paywall_open",
            explicitOnboardId: resolvedOnboardId,
            variant: variant,
            extra: params
        )
    }

    func onboardPaywallOpen(
        variant: String,
        entryPoint: String,
        onboardId: String?,
        paywallId explicitPaywallId: String? = nil,
        paywallKey: String,
        displayedPlans: [String],
        defaultPlan: String
    ) {
        let settings = PaywallAB.shared.productSettings(forKey: paywallKey)
        let normalizedDisplayedPlans = displayedPlans.map { $0.lowercased() }

        func productId(for plan: String) -> String? {
            switch plan.lowercased() {
            case "weekly":
                return settings.weeklyProductID
            case "yearly":
                return settings.yearlyProductID
            case "annual":
                return settings.annualProductID
            default:
                return nil
            }
        }

        let normalizedDefaultPlan = defaultPlan.lowercased()
        let defaultProductId = productId(for: normalizedDefaultPlan) ?? settings.annualProductID
        let secondaryPlan = normalizedDisplayedPlans.first { $0 != normalizedDefaultPlan }

        onboardPaywallOpen(
            variant: variant,
            entryPoint: entryPoint,
            onboardId: onboardId,
            paywallId: explicitPaywallId,
            weeklyProductId: normalizedDisplayedPlans.contains("weekly") ? settings.weeklyProductID : nil,
            yearlyProductId: normalizedDisplayedPlans.contains("yearly") ? settings.yearlyProductID : nil,
            annualProductId: normalizedDisplayedPlans.contains("annual") ? settings.annualProductID : nil,
            defaultProductId: defaultProductId,
            displayedPlans: normalizedDisplayedPlans.joined(separator: ","),
            defaultPlan: normalizedDefaultPlan,
            secondaryPlan: secondaryPlan,
            productVariantId: settings.variantID,
            freeTrialEnabled: settings.freeTest && normalizedDisplayedPlans.contains("weekly")
        )
    }

    func paywallCTATap(
        variant: String,
        entryPoint: String,
        plan: String,
        onboardId: String?,
        paywallId explicitPaywallId: String? = nil
    ) {
        let purchaseSource = purchaseSource(for: currentPaywallContext())
        let resolvedOnboardId = resolveOnboardId(onboardId)
        var params = assignedPaywallProductParams(onboardId: resolvedOnboardId)
        let paywallKey = productSettingsKey(paywallId: explicitPaywallId, variant: variant, onboardId: resolvedOnboardId)
        params.merge(selectedProductParams(paywallKey: paywallKey, onboardId: resolvedOnboardId, plan: plan)) { _, new in new }
        params.merge([
            "paywall_id": explicitPaywallId ?? paywallId(for: variant),
            "entry_point": entryPoint,
            "plan": plan,
            "purchase_source": purchaseSource.rawValue
        ]) { _, new in new }

        logEvent(
            "paywall_cta_tap",
            explicitOnboardId: resolvedOnboardId,
            variant: variant,
            extra: params
        )
    }

    func purchaseSuccess(variant: String, packageId: String, sessionId: String, onboardId: String?) {
        let purchaseSource = purchaseSource(for: currentPaywallContext())
        let resolvedOnboardId = resolveOnboardId(onboardId)
        var params = assignedPaywallProductParams(onboardId: resolvedOnboardId)
        params.merge([
            "product_id": packageId,
            "selected_product_id": packageId,
            "package_id": packageId,
            "paywall_session_id": sessionId,
            "paywall_id": paywallId(for: variant),
            "purchase_source": purchaseSource.rawValue
        ]) { _, new in new }

        logEvent(
            "purchase_success",
            explicitOnboardId: resolvedOnboardId,
            variant: variant,
            extra: params
        )
    }

    func purchaseError(
        variant: String,
        plan: String,
        packageId: String,
        rcCode: Int?,
        message: String?,
        sessionId: String,
        onboardId: String?
    ) {
        let purchaseSource = purchaseSource(for: currentPaywallContext())
        let resolvedOnboardId = resolveOnboardId(onboardId)
        var params = assignedPaywallProductParams(onboardId: resolvedOnboardId)
        let paywallKey = productSettingsKey(paywallId: nil, variant: variant, onboardId: resolvedOnboardId)
        params.merge(selectedProductParams(paywallKey: paywallKey, onboardId: resolvedOnboardId, plan: plan)) { _, new in new }
        params.merge([
            "plan": plan,
            "product_id": packageId,
            "selected_product_id": packageId,
            "package_id": packageId,
            "rc_code": rcCode ?? -1,
            "message": message ?? "",
            "paywall_session_id": sessionId,
            "paywall_id": paywallId(for: variant),
            "purchase_source": purchaseSource.rawValue
        ]) { _, new in new }

        logEvent(
            "purchase_error",
            explicitOnboardId: resolvedOnboardId,
            variant: variant,
            extra: params
        )
    }

    func paywallAOpen() { logRaw("Paywall_A_Open") }
    func paywallBOpen() { logRaw("Paywall_B_Open") }
}

// MARK: - Summary Analytics
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
        var seen = Set<String>()
        let ordered = steps.filter { step in
            if seen.contains(step) { return false }
            seen.insert(step)
            return true
        }

        let resolvedOnboardId = resolveOnboardId(tag.rawValue)
        let resolvedSummaryEventName = self.summaryEventName(for: resolvedOnboardId) ?? tag.summaryEventName
        let stepEventName = "\(resolvedSummaryEventName)_step"

        for (index, step) in ordered.enumerated() {
            logEvent(
                stepEventName,
                explicitOnboardId: resolvedOnboardId,
                variant: variant,
                extra: [
                    "paywall_id": paywallId,
                    "steps": step,
                    "step_index": index + 1,
                    "steps_count": ordered.count
                ]
            )
        }

        var params: [String: Any] = [
            "paywall_id": paywallId,
            "status": status.rawValue,
            "steps_count": ordered.count
        ]
        if let plan, status == .success {
            params["plan"] = plan
        }
        if let reason {
            params["reason"] = reason
        }
        if let entryPoint {
            params["entry_point"] = entryPoint
        }

        logEvent(
            resolvedSummaryEventName,
            explicitOnboardId: resolvedOnboardId,
            variant: variant,
            extra: params
        )
    }

    func modesPaywall(
        status: PaywallStatus,
        plan: String?,
        paywallId: String,
        onboard tag: OnboardTag,
        entryPoint: String? = nil
    ) {
        var params: [String: Any] = [
            "paywall_id": paywallId,
            "status": status.rawValue
        ]
        if let plan, status == .success {
            params["plan"] = plan
        }
        if let entryPoint {
            params["entry_point"] = entryPoint
        }
        logEvent(
            "paywall_summary",
            explicitOnboardId: resolveOnboardId(tag.rawValue),
            extra: params
        )
    }
}

// MARK: - Purchase Success/Error Centralization
extension Telemetry {
    func handleSuccessfulPurchase(
        paywallId: String,
        variant: String,
        entryPoint: String,
        plan: String,
        packageId: String,
        price: Double?,
        currency: String?,
        transactionId: String?,
        explicitPurchaseSource: PurchaseSource?,
        explicitOnboardId: String?,
        selectedDevice: String? = nil,
        placeWhereBuy: String? = nil,
        specialOfferVariant: String? = nil,
        offerText: String? = nil
    ) {
        let purchaseSource = explicitPurchaseSource ?? purchaseSource(for: currentPaywallContext())
        let resolvedOnboardId = resolveOnboardId(explicitOnboardId)
        let brand = brand(fromOnboardId: resolvedOnboardId) ?? presentedOnboardingContext()?.brand

        let txKey = transactionId.map { "\(txSuccessPrefix)\($0)" }
        if let txKey, defaults.bool(forKey: txKey) {
            return
        }
        if let txKey {
            defaults.set(true, forKey: txKey)
        }

        funnelPurchaseSuccess(
            onboardId: resolvedOnboardId ?? "unknown",
            plan: plan,
            productId: packageId,
            purchaseSource: purchaseSource
        )

        let paywallKey = productSettingsKey(paywallId: paywallId, variant: variant, onboardId: resolvedOnboardId)
        let selectedParams = selectedProductParams(paywallKey: paywallKey, onboardId: resolvedOnboardId, plan: plan)

        logEvent(
            "success_Buy",
            explicitOnboardId: resolvedOnboardId,
            explicitBrand: brand,
            variant: variant,
            extra: assignedPaywallProductParams(onboardId: resolvedOnboardId).merging(selectedParams) { _, new in new }.merging([
                "product_id": packageId,
                "selected_product_id": packageId,
                "package_id": packageId,
                "paywall_id": paywallId,
                "plan": plan,
                "purchase_source": purchaseSource.rawValue,
                "selected_device": selectedDevice ?? "",
                "place_where_buy": placeWhereBuy ?? entryPoint,
                "transaction_id": transactionId ?? "",
                "price_paid": price ?? 0,
                "currency": currency ?? "NA"
            ]) { _, new in new }
        )

        logEvent(
            "paywall_summary",
            explicitOnboardId: resolvedOnboardId,
            explicitBrand: brand,
            variant: variant,
            extra: assignedPaywallProductParams(onboardId: resolvedOnboardId).merging(selectedParams) { _, new in new }.merging([
                "paywall_id": paywallId,
                "status": PaywallStatus.success.rawValue,
                "plan": plan,
                "product_id": packageId,
                "selected_product_id": packageId,
                "purchase_source": purchaseSource.rawValue
            ]) { _, new in new }
        )

        syncRevenueCatAttributes(
            onboardId: resolvedOnboardId,
            paywallId: assignedPaywallKey(for: resolvedOnboardId) ?? paywallId
        )
    }

    func handlePurchaseError(
        paywallId: String,
        variant: String,
        entryPoint: String,
        plan: String,
        packageId: String,
        rcCode: Int?,
        message: String?,
        fallbackReason: TelemetryPurchaseFailureReason,
        explicitPurchaseSource: PurchaseSource?,
        explicitOnboardId: String?,
        placeWhereBuy: String? = nil
    ) {
        let purchaseSource = explicitPurchaseSource ?? purchaseSource(for: currentPaywallContext())
        let resolvedOnboardId = resolveOnboardId(explicitOnboardId)
        let reasonWhy = normalizeReason(rcCode: rcCode, message: message, fallback: fallbackReason)
        let paywallKey = productSettingsKey(paywallId: paywallId, variant: variant, onboardId: resolvedOnboardId)
        let selectedParams = selectedProductParams(paywallKey: paywallKey, onboardId: resolvedOnboardId, plan: plan)

        logEvent(
            "Paywall_Purchase_Error",
            explicitOnboardId: resolvedOnboardId,
            variant: variant,
            extra: assignedPaywallProductParams(onboardId: resolvedOnboardId).merging(selectedParams) { _, new in new }.merging([
                "paywall_id": paywallId,
                "product_id": packageId,
                "selected_product_id": packageId,
                "package_id": packageId,
                "plan": plan,
                "rc_code": rcCode ?? -1,
                "message": message ?? "",
                "reasonWhy": reasonWhy.rawValue
            ]) { _, new in new }
        )

        logEvent(
            "paywall_summary",
            explicitOnboardId: resolvedOnboardId,
            variant: variant,
            extra: assignedPaywallProductParams(onboardId: resolvedOnboardId).merging(selectedParams) { _, new in new }.merging([
                "paywall_id": paywallId,
                "status": PaywallStatus.error.rawValue,
                "plan": plan,
                "product_id": packageId,
                "selected_product_id": packageId,
                "purchase_source": purchaseSource.rawValue,
                "reason": reasonWhy.rawValue,
                "place_where_buy": placeWhereBuy ?? entryPoint
            ]) { _, new in new }
        )
    }

    func syncRevenueCatAttributes(onboardId: String?, paywallId: String?) {
        var attributes: [String: String] = [:]
        if let onboardId, !onboardId.isEmpty {
            attributes["onboard_id"] = onboardId
        }
        if let paywallId, !paywallId.isEmpty {
            attributes["paywall_id"] = paywallId
        }
        guard !attributes.isEmpty else { return }
        try? Purchases.shared.attribution.setAttributes(attributes)
    }

    func logTechnicalDeliveryResult(
        deliveryStatus: String,
        txId: String?,
        plan: String,
        event: String,
        subscriptionType: String,
        purchaseSource: PurchaseSource,
        onboardId: String?,
        selectedDevice: String? = nil,
        keyword: String? = nil,
        errorMessage: String? = nil,
        paywallId: String? = nil,
        placeWhereBuy: String? = nil,
        specialOfferVariant: String? = nil
    ) {
        var params: [String: Any] = [
            "delivery_status": deliveryStatus,
            "tx_id": txId ?? "",
            "plan": plan,
            "event": event,
            "subscription_type": subscriptionType,
            "purchase_source": purchaseSource.rawValue
        ]
        if let selectedDevice {
            params["selected_device"] = selectedDevice
        }
        if let keyword {
            params["keyword"] = keyword
        }
        if let errorMessage {
            params["error_message"] = errorMessage
        }
        if let paywallId {
            params["paywall_id"] = paywallId
        }
        if let placeWhereBuy {
            params["place_where_buy"] = placeWhereBuy
        }
        if let specialOfferVariant {
            params["special_offer_variant"] = specialOfferVariant
        }

        logEvent("SuccessBuyTelegram", explicitOnboardId: onboardId, extra: params)
    }
}

// MARK: - Special Offer
extension Telemetry {
    private func specialOfferAnalyticsParams(
        onboardId: String?,
        offerId: String? = nil,
        purchaseSource: PurchaseSource,
        specialOfferVariant: String,
        offerText: String? = nil,
        offerTextEn: String? = nil,
        notificationId: String? = nil,
        extra: [String: Any] = [:]
    ) -> [String: Any] {
        let resolvedOnboardId = resolveOnboardId(onboardId)
        let resolvedBrand = brand(fromOnboardId: resolvedOnboardId) ?? presentedOnboardingContext()?.brand ?? "generic"

        var params: [String: Any] = [
            "purchase_source": purchaseSource.rawValue,
            "special_offer_variant": specialOfferVariant,
            "variant": "special_offer",
            "brand": resolvedBrand,
            "tier": currentTierSuffix
        ]

        if let offerId, !offerId.isEmpty {
            params["offer_id"] = offerId
        }
        if let offerText {
            params["offer_text"] = offerText
        }
        if let offerTextEn {
            params["offer_text_en"] = offerTextEn
        }
        if let notificationId, !notificationId.isEmpty {
            params["notification_id"] = notificationId
        }
        if let onboardFlow = presentedOnboardingContext()?.flowId ?? presentedOnboardingContext()?.flowKey,
           !onboardFlow.isEmpty {
            params["onboard_flow"] = onboardFlow
        }

        extra.forEach { params[$0.key] = $0.value }
        return params
    }

    func specialOfferOpen(
        onboardId: String?,
        variant: String? = nil,
        offerId: String = "special_offer_power",
        specialOfferVariant: String = "power",
        placeWhereOpen: String,
        offerText: String?,
        offerTextEn: String? = nil,
        notificationId: String? = nil
    ) {
        let purchaseSource = specialOfferPurchaseSource(from: placeWhereOpen)
        logEvent(
            "special_offer_open",
            explicitOnboardId: resolveOnboardId(onboardId),
            variant: "special_offer",
            extra: specialOfferAnalyticsParams(
                onboardId: onboardId,
                offerId: offerId,
                purchaseSource: purchaseSource,
                specialOfferVariant: specialOfferVariant,
                offerText: offerText ?? "",
                offerTextEn: offerTextEn,
                notificationId: notificationId,
                extra: ["place_where_open": placeWhereOpen]
            )
        )
    }

    func specialOfferNotificationOpen(
        notificationId: String,
        placeWhereOpen: String,
        offerText: String?,
        offerTextEn: String?,
        onboardId: String?,
        specialOfferVariant: String = "power"
    ) {
        let purchaseSource = specialOfferPurchaseSource(from: placeWhereOpen)
        logEvent(
            "special_offer_notification_open",
            explicitOnboardId: resolveOnboardId(onboardId),
            variant: "special_offer",
            extra: specialOfferAnalyticsParams(
                onboardId: onboardId,
                purchaseSource: purchaseSource,
                specialOfferVariant: specialOfferVariant,
                offerText: offerText ?? "",
                offerTextEn: offerTextEn ?? offerText ?? "",
                notificationId: notificationId,
                extra: ["place_where_open": placeWhereOpen]
            )
        )
    }

    func specialOfferClose(
        onboardId: String?,
        variant: String? = nil,
        specialOfferVariant: String = "power",
        placeWhereClose: String,
        reason: String
    ) {
        let purchaseSource = specialOfferPurchaseSource(from: placeWhereClose)
        logEvent(
            "special_offer_close",
            explicitOnboardId: resolveOnboardId(onboardId),
            variant: "special_offer",
            extra: specialOfferAnalyticsParams(
                onboardId: onboardId,
                purchaseSource: purchaseSource,
                specialOfferVariant: specialOfferVariant,
                extra: [
                    "place_where_close": placeWhereClose,
                    "reason": reason
                ]
            )
        )
    }

    func specialOfferGoToPurchase(
        onboardId: String?,
        variant: String? = nil,
        specialOfferVariant: String = "power",
        placeWhereGo: String,
        offerText: String?,
        plan: String
    ) {
        let purchaseSource = specialOfferPurchaseSource(from: placeWhereGo)
        logEvent(
            "special_offer_go_to_purchase",
            explicitOnboardId: resolveOnboardId(onboardId),
            variant: "special_offer",
            extra: specialOfferAnalyticsParams(
                onboardId: onboardId,
                purchaseSource: purchaseSource,
                specialOfferVariant: specialOfferVariant,
                offerText: offerText ?? "",
                extra: [
                    "place_where_go": placeWhereGo,
                    "plan": plan
                ]
            )
        )
    }

    func specialOfferPurchaseSuccess(
        onboardId: String?,
        variant: String? = nil,
        offerId: String,
        plan: String,
        placeWhereBuy: String,
        offerText: String?,
        offerTextEn: String?,
        purchaseSource: PurchaseSource,
        transactionId: String?,
        specialOfferVariant: String = "power",
        notificationId: String? = nil
    ) {
        logEvent(
            "special_offer_purchase_success",
            explicitOnboardId: resolveOnboardId(onboardId),
            variant: "special_offer",
            extra: specialOfferAnalyticsParams(
                onboardId: onboardId,
                offerId: offerId,
                purchaseSource: purchaseSource,
                specialOfferVariant: specialOfferVariant,
                offerText: offerText ?? "",
                offerTextEn: offerTextEn ?? offerText ?? "",
                notificationId: notificationId,
                extra: [
                    "plan": plan,
                    "place_where_buy": placeWhereBuy,
                    "transaction_id": transactionId ?? ""
                ]
            )
        )
    }

    func specialOfferSuccess(
        onboardId: String?,
        variant: String? = nil,
        specialOfferVariant: String = "power",
        plan: String,
        purchaseSource: PurchaseSource,
        placeWhereBuy: String
    ) {
        logEvent(
            "special_offer_success",
            explicitOnboardId: resolveOnboardId(onboardId),
            variant: "special_offer",
            extra: [
                "special_offer_variant": specialOfferVariant,
                "tier": currentTierSuffix,
                "plan": plan,
                "purchase_source": purchaseSource.rawValue,
                "place_where_buy": placeWhereBuy
            ]
        )
    }

    func specialOfferBuy(placewhereBuy: String?) {
        let purchaseSource = specialOfferPurchaseSource(from: placewhereBuy)
        logEvent(
            "Special_offer_buy",
            explicitOnboardId: resolveOnboardId(nil),
            extra: [
                "place_where_buy": placewhereBuy ?? "",
                "purchase_source": purchaseSource.rawValue
            ]
        )
    }
}

// MARK: - Keywords
extension Telemetry {
    func startKeywordAttributionMeasurement(keywordId: String? = nil, keywordText: String? = nil, source: String = "app_launch") {
        let state = KeywordAttributionState(
            startedAt: Date().timeIntervalSince1970,
            resolvedAt: nil,
            keywordId: keywordId,
            keywordText: keywordText,
            keywordSource: source
        )
        if let data = try? JSONEncoder().encode(state) {
            defaults.set(data, forKey: keywordStateKey)
        }

        var params: [String: Any] = [
            "keyword_source": source,
            "keyword_present": keywordId != nil || keywordText != nil
        ]
        if let keywordId {
            params["keyword_id"] = keywordId
        }
        if let keywordText {
            params["keyword_text"] = keywordText
        }

        logEvent("keywords_log_start", extra: params)
    }

    func keywordsLog(keywordId: String?, keywordText: String?, source: String = "conversion") {
        var params: [String: Any] = [
            "keyword_source": source,
            "keyword_present": keywordId != nil || keywordText != nil
        ]
        if let keywordId, !keywordId.isEmpty {
            params["keyword_id"] = keywordId
        }
        if let keywordText, !keywordText.isEmpty {
            params["keyword_text"] = keywordText
            params["keyword"] = keywordText
        }

        logEvent("keywords_log", extra: params)
        logKeywordResolution(keywordId: keywordId, keywordText: keywordText, source: source, resolvedBy: "appsFlyer")
    }

    func keywordsLogOnStart(keywordId: String?, keywordText: String?) {
        startKeywordAttributionMeasurement(keywordId: keywordId, keywordText: keywordText, source: "stored_on_start")
    }

    func logKeywordResolution(keywordId: String?, keywordText: String?, source: String, resolvedBy: String) {
        let now = Date().timeIntervalSince1970
        let state = keywordAttributionState()
        let elapsedMs = elapsedMilliseconds(from: state?.startedAt ?? now, to: now)
        let elapsedSec = Double(elapsedMs) / 1000
        let elapsedDs = Double(elapsedMs) / 100

        var params: [String: Any] = [
            "keyword_source": source,
            "resolved_by": resolvedBy,
            "keyword_present": keywordId != nil || keywordText != nil,
            "elapsed_ms": elapsedMs,
            "elapsed_ds": elapsedDs,
            "elapsed_sec": elapsedSec,
            "kw_time": keywordTimeBucket(for: elapsedMs)
        ]
        if let keywordId {
            params["keyword_id"] = keywordId
        }
        if let keywordText {
            params["keyword_text"] = keywordText
            params["keyword"] = keywordText
        }

        logEvent("keyword_log_analytics_two", extra: params)
        logEvent("keyword_time_bucket", extra: params)

        let updated = KeywordAttributionState(
            startedAt: state?.startedAt ?? now,
            resolvedAt: now,
            keywordId: keywordId,
            keywordText: keywordText,
            keywordSource: source
        )
        if let data = try? JSONEncoder().encode(updated) {
            defaults.set(data, forKey: keywordStateKey)
        }
    }

    func logKeywordFailure(reason: String, source: String = "conversion") {
        let now = Date().timeIntervalSince1970
        let state = keywordAttributionState()
        let elapsedMs = elapsedMilliseconds(from: state?.startedAt ?? now, to: now)

        logEvent("keyword_fail_time", extra: [
            "keyword_source": source,
            "reason": reason,
            "elapsed_ms": elapsedMs,
            "kw_time": keywordTimeBucket(for: elapsedMs)
        ])
    }
}

// MARK: - Utility / Legacy Raw Events
extension Telemetry {
    func logRaw(_ name: String, params: [String: Any] = [:]) {
        logEvent(name, extra: params)
    }

    func testStart() {
        logRaw("Test_Start")
    }

    func testScreenOpen(_ mode: TestMode) {
        switch mode {
        case .stereo:
            logRaw("Test_StereoView")
        case .bass:
            logRaw("Test_BassView")
        case .micro:
            logRaw("Test_MicroView")
        case .vibro:
            logRaw("Test_VibroView")
        }
    }
}

// MARK: - Private Helpers
private extension Telemetry {
    var europeanCountryCodes: Set<String> {
        [
            "AL", "AD", "AM", "AT", "AZ", "BA", "BE", "BG", "BY", "CH", "CY", "CZ",
            "DE", "DK", "EE", "ES", "FI", "FR", "GB", "GE", "GR", "HR", "HU", "IE",
            "IS", "IT", "KZ", "LI", "LT", "LU", "LV", "MC", "MD", "ME", "MK", "MT",
            "NL", "NO", "PL", "PT", "RO", "RS", "SE", "SI", "SK", "SM", "TR", "UA",
            "VA"
        ]
    }

    func stableBucket(seed: String, modulo: Int) -> Int {
        abs(seed.hashValue) % max(modulo, 1)
    }

    func activeOnboardingFlowId() -> String? {
        guard let data = defaults.data(forKey: activeOnboardingKey),
              let active = try? JSONDecoder().decode(ActiveOnboardingState.self, from: data) else {
            return nil
        }
        return active.flowId
    }

    func activeOnboardingStepId() -> String? {
        guard let data = defaults.data(forKey: activeOnboardingKey),
              let active = try? JSONDecoder().decode(ActiveOnboardingState.self, from: data) else {
            return nil
        }
        return active.stepId
    }

    func pendingOnboardingStart() -> PendingOnboardingStart? {
        guard let data = defaults.data(forKey: pendingOnboardingStartKey) else {
            return nil
        }
        return try? JSONDecoder().decode(PendingOnboardingStart.self, from: data)
    }

    func keywordAttributionState() -> KeywordAttributionState? {
        guard let data = defaults.data(forKey: keywordStateKey) else {
            return nil
        }
        return try? JSONDecoder().decode(KeywordAttributionState.self, from: data)
    }

    func elapsedMilliseconds(from start: TimeInterval, to end: TimeInterval) -> Int {
        Int(max(0, (end - start) * 1000))
    }

    func keywordTimeBucket(for elapsedMs: Int) -> String {
        switch elapsedMs {
        case ..<1000:
            return "<1s"
        case ..<5000:
            return "1_5s"
        case ..<15000:
            return "5_15s"
        case ..<60000:
            return "15_60s"
        default:
            return "60s_plus"
        }
    }

    func normalizeReason(
        rcCode: Int?,
        message: String?,
        fallback: TelemetryPurchaseFailureReason
    ) -> TelemetryPurchaseFailureReason {
        if rcCode == 1 {
            return .userCancelled
        }

        let lowered = (message ?? "").lowercased()
        if lowered.contains("cancel") {
            return .userCancelled
        }
        if lowered.contains("product") && lowered.contains("not found") {
            return .productNotFound
        }
        if lowered.contains("inactive") {
            return .inactiveAfterPurchase
        }
        if lowered.isEmpty {
            return fallback
        }
        return .error
    }

    func summaryEventName(for resolvedOnboardId: String?) -> String? {
        guard let resolvedOnboardId, !resolvedOnboardId.isEmpty else { return nil }
        if let tag = OnboardTag(rawValue: resolvedOnboardId) {
            return tag.summaryEventName
        }

        if resolvedOnboardId.hasSuffix("_4_v1") {
            return "Onboard_branded_v_1"
        }
        if resolvedOnboardId.hasSuffix("_3_v2") {
            return "Onboard_branded_v_2"
        }
        if resolvedOnboardId.hasSuffix("_5_v3") {
            return "Onboard_branded_v_3"
        }
        if resolvedOnboardId.hasSuffix("_5_v4") {
            return "Onboard_branded_v_4"
        }
        return nil
    }
}
