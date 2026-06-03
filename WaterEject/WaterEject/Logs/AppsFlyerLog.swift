//
//  AppsFlyerLog.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 31.10.2025.
//

import Foundation
import RevenueCat
import AppsFlyerLib
import FirebaseRemoteConfig

enum AFEvent: String {
  case install, start_app, subscribe, subscription_started,
       trial_subscribe, trial_success,
       subscription_renewed, subscription_cancelled,
       subscription_refunded, subscription_expired,
       billing_issue_detected, product_change,
       purch, non_subscription_purchase
}

enum AFSubscriptionPeriodKind {
    case trial
    case intro
    case normal
    case promotional
    case unknown
}

enum AFLogMode: String {
    case manual
    case revenuecat
}

struct AF {
    private static let remoteConfigKey = "appsflyer_log"
    private static let defaultLogMode: AFLogMode = .manual

    static func configureRemoteConfigDefaults() {
        RemoteConfig.remoteConfig().setDefaults([
            remoteConfigKey: defaultLogMode.rawValue as NSObject
        ])
    }

    static var logMode: AFLogMode {
        let value = RemoteConfig.remoteConfig()[remoteConfigKey].stringValue
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        return AFLogMode(rawValue: value) ?? defaultLogMode
    }

    static func log(_ e: AFEvent, _ vals: [String: Any] = [:]) {
        guard logMode == .manual else {
            debugSkippedLog(eventName: e.rawValue)
            return
        }

        logRaw(e.rawValue, vals)
    }

    static func logRaw(_ eventName: String, _ vals: [String: Any] = [:]) {
        var payload = vals
        payload["af_user_id"] = Purchases.shared.appUserID
        debugLog(eventName: eventName, payload: payload)
        AppsFlyerLib.shared().logEvent(eventName, withValues: payload)
    }

    static func subscribeValues(
        productId: String,
        revenue: Double,
        currency: String,
        transactionId: String?,
        paywallId: String,
        plan: String
    ) -> [String: Any] {
        [
            "af_revenue": revenue,
            "af_currency": currency,
            "af_content_id": productId,
            "product_id": productId,
            "af_order_id": transactionId ?? "",
            "transaction_id": transactionId ?? "",
            "paywall_id": paywallId,
            "plan": plan,
            "subscription_type": plan,
            "rc_app_user_id": Purchases.shared.appUserID
        ]
    }

    static func trialSubscribeValues(
        productId: String,
        transactionId: String?,
        paywallId: String,
        plan: String
    ) -> [String: Any] {
        [
            "af_content_id": productId,
            "product_id": productId,
            "af_order_id": transactionId ?? "",
            "transaction_id": transactionId ?? "",
            "paywall_id": paywallId,
            "plan": plan,
            "subscription_type": plan,
            "rc_app_user_id": Purchases.shared.appUserID
        ]
    }

    static func trialEligibilityStatus(for product: StoreProduct) async -> IntroEligibilityStatus? {
        guard product.afHasFreeTrialIntroductoryOffer else { return nil }
        return await Purchases.shared.checkTrialOrIntroDiscountEligibility(product: product)
    }

    static func isTrialSubscribe(
        product: StoreProduct,
        entitlement: EntitlementInfo?,
        introEligibilityStatus: IntroEligibilityStatus?
    ) -> Bool {
        if entitlement?.afSubscriptionPeriodKind == .trial {
            return true
        }

        return product.afHasFreeTrialIntroductoryOffer && introEligibilityStatus?.isEligible == true
    }

    private static func debugLog(eventName: String, payload: [String: Any]) {
        #if DEBUG
        let sortedPayload = payload.keys.sorted().reduce(into: [String: Any]()) { result, key in
            result[key] = payload[key]
        }
        print("📈 AF event:", eventName)
        print("   payload:", sortedPayload)
        print("   customerUserID:", AppsFlyerLib.shared().customerUserID ?? "nil")
        #endif
    }

    private static func debugSkippedLog(eventName: String) {
        #if DEBUG
        print("📈 AF event skipped:", eventName, "mode:", logMode.rawValue)
        #endif
    }
}

extension StoreProduct {
    var afCurrencyCode: String {
        if let c = priceFormatter?.currencyCode, !c.isEmpty { return c }
        if #available(iOS 16.0, *), let c = priceFormatter?.locale.currency?.identifier { return c }
        if let c = priceFormatter?.locale.currencyCode { return c }
        if #available(iOS 16.0, *), let c = Locale.current.currency?.identifier { return c }
        return "USD"
    }

    var afPriceDouble: Double {
        (price as NSDecimalNumber).doubleValue
    }

    var afHasFreeTrialIntroductoryOffer: Bool {
        introductoryDiscount?.paymentMode == .freeTrial
    }
}

extension EntitlementInfo {
    var afSubscriptionPeriodKind: AFSubscriptionPeriodKind {
        let rawValue = String(describing: periodType).lowercased()

        if rawValue.contains("trial") {
            return .trial
        }
        if rawValue.contains("intro") {
            return .intro
        }
        if rawValue.contains("promo") {
            return .promotional
        }
        if rawValue.contains("normal") {
            return .normal
        }

        return .unknown
    }
}
