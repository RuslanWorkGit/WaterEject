//
//  PaywallFirstViewModel.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 07.08.2025.
//

import Foundation
import RevenueCat
import StoreKit


enum PaywallPlan: String, CaseIterable, Hashable {
    case weekly, yearly
    
    var productID: String {
        switch self {
        case .weekly: return "kyryloVoinov.WaterEject.subscription.weekly"
        case .yearly: return "kyryloVoinov.WaterEject.subscription.yearly"
        }
    }
    
    var title: String {
        switch self { case .weekly: "7 days"; case .yearly: "12 months" }
    }
    
    var analyticsValue: String { rawValue }
}

import Foundation
import RevenueCat
import FirebaseAnalytics

@MainActor
final class PaywallViewModel: ObservableObject {
    @Published var isPurchasing = false
    @Published var purchaseSucceeded = false
    @Published var errorMessage: String?
    @Published var selectedPlan: PaywallPlan = .yearly
    
    // Мапа план → Package/StoreProduct
    @Published private(set) var packageByPlan: [PaywallPlan: Package] = [:]
    
    // Готові рядки для UI
    @Published private(set) var pricePerPeriod: [PaywallPlan: String] = [:] // "$3.99/week", "$12.99/year"
    @Published private(set) var onlyPrice: [PaywallPlan: String] = [:]      // "for $3.99", "for $12.99"
    
    private let entitlementID = "pro_user"

    private func shouldSendSubscribeEvent(txId: String?) -> Bool {
        guard let txId, !txId.isEmpty else { return true }
        let key = "af_subscribe_sent_\(txId)"
        if UserDefaults.standard.bool(forKey: key) { return false }
        UserDefaults.standard.set(true, forKey: key)
        return true
    }

    private func shouldSendJ2DEvent(txId: String?, suffix: String) -> Bool {
        guard let txId, !txId.isEmpty else { return true }
        let key = "j2d_sent_\(suffix)_\(txId)"
        if UserDefaults.standard.bool(forKey: key) { return false }
        UserDefaults.standard.set(true, forKey: key)
        return true
    }
    
