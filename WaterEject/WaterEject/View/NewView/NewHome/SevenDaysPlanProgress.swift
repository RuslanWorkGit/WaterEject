//
//  SevenDaysPlanProgress.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 23.12.2025.
//

import Foundation

enum SevenDayPlanProgress {
    static let daysKey = "seven_day_plan_completed_days"
    static let lastDateKey = "seven_day_plan_last_completed_date"
    
    static let unlockDelaySeconds: TimeInterval = 0

    static var completedDays: Int {
        get { min(UserDefaults.standard.integer(forKey: daysKey), 7) }
        set {
            let clamped = min(max(newValue, 0), 7)
            UserDefaults.standard.set(clamped, forKey: daysKey)
        }
    }
    
    
    static func canStartNextDay(now: Date = Date()) -> Bool {
        guard let last = UserDefaults.standard.object(forKey: lastDateKey) as? Date else {
            return true // ще нічого не проходили
        }

        let calendar = Calendar.current
        let startOfLastDay = calendar.startOfDay(for: last)

        guard let startOfNextDay = calendar.date(byAdding: .day, value: 1, to: startOfLastDay) else {
            return true
        }

        return now >= startOfNextDay.addingTimeInterval(unlockDelaySeconds)
    }

    /// Викликати при успішному завершенні чистки.
    /// Захищає від кількох інкрементів за один день.
    static func markCompletedToday() {
        let calendar = Calendar.current
        let now = Date()

        if let lastDate = UserDefaults.standard.object(forKey: lastDateKey) as? Date,
           calendar.isDate(lastDate, inSameDayAs: now) {
            return
        }

        var days = UserDefaults.standard.integer(forKey: daysKey)
        if days < 7 { days += 1 }

        UserDefaults.standard.set(days, forKey: daysKey)
        UserDefaults.standard.set(now, forKey: lastDateKey)
    }

    static func reset() {
        UserDefaults.standard.removeObject(forKey: lastDateKey)
        completedDays = 0
    }
}
