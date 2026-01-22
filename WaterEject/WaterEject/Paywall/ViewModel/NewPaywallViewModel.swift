//
//  NewPaywallViewModel.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 20.11.2025.
//



import Foundation
import RevenueCat
import StoreKit


enum NewPaywallPlan: String, CaseIterable, Hashable {
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
final class NewPaywallViewModel: ObservableObject {
    @Published var isPurchasing = false
    @Published var purchaseSucceeded = false
    @Published var errorMessage: String?
    @Published var selectedPlan: NewPaywallPlan = .weekly
    
    // Мапа план → Package/StoreProduct
    @Published private(set) var packageByPlan: [NewPaywallPlan: Package] = [:]
    
    // Готові рядки для UI
    @Published private(set) var pricePerPeriod: [NewPaywallPlan: String] = [:] // "$3.99/week", "$12.99/year"
    @Published private(set) var onlyPrice: [NewPaywallPlan: String] = [:]      // "for $3.99", "for $12.99"
    
    private let entitlementID = "pro_user"
    
    // Виклич на .onAppear пейвола
    func loadPricing() async {
        do {
            let offerings = try await Purchases.shared.offerings()
            guard let current = offerings.current else { return }
            
            var map: [NewPaywallPlan: Package] = [:]
            let wantedIDs = Set(NewPaywallPlan.allCases.map { $0.productID })
            for pkg in current.availablePackages {
                let id = pkg.storeProduct.productIdentifier
                if wantedIDs.contains(id) {
                    if id == NewPaywallPlan.weekly.productID { map[.weekly] = pkg }
                    if id == NewPaywallPlan.yearly.productID  { map[.yearly]  = pkg }
                }
            }
            self.packageByPlan = map
            
            // заповнюємо локальні словники
            var period: [NewPaywallPlan: String] = [:]
            var only:   [NewPaywallPlan: String] = [:]
            
            
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
    
    private func shouldSendSubscribeEvent(txId: String?) -> Bool {
        guard let txId, !txId.isEmpty else { return true } // якщо нема txId — хоча б не блокуємо
        let key = "af_subscribe_sent_\(txId)"
        if UserDefaults.standard.bool(forKey: key) { return false }
        UserDefaults.standard.set(true, forKey: key)
        return true
    }
    
    // Купівля: краще купувати по package (RC сам розрулить SK1/SK2)
    func buyWithRevenueCat(plan: NewPaywallPlan, variant: String, entryPoint: String, sessionId: String, onboardId: String?, paywallId: String) async {
        guard !isPurchasing else { return }
        //let paywallId = "paywall_v_3.0"
        guard let pkg = packageByPlan[plan] else {
            errorMessage = "Product not found"
            Telemetry.shared.purchaseResult(
                variant: variant, status: "error", rcCode: -2,
                packageId: plan.productID, pricePaid: nil, currency: nil, sessionId: sessionId, onboardId: onboardId, paywallId: paywallId
            )
            return
        }
        
        isPurchasing = true
        defer { isPurchasing = false }
        
        errorMessage = nil
        purchaseSucceeded = false

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
                let tx = result.transaction
                let txId = result.transaction?.transactionIdentifier
  
                
                if shouldSendSubscribeEvent(txId: txId) {
                    AF.log(.subscribe, [
                      "af_revenue": price,
                      "af_currency": currency ?? "USD",
                      "af_content_id": p.productIdentifier,
                      "af_order_id": txId ?? "",
                      "transaction_id": txId ?? "",
                      "paywall_id": paywallId,
                      "plan": plan.analyticsValue,
                      "rc_app_user_id": Purchases.shared.appUserID
                    ])

                }
                
                
//                AF.log(.subscribe, [
//                  "af_revenue": price,               // Double
//                  "af_currency": currency ?? "USD",
//                  "af_content_id": p.productIdentifier,
//                  "cpa_value": 0
//                ])
                
                let planId = plan.analyticsValue

//                if let onboardId = onboardId {
//                    Telemetry.shared.funnelPurchaseSuccess(
//                        onboardId: onboardId,
//                        plan: planId
//                    )
//                }
                
                let resolvedOnboardId = onboardId ?? OnboardTag.lastFromUserDefaults()?.rawValue ?? "unknown"
                Telemetry.shared.funnelPurchaseSuccess(
                    onboardId: resolvedOnboardId,
                    plan: planId
                )
                
                let cpaFlag = "af_subscribe_cpa_sent\(Purchases.shared.appUserID)"
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

            } else {
                errorMessage = "Subscription not active"
//                Telemetry.shared.purchaseResult(
//                    variant: variant, status: "error", rcCode: -3,
//                    packageId: p.productIdentifier, pricePaid: nil, currency: currency,
//                    sessionId: sessionId, onboardId: onboardId, paywallId: paywallId
//                )
                

            }
        } catch {
            let ns = error as NSError
            let rcCode = ns.userInfo["RCErrorCodeKey"] as? Int
            let status = (rcCode == 1) ? "user_cancelled" : "error"
            errorMessage = ns.localizedDescription
//            Telemetry.shared.purchaseResult(
//                variant: variant, status: status, rcCode: rcCode,
//                packageId: p.productIdentifier, pricePaid: nil, currency: currency,
//                sessionId: sessionId, onboardId: onboardId, paywallId: paywallId
//            )
            if status == "error" {
//                Telemetry.shared.paywallPurchaseError(
//                        variant: variant,
//                        entryPoint: entryPoint,
//                        packageId: p.productIdentifier,
//                        rcCode: rcCode,
//                        message: ns.localizedDescription,
//                        sessionId: sessionId
//                    )
            }
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
