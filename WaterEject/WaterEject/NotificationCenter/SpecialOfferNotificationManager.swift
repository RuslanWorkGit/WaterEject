
//
//  Untitled.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 04.12.2025.
//

import Foundation
import UserNotifications

enum LocalNotificationId {
    static let specialOffer = "special_offer_after_close"
}

extension Notification.Name {
    static let specialOfferPushTapped = Notification.Name("specialOfferPushTapped")
}


final class SpecialOfferNotificationManager {
    static let shared = SpecialOfferNotificationManager()
    private init() {}

    // 1) Запит дозволів (краще викликати 1 раз, наприклад після онбордингу)
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error {
                print("Notification permission error: \(error)")
            } else {
                print("Notification permission granted: \(granted)")
            }
        }
    }

    // 2) Запланувати оффер через N секунд (за замовчуванням 5 хв)
    func scheduleSpecialOffer(after seconds: TimeInterval = 1 * 60) {
        // щоб не плодити дублікати
        cancelSpecialOffer()

        let content = UNMutableNotificationContent()

        // Випадковий текст із чотирьох варіантів
        let variants = [
            "💧 Your speakers may still need cleaning — 40% OFF.",
            "💧 Water may be trapped. Finish cleaning: 40% OFF.",
            "💧 Protect your speakers. Cleaning now 40% OFF.",
            "💧 Restore speaker clarity — 40% OFF cleaning."
        ]
        content.body  = variants.randomElement() ?? variants[0]
        content.title = "Water Eject"

        // важливо — по цьому ключу будемо розуміти, що відкривати SpecialOfferView
        content.userInfo = ["special_offer": true]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)

        let request = UNNotificationRequest(
            identifier: LocalNotificationId.specialOffer,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("Failed to schedule special offer notification: \(error)")
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                    didReceive response: UNNotificationResponse,
                                    withCompletionHandler completionHandler: @escaping () -> Void) {

            let userInfo = response.notification.request.content.userInfo
            if let type = userInfo["type"] as? String, type == "special_offer" {
                // 1) Запам’ятати факт, що треба відкрити спец-оффер
                UserDefaults.standard.set(true, forKey: "launch_special_offer_from_push")

                // 2) На випадок, якщо апка вже жива — расшарити через NotificationCenter
                NotificationCenter.default.post(name: .specialOfferPushTapped, object: nil)
            }

            completionHandler()
        }

    // 3) Скасувати, наприклад після успішної покупки або якщо не треба
    func cancelSpecialOffer() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [LocalNotificationId.specialOffer])
    }
}
