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
    case weekly, yearly, annual

    var productID: String {
        switch self {
        case .weekly: return "kyryloVoinov.WaterEject.subscription.weekly"
        case .yearly: return "kyryloVoinov.WaterEject.subscription.yearly"
        case .annual: return "KyryloVoinov.WaterEject.lifetime.access"
        }
    }

    var title: String {
        switch self { case .weekly: String(localized: "7 days"); case .yearly: String(localized: "12 months"); case .annual: String(localized: "Annual") }
    }

    var analyticsValue: String { rawValue }

    var j2dEvent: J2DEvent {
        switch self {
        case .weekly, .yearly: return .subscribed
        case .annual: return .purchased
        }
    }

    var j2dType: J2DSubscriptionType {
        switch self {
        case .weekly, .yearly: return .subscription
        case .annual: return .nonConsumable
        }
    }

    var appsFlyerPurchaseEvent: AFEvent {
        switch self {
        case .weekly, .yearly: return .subscribe
        case .annual: return .non_subscription_purchase
        }
    }
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
    @Published private(set) var freeTestEnabled = false

    // Готові рядки для UI
    @Published private(set) var pricePerPeriod: [NewPaywallPlan: String] = [:]
    @Published private(set) var onlyPrice: [NewPaywallPlan: String] = [:]

    private let entitlementID = "pro_user"
    private var productIDByPlan: [NewPaywallPlan: String] = [:]

    // Виклич на .onAppear пейвола
    func loadPricing(paywallVariant: PaywallVariant) async {
        await loadPricing(paywallKey: paywallVariant.rawValue)
    }

    func loadPricing(paywallKey: String) async {
        do {
            let settings = PaywallAB.shared.productSettings(forKey: paywallKey)
            productIDByPlan = [
                .weekly: settings.weeklyProductID,
                .yearly: settings.yearlyProductID,
                .annual: settings.annualProductID
            ]
            freeTestEnabled = settings.freeTest

            let offerings = try await Purchases.shared.offerings()
            guard let current = offerings.current else { return }

            var map: [NewPaywallPlan: Package] = [:]
            let wantedIDs = Set(NewPaywallPlan.allCases.map { productID(for: $0) })
            for pkg in current.availablePackages {
                let id = pkg.storeProduct.productIdentifier
                if wantedIDs.contains(id) {
                    if id == productID(for: .weekly) { map[.weekly] = pkg }
                    if id == productID(for: .yearly)  { map[.yearly]  = pkg }
                    if id == productID(for: .annual)  { map[.annual]  = pkg }
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
                case .weekly: period[plan] = "\(localized)\(String(localized: "/week"))"
                case .yearly: period[plan] = "\(localized)\(String(localized: "/year"))"
                case .annual: period[plan] = localized
                }
                only[plan] = "\(String(localized: "for")) \(localized)"
            }

            // 👇 тепер ОДНИМ махом присвоюємо у @Published
            self.pricePerPeriod = period
            self.onlyPrice      = only
        } catch {
            self.errorMessage = (error as NSError).localizedDescription
        }
    }

    func productID(for plan: NewPaywallPlan) -> String {
        productIDByPlan[plan] ?? plan.productID
    }

    private func shouldSendSubscribeEvent(txId: String?) -> Bool {
        guard let txId, !txId.isEmpty else { return true } // якщо нема txId — хоча б не блокуємо
        let key = "af_subscribe_sent_\(txId)"
        if UserDefaults.standard.bool(forKey: key) { return false }
        UserDefaults.standard.set(true, forKey: key)
        return true
    }

    // Купівля: краще купувати по package (RC сам розрулить SK1/SK2)
    func buyWithRevenueCat(
        plan: NewPaywallPlan,
        variant: String,
        entryPoint: String,
        sessionId: String,
        onboardId: String?,
        paywallId: String
    ) async -> TelemetryPurchaseAttemptResult {
        guard !isPurchasing else {
            return TelemetryPurchaseAttemptResult(
                status: .failed,
                packageId: productID(for: plan),
                transactionId: nil,
                rcCode: nil,
                message: "Purchase already in progress",
                reasonWhy: .unknown
            )
        }

        guard let pkg = packageByPlan[plan] else {
            errorMessage = "Product not found"
            Telemetry.shared.handlePurchaseError(
                paywallId: paywallId,
                variant: variant,
                entryPoint: entryPoint,
                plan: plan.analyticsValue,
                packageId: productID(for: plan),
                rcCode: -2,
                message: "Product not found",
                fallbackReason: .productNotFound,
                explicitPurchaseSource: nil,
                explicitOnboardId: onboardId
            )
            return TelemetryPurchaseAttemptResult(
                status: .failed,
                packageId: productID(for: plan),
                transactionId: nil,
                rcCode: -2,
                message: "Product not found",
                reasonWhy: .productNotFound
            )
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
        let afCurrency = p.afCurrencyCode

        Telemetry.shared.purchaseStart(
            variant: variant,
            packageId: p.productIdentifier,
            offeringId: pkg.identifier,
            price: price,
            currency: currency,
            sessionId: sessionId,
            paywallId: paywallId,
            onboardId: onboardId
        )

        do {
            let result = try await Purchases.shared.purchase(package: pkg)
            let active = result.customerInfo.entitlements[entitlementID]?.isActive == true
            purchaseSucceeded = active

            if active {
                let txId = result.transaction?.transactionIdentifier
                let resolvedOnboardId = Telemetry.shared.resolveOnboardId(onboardId)
                let purchaseSource = Telemetry.shared.resolvedPurchaseSource(for: nil)

                if shouldSendJ2DEvent(txId: txId, suffix: plan.j2dEvent.rawValue) {
                    Task {
                        do {
                            try await J2DSubscriptionReporter.shared.sendSubscriptionEvent(
                                platform: .watereject,
                                userId: Purchases.shared.appUserID,
                                event: plan.j2dEvent,
                                type: plan.j2dType,
                                plan: plan.rawValue,
                                purchaseSource: purchaseSource.rawValue,
                                onboardId: resolvedOnboardId,
                                paywallId: paywallId
                            )
                            Telemetry.shared.logTechnicalDeliveryResult(
                                deliveryStatus: "success",
                                txId: txId,
                                plan: plan.rawValue,
                                event: plan.j2dEvent.rawValue,
                                subscriptionType: plan.j2dType.rawValue,
                                purchaseSource: purchaseSource,
                                onboardId: resolvedOnboardId,
                                paywallId: paywallId
                            )
                        } catch {
                            Telemetry.shared.logTechnicalDeliveryResult(
                                deliveryStatus: "error",
                                txId: txId,
                                plan: plan.rawValue,
                                event: plan.j2dEvent.rawValue,
                                subscriptionType: plan.j2dType.rawValue,
                                purchaseSource: purchaseSource,
                                onboardId: resolvedOnboardId,
                                errorMessage: error.localizedDescription,
                                paywallId: paywallId
                            )
                        }
                    }
                }

                if shouldSendSubscribeEvent(txId: txId) {
                    AF.log(
                        plan.appsFlyerPurchaseEvent,
                        AF.subscribeValues(
                            productId: p.productIdentifier,
                            revenue: price,
                            currency: afCurrency,
                            transactionId: txId,
                            paywallId: paywallId,
                            plan: plan.analyticsValue
                        )
                    )
                }

                let cpaFlag = "af_subscribe_cpa_sent\(Purchases.shared.appUserID)"
                if plan.j2dType == .subscription, !UserDefaults.standard.bool(forKey: cpaFlag) {
                    AF.log(
                        .subscribe_cpa,
                        AF.subscribeCPAValues(
                            productId: p.productIdentifier,
                            revenue: p.afPriceDouble,
                            currency: afCurrency,
                            transactionId: txId
                        )
                    )
                    UserDefaults.standard.set(true, forKey: cpaFlag)
                }

                SubscriptionMonitor.shared.process(customerInfo: result.customerInfo)
                RCPriceCache.save(entitlementID: "pro_user", price: price, currency: afCurrency)

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
            }

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
        } catch {
            let ns = error as NSError
            let rcCode = ns.userInfo["RCErrorCodeKey"] as? Int
            let fallbackReason: TelemetryPurchaseFailureReason = (rcCode == 1) ? .userCancelled : .error
            errorMessage = ns.localizedDescription

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

    private func shouldSendJ2DEvent(txId: String?, suffix: String) -> Bool {
        guard let txId, !txId.isEmpty else { return true }
        let key = "j2d_sent_\(suffix)_\(txId)"
        if UserDefaults.standard.bool(forKey: key) { return false }
        UserDefaults.standard.set(true, forKey: key)
        return true
    }
}
