
//
//  Untitled.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 04.12.2025.
//

import Foundation
import UserNotifications

enum LocalNotificationId {
    static let specialOfferAfterClose  = "special_offer_after_close"
    static let specialOfferAfter7Days  = "special_offer_after_7_days"
}
extension Notification.Name {
    static let specialOfferPushTapped = Notification.Name("specialOfferPushTapped")
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
           id: String
       ) {
           guard AppNotificationPolicy.canScheduleNotifications else { return }

           let content = UNMutableNotificationContent()
           content.title = String(localized: "WaterEject")
           
           // 🔹 Варіанти текстів для 5 хв після закриття
           let afterCloseBodies = [
               String(localized: "💧 Your speakers may still need cleaning — 40% OFF."),
               String(localized: "💧 Water may be trapped. Finish cleaning: 40% OFF."),
               String(localized: "💧 Protect your speakers. Cleaning now 40% OFF."),
               String(localized: "💧 Restore speaker clarity — 40% OFF cleaning.")
           ]
           
           // 🔹 Варіанти текстів для 7 днів неактивності
           let after7DaysBodies = [
               String(localized: "💧 Moisture risk in speakers. 40% OFF to clean."),
               String(localized: "💧 Your speakers may still need cleaning — 40% OFF."),
               String(localized: "💧 Water may be trapped. Finish cleaning: 40% OFF."),
               String(localized: "💧 Protect your speakers. Cleaning now 40% OFF."),
               String(localized: "💧 Restore speaker clarity — 40% OFF cleaning.")
           ]
           
           // 🔹 Вибір рандомного тексту залежно від типу нотифікації
           let body: String
           switch id {
           case LocalNotificationId.specialOfferAfter7Days:
               body = after7DaysBodies.randomElement() ?? after7DaysBodies[0]
               
           case LocalNotificationId.specialOfferAfterClose:
               body = afterCloseBodies.randomElement() ?? afterCloseBodies[0]
               
           default:
               body = String(localized: "💧 Your speakers may still need cleaning — 40% OFF.")
           }
           
           content.body  = body
           content.sound = .default
           
           // ключ, по якому розуміємо, що це наш special offer
           content.userInfo = ["special_offer": true]
           
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
    
    // офер через 5 хв після закриття
    func scheduleAfterClose() {
        scheduleSpecialOffer(
            after: 5 * 60,
            id: LocalNotificationId.specialOfferAfterClose
        )
    }
    
    // офер через 7 днів неактивності
    func scheduleAfter7Days() {
        let sevenDays: TimeInterval = 7 * 24 * 60 * 60
        scheduleSpecialOffer(
            after: sevenDays,
            id: LocalNotificationId.specialOfferAfter7Days
        )
    }
    
    func cancelAllSpecialOffers() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(
                withIdentifiers: [
                    LocalNotificationId.specialOfferAfterClose,
                    LocalNotificationId.specialOfferAfter7Days
                ]
            )
    }
}
