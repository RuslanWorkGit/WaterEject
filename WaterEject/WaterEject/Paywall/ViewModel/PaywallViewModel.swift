//
//  PaywallFirstViewModel.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 07.08.2025.
//

import Foundation
import RevenueCat
import StoreKit

//enum PaywallPlan {
//    case weekly, yearly
//
//    var productID: String {
//        switch self {
//        case .weekly: return "kyryloVoinov.WaterEject.subscription.weekly"
//        case .yearly: return "kyryloVoinov.WaterEject.subscription.yearly"
//        }
//    }
//
//    var price: String {
//        switch self {
//        case .weekly:
//            return " $0.57/day"
//        case .yearly:
//            return " $0.03/day"
//        }
//    }
//
//    var onlyPrice: String {
//        switch self {
//        case .weekly:
//            return "for $3.59"
//        case .yearly:
//            return "for $12.99"
//        }
//    }
//}

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
    func buyWithRevenueCat(plan: PaywallPlan) async {
        guard let pkg = packageByPlan[plan] else {
            errorMessage = "Product not found"
            Telemetry.shared.purchaseError(plan: plan, reason: "product_not_found", error: nil)
            return
        }
        
        isPurchasing = true
        errorMessage = nil
        purchaseSucceeded = false
        Telemetry.shared.purchaseStart(plan: plan)
        defer { isPurchasing = false }
        
        do {
            let result = try await Purchases.shared.purchase(package: pkg)
            let active = result.customerInfo.entitlements[entitlementID]?.isActive == true
            purchaseSucceeded = active
            if active {
                let txId = result.transaction?.transactionIdentifier
                Telemetry.shared.purchaseSuccess(
                    plan: plan,
                    product: pkg.storeProduct,
                    transactionId: txId
                )
            } else {
                errorMessage = "Subscription not active"
                Telemetry.shared.purchaseError(plan: plan, reason: "entitlement_inactive", error: nil)
            }
        } catch {
            let ns = error as NSError
            if let rc = RevenueCat.ErrorCode(_bridgedNSError: ns), rc == .purchaseCancelledError {
                Telemetry.shared.purchaseCancelled(plan: plan)
                return
            }
            errorMessage = ns.localizedDescription
            Telemetry.shared.purchaseError(plan: plan, reason: "revenuecat_error", error: ns)
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
