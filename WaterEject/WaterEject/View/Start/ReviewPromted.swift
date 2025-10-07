//
//  ReviewPromted.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 07.10.2025.
//

import StoreKit
import UIKit


enum ReviewPrompter {
    private static let lastPromptKey = "rate.lastPrompt.ts"
    private static let completedKey  = "rate.completed.count"

    static var minCompletions = 1
    static var minDaysBetween: Double = 1

    static func recordCompletion() {
        let n = UserDefaults.standard.integer(forKey: completedKey)
        UserDefaults.standard.set(n + 1, forKey: completedKey)
        print("⭐️ ReviewPrompter.recordCompletion() → \(n + 1)")
    }

    @MainActor
    static func maybeAsk() {
        let n = UserDefaults.standard.integer(forKey: completedKey)
        let last = UserDefaults.standard.double(forKey: lastPromptKey)
        let daysSince = (Date().timeIntervalSince1970 - last) / 86_400

        guard n >= minCompletions else {
            print("🟡 not enough completions: \(n) < \(minCompletions)")
            return
        }
        guard daysSince >= minDaysBetween else {
            print("🟡 too early: \(daysSince) < \(minDaysBetween) days since last prompt")
            return
        }

        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) else {
                print("🔴 no foreground UIWindowScene")
                return
            }

        print("✅ requesting SKStoreReviewController on scene: \(scene)")
        SKStoreReviewController.requestReview(in: scene)

        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: lastPromptKey)
        UserDefaults.standard.set(0, forKey: completedKey)
    }

    static func openWriteReview(appId: String) {
        if let url = URL(string: "itms-apps://itunes.apple.com/app/id\(appId)?action=write-review") {
            UIApplication.shared.open(url)
        }
    }

    #if DEBUG
    @MainActor
    static func debugForceAsk() {
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) else { return }
        SKStoreReviewController.requestReview(in: scene)
    }

    static func resetCounters() {
        UserDefaults.standard.removeObject(forKey: lastPromptKey)
        UserDefaults.standard.removeObject(forKey: completedKey)
        print("♻️ ReviewPrompter counters reset")
    }
    #endif
}
