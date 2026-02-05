//
//  SubscriptionReport.swift
//  SoundPad
//
//  Created by Ruslan Liulka on 03.02.2026.
//

import Foundation

enum J2DPlatform: String {
    case watereject
    case speaker
}

enum AppConfig {
    static var j2dBaseURL: URL {
        let s = Bundle.main.object(forInfoDictionaryKey: "J2D_BASE_URL") as? String
        let urlString = (s?.isEmpty == false) ? s! : "https://notion.just2done.com:9000"
        return URL(string: urlString)!
    }

    static var j2dSubscriptionKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "J2D_SUBSCRIPTION_KEY") as? String,
              !key.isEmpty
        else {
            fatalError("Missing J2D_SUBSCRIPTION_KEY in Info.plist")
        }
        return key
    }
}


enum J2DSubscriptionType: String {
    case subscription
    case nonConsumable = "non_consumable"
}

enum J2DEvent: String {
    // subscription
    case subscribed, renewed, unsubscribed, expired
    // non-consumable
    case purchased, refunded
}

struct J2DSubscriptionEventPayload: Encodable {
    let platform: String
    let user_id: String
    let event: String
    let subscription_type: String
    let plan: String
    let date: String
    let region: String?
    let language: String?
}

enum J2DAPIError: Error {
    case badURL
    case httpStatus(Int, String)
}

final class J2DSubscriptionReporter {
    static let shared = J2DSubscriptionReporter()

    private let baseURL = AppConfig.j2dBaseURL
    private var keyHeaderValue: String { AppConfig.j2dSubscriptionKey }


    private init() {}

    func sendSubscriptionEvent(
        platform: J2DPlatform,
        userId: String,
        event: J2DEvent,
        type: J2DSubscriptionType,
        plan: String,
        region: String? = Locale.current.regionCode,
        language: String? = Locale.preferredLanguages.first.map { String($0.prefix(2)).uppercased() },
        date: Date = Date()
    ) async throws {
        // простий захист від неправильних комбінацій event/type
        switch type {
        case .subscription:
            precondition([.subscribed, .renewed, .unsubscribed, .expired].contains(event))
        case .nonConsumable:
            precondition([.purchased, .refunded].contains(event))
        }

        let url = baseURL.appendingPathComponent("subscription/event")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(keyHeaderValue, forHTTPHeaderField: "Key")

        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withFullDate]
        iso.timeZone = TimeZone(secondsFromGMT: 0)

        let payload = J2DSubscriptionEventPayload(
            platform: platform.rawValue,
            user_id: userId,
            event: event.rawValue,
            subscription_type: type.rawValue,
            plan: plan,
            date: iso.string(from: date),
            region: region,
            language: language
        )

        request.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await URLSession.shared.data(for: request)
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
        let text = String(data: data, encoding: .utf8) ?? ""

        guard (200...299).contains(statusCode) else {
            throw J2DAPIError.httpStatus(statusCode, text)
        }
    }
}

