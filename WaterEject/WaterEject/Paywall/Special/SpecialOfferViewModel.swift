//
//  SpecialOfferViewModel.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 03.12.2025.
//

import Foundation
import RevenueCat
import StoreKit
import FirebaseAnalytics
import AppsFlyerLib

enum SpecialPlan: String, CaseIterable, Hashable {
    case weekly
    
    var productID: String {
        switch self {
        case .weekly: return "kyryloVoinov.WaterEject.subscription.weeklyPecialOffer"
        }
    }
    
    var title: String {
        switch self { case .weekly: String(localized: "7 days") }
    }
    
    var analyticsValue: String { rawValue }
}


@MainActor
final class SpecialOfferViewModel: ObservableObject {
    
    @Published var isPurchasing = false
    @Published var purchaseSucceeded = false
    @Published var errorMessage: String?
    
    // працюємо тільки з weekly планом
    private let plan: SpecialPlan = .weekly
    
    // Package для weekly
    @Published private(set) var weeklyPackage: Package?
    
    // Текст для UI
    @Published private(set) var weeklyPricePerPeriod: String = ""   // "$2.99/week"
    @Published private(set) var weeklyOnlyPrice: String = ""        // "for $2.99"
    @Published private(set) var weeklyFullPrice: String = ""
    
    // Таймер до кінця дня
    @Published private(set) var countdownText: String = ""
    @Published private(set) var hoursText: String   = "00"
    @Published private(set) var minutesText: String = "00"
    @Published private(set) var secondsText: String = "00"
    
    private let entitlementID = "pro_user"
    private var timer: Timer?
    private var productID: String = SpecialPlan.weekly.productID
    
    init() {
        updateCountdown()
        startTimer()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    // MARK: - Pricing
    
    func loadPricing() async {
        do {
            productID = PaywallAB.shared.productSettings(forKey: "special").weeklyProductID
            let offerings = try await Purchases.shared.offerings()
            guard let current = offerings.current else { return }

            let wantedID = productID
            guard let pkg = current.availablePackages.first(
                where: { $0.storeProduct.productIdentifier == wantedID }
            ) else { return }

            self.weeklyPackage = pkg
            let p = pkg.storeProduct

            // 1) Першим ділом пробуємо взяти Introductory Offer
            var displayPrice: String

            if let intro = p.introductoryDiscount {
                // тут уже відформатований локалізований прайс з інтро-офера (2.99)
                displayPrice = intro.localizedPriceString
                print("INTRO PRICE = \(displayPrice)")
            } else {
                // якщо інтро немає/не налаштоване – показуємо базову (4.99)
                displayPrice = p.localizedPriceString
                print("BASE PRICE = \(displayPrice)")
            }
            
            var fullPrice = p.localizedPriceString

            weeklyPricePerPeriod = "\(displayPrice)\(String(localized: "/week"))"
            weeklyOnlyPrice      = "\(displayPrice)"
            weeklyFullPrice      = "\(fullPrice)"

        } catch {
            self.errorMessage = (error as NSError).localizedDescription
        }
    }

    
    // MARK: - Timer
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateCountdown()
            }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    private func updateCountdown() {
            let calendar = Calendar.current
            let now = Date()
            let startOfTomorrow = calendar.startOfDay(for: now.addingTimeInterval(24 * 60 * 60))
            let diff = max(0, startOfTomorrow.timeIntervalSince(now))

            if diff <= 0 {
                countdownText = "Offer ends soon"
                hoursText   = "00"
                minutesText = "00"
                secondsText = "00"
                return
            }

            let totalSeconds = Int(diff)
            let hours   = totalSeconds / 3600
            let minutes = (totalSeconds % 3600) / 60
            let seconds = totalSeconds % 60

            countdownText = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
            hoursText   = String(format: "%02d", hours)
            minutesText = String(format: "%02d", minutes)
            secondsText = String(format: "%02d", seconds)
        }
    
    // MARK: - Purchase
    
    private func shouldSendSubscribeEvent(txId: String?) -> Bool {
        guard let txId, !txId.isEmpty else { return true } // якщо нема txId — хоча б не блокуємо
        let key = "af_subscribe_sent_\(txId)"
        if UserDefaults.standard.bool(forKey: key) { return false }
        UserDefaults.standard.set(true, forKey: key)
        return true
    }
    
