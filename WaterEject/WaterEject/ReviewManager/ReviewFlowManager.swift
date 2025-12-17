//
//  ReviewFlowManager.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 17.12.2025.
//

import SwiftUI
import FirebaseAnalytics

@MainActor
final class ReviewFlowManager: ObservableObject {
    static let shared = ReviewFlowManager()
    private init() {}

    // MARK: - UI routing (alerts)
    enum Route: Equatable {
        case initialLike
        case starRating
        case feedback(stars: Int?)   // nil = “не сподобалось” без зірок
    }

    @Published var route: Route?
    @Published var feedbackText: String = ""

    // MARK: - UserDefaults keys
    private enum Keys {
        static let successfulCleanCount = "review_successful_clean_count"
        static let didPromptAfterFirstSuccess = "review_prompted_after_first_success"
        static let hasRated = "review_has_rated"
        static let hasSentFeedback = "review_has_sent_feedback"
        static let lastPromptTs = "review_last_prompt_ts1"
        static let didCompleteReviewFlow = "review_did_complete_flow"
    }

    private let defaults = UserDefaults.standard

    private var lastDevice: String?
    private var lastMode: String?

    // MARK: - Derived state helpers
    var feedbackStars: Int? {
        if case .feedback(let stars) = route { return stars }
        return nil
    }

    // MARK: - Public API

    /// Викликаєш коли чистка “успішна” (таймер дійшов до 0).
    func recordSuccessfulCleaning(device: String, mode: String) {
        lastDevice = device
        lastMode = mode

        let newCount = defaults.integer(forKey: Keys.successfulCleanCount) + 1
        defaults.set(newCount, forKey: Keys.successfulCleanCount)

        Analytics.logEvent("clean_success", parameters: [
            "count": newCount,
            "device": device,
            "mode": mode
        ])

        maybePresentAfterSuccess(count: newCount)
    }

    func userLiked() {
        log("review_initial_like", ["like": "Yes"])
        go(.starRating)
    }

    func userDisliked() {
        log("review_initial_like", ["like": "No"])
        go(.feedback(stars: nil))
    }

    func userLater() {
        log("review_initial_like", ["like": "Later"])
        dismiss()
    }

    /// Вибрали зірки
    func userPickedStars(_ stars: Int) {
        log("review_star_selected", ["stars": stars])

        if stars >= 4 {
            defaults.set(true, forKey: Keys.hasRated)
            defaults.set(true, forKey: Keys.didCompleteReviewFlow)   // ✅ стоп-флаг
            //log("review_star_selected", ["stars": stars])
            dismiss()
        } else {
            go(.feedback(stars: stars))
        }
    }

    /// Надіслали кастомний фідбек
    func submitFeedback(text: String, stars: Int?) {
        defaults.set(true, forKey: Keys.hasSentFeedback)
        defaults.set(true, forKey: Keys.didCompleteReviewFlow)       // ✅ стоп-флаг

        log("review_feedback_submitted", [
            "stars": stars ?? 0,
            "len": text.count
            //"text": text
        ])
        dismiss()
    }

    func dismiss() {
        route = nil
        feedbackText = ""
    }

    // MARK: - Private routing

    private func go(_ next: Route) {
        // Щоб не було конфлікту “один alert закрився — інший має відкритися”
        route = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.route = next
        }
    }

    // MARK: - Gating

    private func maybePresentAfterSuccess(count: Int) {
        // ✅ якщо вже завершили review-флоу — більше не показуємо
        guard !defaults.bool(forKey: Keys.didCompleteReviewFlow) else { return }

        // (опційно) якщо вже зараз щось показується — не конфліктуємо
        guard route == nil else { return }

        defaults.set(Date().timeIntervalSince1970, forKey: Keys.lastPromptTs)

        log("review_prompt_shown", ["trigger": "after_success", "count": count])
        route = .initialLike
    }

    private func log(_ name: String, _ params: [String: Any] = [:]) {
        var p = params
        p["device"] = lastDevice ?? "unknown"
        p["mode"] = lastMode ?? "unknown"
        Analytics.logEvent(name, parameters: p)
    }
}
