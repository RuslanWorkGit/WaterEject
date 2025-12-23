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

    static var completedDays: Int {
        get { min(UserDefaults.standard.integer(forKey: daysKey), 7) }
        set {
            let clamped = min(max(newValue, 0), 7)
            UserDefaults.standard.set(clamped, forKey: daysKey)
        }
    }

    /// Викликати при успішному завершенні чистки.
    /// Захищає від кількох інкрементів за один день.
    static func markCompletedToday() {
        let defaults = UserDefaults.standard
        let now = Date()
        let calendar = Calendar.current

        if let last = defaults.object(forKey: lastDateKey) as? Date,
           calendar.isDate(last, inSameDayAs: now) {
            return
        }

        defaults.set(now, forKey: lastDateKey)
        completedDays = min(completedDays + 1, 7)
    }

    static func reset() {
        UserDefaults.standard.removeObject(forKey: lastDateKey)
        completedDays = 0
    }
}