    func buySpecialOffer(
        variant: String,
        entryPoint: String,
        sessionId: String,
        placeWhereBuy: String?,
        paywallId: String      // наприклад "special_offer_v_1.0"
    ) async -> TelemetryPurchaseAttemptResult {
        guard !isPurchasing else {
            return TelemetryPurchaseAttemptResult(
                status: .failed,
                packageId: productID,
                transactionId: nil,
                rcCode: nil,
                message: "Purchase already in progress",
                reasonWhy: .unknown
            )
        }
        guard let pkg = weeklyPackage else {
            errorMessage = "Product not found"
            Telemetry.shared.handlePurchaseError(
                paywallId: paywallId,
                variant: variant,
                entryPoint: entryPoint,
                plan: plan.analyticsValue,
                packageId: productID,
                rcCode: -2,
                message: "Product not found",
                fallbackReason: .productNotFound,
                explicitPurchaseSource: Telemetry.shared.resolvedSpecialOfferPurchaseSource(from: placeWhereBuy),
                explicitOnboardId: OnboardTag.lastFromUserDefaults()?.rawValue,
                placeWhereBuy: placeWhereBuy
            )
            return TelemetryPurchaseAttemptResult(
                status: .failed,
                packageId: productID,
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
        
        
        do {
            let result = try await Purchases.shared.purchase(package: pkg)
            let active = result.customerInfo.entitlements[entitlementID]?.isActive == true
            purchaseSucceeded = active
            
            if active {
                let txId = result.transaction?.transactionIdentifier
                let purchaseSource = Telemetry.shared.resolvedSpecialOfferPurchaseSource(from: placeWhereBuy)
                let resolvedOnboardId = Telemetry.shared.resolveOnboardId(OnboardTag.lastFromUserDefaults()?.rawValue)

                if shouldSendJ2DEvent(txId: txId, suffix: "special_offer_subscribed") {
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
                                paywallId: paywallId,
                                placeWhereBuy: placeWhereBuy,
                                specialOfferVariant: "special_offer_v_1"
                            )
                            Telemetry.shared.logTechnicalDeliveryResult(
                                deliveryStatus: "success",
                                txId: txId,
                                plan: plan.rawValue,
                                event: "special_offer_\(J2DEvent.subscribed.rawValue)",
                                subscriptionType: J2DSubscriptionType.subscription.rawValue,
                                purchaseSource: purchaseSource,
                                onboardId: resolvedOnboardId,
                                paywallId: paywallId,
                                placeWhereBuy: placeWhereBuy,
                                specialOfferVariant: "special_offer_v_1"
                            )
                        } catch {
                            Telemetry.shared.logTechnicalDeliveryResult(
                                deliveryStatus: "error",
                                txId: txId,
                                plan: plan.rawValue,
                                event: "special_offer_\(J2DEvent.subscribed.rawValue)",
                                subscriptionType: J2DSubscriptionType.subscription.rawValue,
                                purchaseSource: purchaseSource,
                                onboardId: resolvedOnboardId,
                                errorMessage: error.localizedDescription,
                                paywallId: paywallId,
                                placeWhereBuy: placeWhereBuy,
                                specialOfferVariant: "special_offer_v_1"
                            )
                        }
                    }
                }
                
                if shouldSendSubscribeEvent(txId: txId) {
                    AF.log(
                        .subscribe,
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
                if !UserDefaults.standard.bool(forKey: cpaFlag) {
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
                RCPriceCache.save(entitlementID: entitlementID, price: price, currency: afCurrency)
                
                Telemetry.shared.handleSuccessfulPurchase(
                    paywallId: paywallId,
                    variant: variant,
                    entryPoint: entryPoint,
                    plan: plan.analyticsValue,
                    packageId: p.productIdentifier,
                    price: price,
                    currency: currency,
                    transactionId: txId,
                    explicitPurchaseSource: purchaseSource,
                    explicitOnboardId: resolvedOnboardId,
                    placeWhereBuy: placeWhereBuy,
                    specialOfferVariant: "special_offer_v_1",
                    offerText: nil
                )
                Telemetry.shared.specialOfferSuccess(
                    onboardId: resolvedOnboardId,
                    variant: variant,
                    specialOfferVariant: "special_offer_v_1",
                    plan: plan.analyticsValue,
                    purchaseSource: purchaseSource,
                    placeWhereBuy: placeWhereBuy ?? entryPoint
                )
                Telemetry.shared.specialOfferBuy(placewhereBuy: placeWhereBuy)
                
                SpecialOfferNotificationManager.shared.cancelAllSpecialOffers() // ⬅️ додали
                UserDefaults.standard.set(true, forKey: "special_offer_just_purchased")
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
                    explicitPurchaseSource: Telemetry.shared.resolvedSpecialOfferPurchaseSource(from: placeWhereBuy),
                    explicitOnboardId: OnboardTag.lastFromUserDefaults()?.rawValue,
                    placeWhereBuy: placeWhereBuy
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
                packageId: pkg.storeProduct.productIdentifier,
                rcCode: rcCode,
                message: ns.localizedDescription,
                fallbackReason: fallbackReason,
                explicitPurchaseSource: Telemetry.shared.resolvedSpecialOfferPurchaseSource(from: placeWhereBuy),
                explicitOnboardId: OnboardTag.lastFromUserDefaults()?.rawValue,
                placeWhereBuy: placeWhereBuy
            )
            return TelemetryPurchaseAttemptResult(
                status: (rcCode == 1) ? .cancelled : .failed,
                packageId: pkg.storeProduct.productIdentifier,
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
