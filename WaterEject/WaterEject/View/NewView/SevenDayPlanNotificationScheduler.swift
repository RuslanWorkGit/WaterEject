//
//  SevenDayPlanNotificationScheduler.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 26.12.2025.
//

import Foundation
import UserNotifications

enum SevenDayPlanNotificationScheduler {

    private static let morningId = "sevenDayPlan.reminder.morning"
    private static let eveningId = "sevenDayPlan.reminder.evening"

    /// Викликати ПІСЛЯ успішної чистки (після markCompletedToday()).
    /// Запланує нотифікації на наступний день о 10:00 і 20:00.
    static func scheduleForNextDayIfNeeded() {
        guard AppNotificationPolicy.canScheduleNotifications else {
            cancelPending()
            return
        }

        // Якщо план завершено — нічого не плануємо
        let completed = SevenDayPlanProgress.completedDays
        guard completed < 7 else {
            cancelPending()
            return
        }

        // Має бути дата останнього виконаного дня
        guard let last = UserDefaults.standard.object(forKey: SevenDayPlanProgress.lastDateKey) as? Date else {
            return
        }

        // Розрахунок "наступного дня" від старту дня останнього виконання
        let cal = Calendar.current
        let startOfLastDay = cal.startOfDay(for: last)
        guard let nextDay = cal.date(byAdding: .day, value: 1, to: startOfLastDay) else {
            return
        }

        // Скасувати попередні, щоб не плодити дублікати
        cancelPending()

        Task {
            let allowed = await requestAuthorizationIfNeeded()
            guard allowed, AppNotificationPolicy.canScheduleNotifications else { return }

            // 10:00
            if let tenAM = cal.date(bySettingHour: 10, minute: 0, second: 0, of: nextDay) {
                schedule(at: tenAM,
                         id: morningId,
                         title: "Daily cleaning reminder",
                         body: "Don’t forget your daily cleaning — today’s step is ready.")
            }

            // 20:00
            if let eightPM = cal.date(bySettingHour: 20, minute: 0, second: 0, of: nextDay) {
                schedule(at: eightPM,
                         id: eveningId,
                         title: "Still haven’t cleaned today?",
                         body: "Take 60 seconds to complete today’s cleaning step.")
            }
        }
    }

    static func cancelPending() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [morningId, eveningId])
    }

    // MARK: - Private

    private static func schedule(at date: Date, id: String, title: String, body: String) {
        guard AppNotificationPolicy.canScheduleNotifications else { return }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)

        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    private static func requestAuthorizationIfNeeded() async -> Bool {
        guard AppNotificationPolicy.canScheduleNotifications else { return false }

        let center = UNUserNotificationCenter.current()

        let settings = await withCheckedContinuation { cont in
            center.getNotificationSettings { cont.resume(returning: $0) }
        }

        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied:
            return false
        case .notDetermined:
            return await withCheckedContinuation { cont in
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    cont.resume(returning: granted)
                }
            }
        @unknown default:
            return false
        }
    }
}
