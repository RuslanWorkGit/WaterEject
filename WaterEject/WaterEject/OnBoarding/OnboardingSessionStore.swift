//
//  OnboardingSessionStore.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 20.10.2025.
//

import Foundation

struct OnboardingSession: Codable {
    let tag: OnboardTag
    var steps: [String]
    var paywallShown: Bool
    var ts: TimeInterval
}

final class OnboardingSessionStore {
    static let shared = OnboardingSessionStore()
    private let key = "onboarding_session_v1"

    func save(tag: OnboardTag, steps: [String], paywallShown: Bool) {
        let s = OnboardingSession(tag: tag, steps: steps, paywallShown: paywallShown, ts: Date().timeIntervalSince1970)
        if let data = try? JSONEncoder().encode(s) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func load() -> OnboardingSession? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(OnboardingSession.self, from: data)
    }

    func clear() { UserDefaults.standard.removeObject(forKey: key) }
}
