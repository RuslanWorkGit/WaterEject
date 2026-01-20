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
        switch self { case .weekly: "7 days" }
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
            let offerings = try await Purchases.shared.offerings()
            guard let current = offerings.current else { return }

            let wantedID = plan.productID
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

            weeklyPricePerPeriod = "\(displayPrice)/week"
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
    ) async {
        
        guard !isPurchasing else { return }
        guard let pkg = weeklyPackage else {
            errorMessage = "Product not found"

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
        
        
        do {
            let result = try await Purchases.shared.purchase(package: pkg)
            let active = result.customerInfo.entitlements[entitlementID]?.isActive == true
            purchaseSucceeded = active
            
            if active {
                let txId = result.transaction?.transactionIdentifier
                
                if shouldSendSubscribeEvent(txId: txId) {    // <-- додати дедуп
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
                
                let resolvedOnboardId = OnboardTag.lastFromUserDefaults()?.rawValue ?? "unknown"
                Telemetry.shared.funnelPurchaseSuccess(
                    onboardId: resolvedOnboardId,
                    plan: "weekly"
                )
                
                
//                AF.log(.subscribe, [
//                  "af_revenue": price,
//                  "af_currency": currency ?? "USD",
//                  "af_content_id": p.productIdentifier,
//                  "cpa_value": 0
//                ])
                
                let cpaFlag = "af_subscribe_cpa_sent \(Purchases.shared.appUserID)"
                if !UserDefaults.standard.bool(forKey: cpaFlag) {
//                    AppsFlyerLib.shared().logEvent("subscribe_cpa", withValues: [
//                        "cpa_value": p.afPriceDouble,
//                        "af_currency": p.afCurrencyCode,
//                        "product_id": p.productIdentifier,
//                        "transaction_id": txId ?? ""
//                    ])
                    UserDefaults.standard.set(true, forKey: cpaFlag)
                }
                
                SubscriptionMonitor.shared.process(customerInfo: result.customerInfo)
                RCPriceCache.save(entitlementID: entitlementID, price: price, currency: currency ?? "USD")
                
                Telemetry.shared.specialOfferBuy(placewhereBuy: placeWhereBuy)
                
                SpecialOfferNotificationManager.shared.cancelAllSpecialOffers() // ⬅️ додали
                UserDefaults.standard.set(true, forKey: "special_offer_just_purchased")

//                
//                Telemetry.shared.purchaseResult(
//                    variant: variant,
//                    status: "success",
//                    rcCode: 0,
//                    packageId: p.productIdentifier,
//                    pricePaid: price,
//                    currency: currency,
//                    sessionId: sessionId,
//                    onboardId: onboardId,
//                    paywallId: paywallId
//                )
            } else {
                errorMessage = "Subscription not active"

            }
        } catch {
            let ns = error as NSError
            let rcCode = ns.userInfo["RCErrorCodeKey"] as? Int
            let status = (rcCode == 1) ? "user_cancelled" : "error"
            errorMessage = ns.localizedDescription
            
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
