//
//  UserDefaultsReset.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 20.10.2025.
//

import Foundation

enum OneTimeDefaultsReset {
    /// ЗМІНИ цю константу в кожному релізі, де треба повторити ресет
    private static let tokenKey = "ud_reset_done_v2025_10_20"

    /// Повний ресет стандартного UserDefaults + опційно App Group’ів
    static func run(full: Bool = true) {
        let d = UserDefaults.standard

        // Якщо вже робили цей ресет — нічого не робимо
        guard d.bool(forKey: tokenKey) == false else { return }

        // 1) Чистимо стандартний домен (ВСЕ)
        if full, let bundleID = Bundle.main.bundleIdentifier {
            d.removePersistentDomain(forName: bundleID)
        }
        
        // 3) СТАВИМО ПРАПОРЕЦЬ ПІСЛЯ ЧИСТКИ (інакше він теж зітреться)
        d.set(true, forKey: tokenKey)
        d.synchronize()
    }
}