    // Виклич на .onAppear пейвола
    func loadPricing() async {
        do {
            let offerings = try await Purchases.shared.offerings()
            guard let current = offerings.current else { return }
            
            var map: [PaywallPlan: Package] = [:]
            let wantedIDs = Set(PaywallPlan.allCases.map { $0.productID })
            for pkg in current.availablePackages {
                let id = pkg.storeProduct.productIdentifier
                if wantedIDs.contains(id) {
                    if id == PaywallPlan.weekly.productID { map[.weekly] = pkg }
                    if id == PaywallPlan.yearly.productID  { map[.yearly]  = pkg }
                }
            }
            self.packageByPlan = map
            
            // заповнюємо локальні словники
            var period: [PaywallPlan: String] = [:]
            var only:   [PaywallPlan: String] = [:]
            
            
            for (plan, pkg) in map {
                let p = pkg.storeProduct
                let localized = p.localizedPriceString
                switch plan {
                case .weekly: period[plan] = "\(localized)/week"
                case .yearly: period[plan] = "\(localized)/year"
                }
                only[plan]   = "for \(localized)"
            }
            
            // 👇 тепер ОДНИМ махом присвоюємо у @Published
            self.pricePerPeriod = period
            self.onlyPrice      = only
        } catch {
            self.errorMessage = (error as NSError).localizedDescription
        }
    }
    
    
    // Купівля: краще купувати по package (RC сам розрулить SK1/SK2)
    func buyWithRevenueCat(
        plan: PaywallPlan,
        variant: String,
        entryPoint: String,
        sessionId: String,
        onboardId: String?,
        paywallId: String
    ) async -> TelemetryPurchaseAttemptResult {
        guard let pkg = packageByPlan[plan] else {
            errorMessage = "Product not found"
            Telemetry.shared.handlePurchaseError(
                paywallId: paywallId,
                variant: variant,
                entryPoint: entryPoint,
                plan: plan.analyticsValue,
                packageId: plan.productID,
                rcCode: -2,
                message: "Product not found",
                fallbackReason: .productNotFound,
                explicitPurchaseSource: nil,
                explicitOnboardId: onboardId
            )
            return TelemetryPurchaseAttemptResult(
                status: .failed,
                packageId: plan.productID,
                transactionId: nil,
                rcCode: -2,
                message: "Product not found",
                reasonWhy: .productNotFound
            )
        }
        
        isPurchasing = true
        errorMessage = nil
        purchaseSucceeded = false

        defer { isPurchasing = false }
        
        let p = pkg.storeProduct
        let price = (p.price as? NSNumber)?.doubleValue
        ?? (p.price as? NSDecimalNumber)?.doubleValue
        ?? 0
        let currency = p.currencyCode
        
        Telemetry.shared.purchaseStart(
            variant: variant,
            packageId: p.productIdentifier,
            offeringId: pkg.identifier,
            price: price,
            currency: currency,
            sessionId: sessionId
        )
        
        do {
            let result = try await Purchases.shared.purchase(package: pkg)
            let active = result.customerInfo.entitlements[entitlementID]?.isActive == true
            purchaseSucceeded = active
            if active {
                let txId = result.transaction?.transactionIdentifier
                AF.log(.subscribe, [
                  "af_revenue": price,               // Double
                  "af_currency": currency ?? "USD",
                  "af_content_id": p.productIdentifier,
                  "cpa_value": 0
                ])

                if shouldSendJ2DEvent(txId: txId, suffix: "subscribed") {
                    let resolvedOnboardId = Telemetry.shared.resolveOnboardId(onboardId)
                    let purchaseSource = Telemetry.shared.resolvedPurchaseSource(for: nil)
                    Task {
                        do {
                            try await J2DSubscriptionReporter.shared.sendSubscriptionEvent(
                                platform: .watereject,
                                userId: Purchases.shared.appUserID,
                                event: .subscribed,
                                type: .subscription,
                                plan: plan.rawValue,
                                purchaseSource: purchaseSource.rawValue,
                                onboardId: resolvedOnboardId,
                                paywallId: paywallId
                            )
                            Telemetry.shared.logTechnicalDeliveryResult(
                                deliveryStatus: "success",
                                txId: txId,
                                plan: plan.rawValue,
                                event: J2DEvent.subscribed.rawValue,
                                subscriptionType: J2DSubscriptionType.subscription.rawValue,
                                purchaseSource: purchaseSource,
                                onboardId: resolvedOnboardId,
                                paywallId: paywallId
                            )
                        } catch {
                            Telemetry.shared.logTechnicalDeliveryResult(
                                deliveryStatus: "error",
                                txId: txId,
                                plan: plan.rawValue,
                                event: J2DEvent.subscribed.rawValue,
                                subscriptionType: J2DSubscriptionType.subscription.rawValue,
                                purchaseSource: purchaseSource,
                                onboardId: resolvedOnboardId,
                                errorMessage: error.localizedDescription,
                                paywallId: paywallId
                            )
                        }
                    }
                }
                
                let cpaFlag = "af_subscribe_cpa_sent \(Purchases.shared.appUserID)"
                    if !UserDefaults.standard.bool(forKey: cpaFlag) {
                        AppsFlyerLib.shared().logEvent("subscribe_cpa", withValues: [
                            "cpa_value": p.afPriceDouble,        // твоя CPA-ціль (можеш підставити інше число)
                            "af_currency": p.afCurrencyCode,
                            "product_id": p.productIdentifier,
                            "transaction_id": txId
                        ])
                        UserDefaults.standard.set(true, forKey: cpaFlag)
                    }
                
                SubscriptionMonitor.shared.process(customerInfo: result.customerInfo)
                
                RCPriceCache.save(entitlementID: "pro_user", price: price, currency: currency ?? "USD")

                Telemetry.shared.handleSuccessfulPurchase(
                    paywallId: paywallId,
                    variant: variant,
                    entryPoint: entryPoint,
                    plan: plan.analyticsValue,
                    packageId: p.productIdentifier,
                    price: price,
                    currency: currency,
                    transactionId: txId,
                    explicitPurchaseSource: nil,
                    explicitOnboardId: onboardId
                )

                return TelemetryPurchaseAttemptResult(
                    status: .success,
                    packageId: p.productIdentifier,
                    transactionId: txId,
                    rcCode: nil,
                    message: nil,
                    reasonWhy: nil
                )

            } else {
                errorMessage = "Subscription not active"
                Telemetry.shared.handlePurchaseError(
                    paywallId: paywallId,
                    variant: variant,
                    entryPoint: entryPoint,
                    plan: plan.analyticsValue,
                    packageId: p.productIdentifier,
                    rcCode: -3,
                    message: "Subscription not active",
                    fallbackReason: .inactiveAfterPurchase,
                    explicitPurchaseSource: nil,
                    explicitOnboardId: onboardId
                )
                return TelemetryPurchaseAttemptResult(
                    status: .failed,
                    packageId: p.productIdentifier,
                    transactionId: result.transaction?.transactionIdentifier,
                    rcCode: -3,
                    message: "Subscription not active",
                    reasonWhy: .inactiveAfterPurchase
                )
            }
        } catch {
            let ns = error as NSError
            let rcCode = ns.userInfo["RCErrorCodeKey"] as? Int
            errorMessage = ns.localizedDescription
            let fallbackReason: TelemetryPurchaseFailureReason = (rcCode == 1) ? .userCancelled : .error
            Telemetry.shared.handlePurchaseError(
                paywallId: paywallId,
                variant: variant,
                entryPoint: entryPoint,
                plan: plan.analyticsValue,
                packageId: p.productIdentifier,
                rcCode: rcCode,
                message: ns.localizedDescription,
                fallbackReason: fallbackReason,
                explicitPurchaseSource: nil,
                explicitOnboardId: onboardId
            )
            return TelemetryPurchaseAttemptResult(
                status: (rcCode == 1) ? .cancelled : .failed,
                packageId: p.productIdentifier,
                transactionId: nil,
                rcCode: rcCode,
                message: ns.localizedDescription,
                reasonWhy: fallbackReason
            )
        }
    }
    
    
    func restorePurchases() async {
        isPurchasing = true
        Telemetry.shared.restoreStart()
        defer { isPurchasing = false }
        
        do {
            let info = try await Purchases.shared.restorePurchases()
            let active = info.entitlements[entitlementID]?.isActive == true
            purchaseSucceeded = active
            if !active { errorMessage = "No previous purchases found." }
            Telemetry.shared.restoreSuccess(entitlementActive: active)
        } catch {
            let ns = error as NSError
            errorMessage = ns.localizedDescription
            Telemetry.shared.restoreError(ns)
        }
    }
}

import AppsFlyerLib

private extension StoreProduct {
    var afCurrencyCode: String {
        if let c = priceFormatter?.currencyCode, !c.isEmpty { return c }
        if #available(iOS 16.0, *), let c = priceFormatter?.locale.currency?.identifier { return c }
        if let c = priceFormatter?.locale.currencyCode { return c }
        if #available(iOS 16.0, *), let c = Locale.current.currency?.identifier { return c }
        return "USD"
    }
    var afPriceDouble: Double { (price as NSDecimalNumber).doubleValue }
}
