
//
//  Untitled.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 04.12.2025.
//

import Foundation
import UserNotifications
import RevenueCat

enum LocalNotificationId {
    static let specialOfferAfterClose  = "special_offer_after_5_min"
    static let legacySpecialOfferAfterClose = "special_offer_after_close"
    static let specialOfferAfter5Min = "special_offer_after_5_min"
    static let specialOfferAfter30Min = "special_offer_after_30_min"
    static let specialOfferAfter1Day = "special_offer_after_1_day"
    static let specialOfferAfter3Days = "special_offer_after_3_days"
    static let specialOfferAfter7Days  = "special_offer_after_7_days"
}
extension Notification.Name {
    static let specialOfferPushTapped = Notification.Name("specialOfferPushTapped")
}

struct SpecialOfferPushContext {
    let notificationId: String
    let placeWhereBuy: String
    let shownText: String
    let offerTextEn: String
    let launchedFromPush: Bool
}

enum AppNotificationPolicy {
    private static let subscriptionBlocksNotificationsKey = "subscription_blocks_app_notifications"
    private static let subscriptionStatusResolvedKey = "subscription_notification_status_resolved"

    static var blocksNotifications: Bool {
        UserDefaults.standard.bool(forKey: subscriptionBlocksNotificationsKey)
    }

    static var canScheduleNotifications: Bool {
        UserDefaults.standard.bool(forKey: subscriptionStatusResolvedKey) && !blocksNotifications
    }

    static func updateForSubscription(isActive: Bool) {
        UserDefaults.standard.set(true, forKey: subscriptionStatusResolvedKey)
        UserDefaults.standard.set(isActive, forKey: subscriptionBlocksNotificationsKey)

        if isActive {
            disableAllNotifications()
        }
    }

    static func disableAllNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }
}

final class SpecialOfferNotificationManager {
    static let shared = SpecialOfferNotificationManager()
    private init() {}

    static let defaultEnglishOfferText = "Your speakers may still need cleaning - 40% OFF."

    static var allSpecialOfferIds: [String] {
        [
            LocalNotificationId.specialOfferAfter5Min,
            LocalNotificationId.specialOfferAfter30Min,
            LocalNotificationId.specialOfferAfter1Day,
            LocalNotificationId.specialOfferAfter3Days,
            LocalNotificationId.specialOfferAfter7Days,
            LocalNotificationId.legacySpecialOfferAfterClose
        ]
    }

    static func placeWhereBuy(for notificationId: String) -> String {
        switch notificationId {
        case LocalNotificationId.specialOfferAfter5Min, LocalNotificationId.legacySpecialOfferAfterClose:
            return "Push notification 5 min"
        case LocalNotificationId.specialOfferAfter30Min:
            return "Push notification 30 min"
        case LocalNotificationId.specialOfferAfter1Day:
            return "Push notification 1 day"
        case LocalNotificationId.specialOfferAfter3Days:
            return "Push notification 3 days"
        case LocalNotificationId.specialOfferAfter7Days:
            return "Push notification 7 days"
        default:
            return "Push notification"
        }
    }
    
    // 1) Запит дозволів (краще викликати 1 раз, наприклад після онбордингу)
    func requestAuthorization() {
        guard !AppNotificationPolicy.blocksNotifications else { return }

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error {
                print("Notification permission error: \(error)")
            } else {
                print("Notification permission granted: \(granted)")
            }
        }
    }
    
    // 2) Запланувати оффер через N секунд (за замовчуванням 5 хв)
    private func scheduleSpecialOffer(
        after seconds: TimeInterval,
        id: String,
        englishBody: String
    ) {
           guard AppNotificationPolicy.canScheduleNotifications else { return }

           let content = UNMutableNotificationContent()
           content.title = String(localized: "WaterEject")
           let body = NSLocalizedString(englishBody, comment: "")
           
           content.body  = body
           content.sound = .default
           
           content.userInfo = [
                "special_offer": true,
                "special_offer_text": englishBody,
                "offer_text_en": englishBody,
                "notification_id": id
           ]
           
           let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
           
           let request = UNNotificationRequest(
               identifier: id,
               content: content,
               trigger: trigger
           )
           
           UNUserNotificationCenter.current().add(request) { error in
               if let error {
                   print("Failed to schedule special offer notification: \(error)")
               }
           }
       }
    
    func scheduleAllSpecialOffers() {
        guard AppNotificationPolicy.canScheduleNotifications else { return }
        cancelAllSpecialOffers()

        scheduleSpecialOffer(
            after: 5 * 60,
            id: LocalNotificationId.specialOfferAfter5Min,
            englishBody: "Your speakers may still need cleaning - 40% OFF."
        )
        scheduleSpecialOffer(
            after: 30 * 60,
            id: LocalNotificationId.specialOfferAfter30Min,
            englishBody: "Water may be trapped. Finish cleaning: 40% OFF."
        )
        scheduleSpecialOffer(
            after: 24 * 60 * 60,
            id: LocalNotificationId.specialOfferAfter1Day,
            englishBody: "Protect your speakers. Cleaning now 40% OFF."
        )
        scheduleSpecialOffer(
            after: 3 * 24 * 60 * 60,
            id: LocalNotificationId.specialOfferAfter3Days,
            englishBody: "Restore speaker clarity - 40% OFF cleaning."
        )
        scheduleSpecialOffer(
            after: 7 * 24 * 60 * 60,
            id: LocalNotificationId.specialOfferAfter7Days,
            englishBody: "Moisture risk in speakers. 40% OFF to clean."
        )
    }

    func scheduleAllSpecialOffersIfEligible() async {
        if let info = try? await Purchases.shared.customerInfo() {
            let isPro = info.entitlements["pro_user"]?.isActive == true
            AppNotificationPolicy.updateForSubscription(isActive: isPro)
        }

        guard AppNotificationPolicy.canScheduleNotifications else { return }
        scheduleAllSpecialOffers()
    }

    func scheduleAfterClose() {
        Task { await scheduleAllSpecialOffersIfEligible() }
    }

    func scheduleAfter7Days() {
        Task { await scheduleAllSpecialOffersIfEligible() }
    }
    
    func cancelAllSpecialOffers() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(
                withIdentifiers: Self.allSpecialOfferIds
            )
    }
}
