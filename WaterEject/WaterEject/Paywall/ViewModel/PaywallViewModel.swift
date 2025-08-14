//
//  PaywallFirstViewModel.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 07.08.2025.
//

import Foundation
import RevenueCat
import StoreKit

enum PaywallPlan {
    case weekly, yearly

    var productID: String {
        switch self {
        case .weekly: return "kyryloVoinov.WaterEject.subscription.weekly"
        case .yearly: return "kyryloVoinov.WaterEject.subscription.yearly"
        }
    }
    
    var price: String {
        switch self {
        case .weekly:
            return " $0.57/day"
        case .yearly:
            return " $0.03/day"
        }
    }
    
    var onlyPrice: String {
        switch self {
        case .weekly:
            return "only $0.57/day"
        case .yearly:
            return "only $0.03/day"
        }
    }
}

@MainActor
final class PaywallViewModel: ObservableObject {

    // опційно: для UX у кнопці
    @Published var isPurchasing = false
    @Published var purchaseSucceeded = false
    @Published var errorMessage: String?
    @Published var selectedPlan: PaywallPlan = .yearly

    private let entitlementID = "pro_user"

    /// Купівля обраного плану через RevenueCat
    func buyWithRevenueCat(plan: PaywallPlan) async {
        isPurchasing = true
        errorMessage = nil
        purchaseSucceeded = false
        defer { isPurchasing = false }

        do {
            // products() у RC не кидає — без try
            let products = await Purchases.shared.products([plan.productID])
            guard let product = products.first else {
                errorMessage = "Product not found"
                return
            }

            let result = try await Purchases.shared.purchase(product: product)
            purchaseSucceeded = result.customerInfo.entitlements[entitlementID]?.isActive == true
            if !purchaseSucceeded { errorMessage = "Subscription not active" }
        } catch {
            let nsError = error as NSError

            // користувач скасував — не показуємо помилку
            if let rc = RevenueCat.ErrorCode(_bridgedNSError: nsError), rc == .purchaseCancelledError { return }
            if let sk1 = error as? SKError, sk1.code == .paymentCancelled { return }
            if #available(iOS 15.0, *), let sk2 = error as? StoreKitError, case .userCancelled = sk2 { return }

            errorMessage = nsError.localizedDescription
        }
    }

    /// Відновлення покупок (щоб кнопка Restore працювала)
    func restorePurchases() async {
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            let info = try await Purchases.shared.restorePurchases()
            purchaseSucceeded = info.entitlements[entitlementID]?.isActive == true
            if !purchaseSucceeded { errorMessage = "No previous purchases found." }
        } catch {
            errorMessage = (error as NSError).localizedDescription
        }
    }

    func closePaywall() {
        print("Close paywall")
    }
}

