//
//  PaywallVariant.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 13.08.2025.
//

import Foundation
import FirebaseRemoteConfig
import FirebaseAnalytics
import RevenueCat
import SwiftUI

enum PaywallVariant: String, Identifiable {
    case third    = "third"  // наш основний
    case fourth   = "fourth"  // НОВИЙ PaywallFourView
    case fifth     = "fifth"
//    case A        = "A"
//    case B        = "B"

    var id: String { rawValue }
}

struct PaywallProductSettings {
    let variantID: String?
    let weeklyProductID: String
    let yearlyProductID: String
    let annualProductID: String
    let yearlyCardPlan: PaywallCardPlan
    let chooseCard: PaywallChooseCard
    let freeTest: Bool
}

enum PaywallCardPlan: String {
    case yearly
    case annual
}

enum PaywallChooseCard: String {
    case first
    case second
}

enum PaywallPriceMode: String {
    case first
    case second
    case both
}

struct PaywallPlanTextSettings {
    let title: String?
    let trialTitleFormat: String?
    let sublabel: String?
    let saveText: String?
}

struct PaywallTextSettings {
    let mainText: String?
    let footerTrialText: String?
    let footerSecureText: String?
    let plans: [String: PaywallPlanTextSettings]

    func plan(_ key: String) -> PaywallPlanTextSettings {
        plans[key] ?? PaywallPlanTextSettings(title: nil, trialTitleFormat: nil, sublabel: nil, saveText: nil)
    }
}

private struct PaywallProductsRemoteConfig: Decodable {
    let version: Int?
    let paywalls: [String: PaywallProductRemoteConfig]
}

private struct PaywallTextRemoteConfig: Decodable {
    let version: Int?
    let paywalls: [String: PaywallTextRemotePaywall]
}

private struct PaywallTextRemotePaywall: Decodable {
    let mainText: [String: String]?
    let footerTrialText: [String: String]?
    let footerSecureText: [String: String]?
    let plans: [String: PaywallPlanTextRemoteConfig]?
}

private struct PaywallPlanTextRemoteConfig: Decodable {
    let title: [String: String]?
    let trialTitleFormat: [String: String]?
    let sublabel: [String: String]?
    let saveText: [String: String]?
}

private struct PaywallProductRemoteConfig: Decodable {
    let weeklyProductId: String?
    let yearlyProductId: String?
    let annualProductId: String?
    let yearlyCardPlan: String?
    let chooseCard: String?
    let freeTest: Bool?
    let variants: PaywallProductVariantsRemoteConfig?
}

private enum PaywallProductVariantsRemoteConfig: Decodable {
    case list([PaywallProductVariantRemoteConfig])
    case tiers([String: PaywallProductTierVariantsRemoteConfig])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let list = try? container.decode([PaywallProductVariantRemoteConfig].self) {
            self = .list(list)
            return
        }
        self = .tiers(try container.decode([String: PaywallProductTierVariantsRemoteConfig].self))
    }
}

private struct PaywallProductTierVariantsRemoteConfig: Decodable {
    let defaultVariants: [PaywallProductVariantRemoteConfig]
    let countries: [String: PaywallProductCountryVariantsRemoteConfig]?

    private enum CodingKeys: String, CodingKey {
        case defaultVariants = "default"
        case countries
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let list = try? container.decode([PaywallProductVariantRemoteConfig].self) {
            self.defaultVariants = list
            self.countries = nil
            return
        }

        let keyed = try decoder.container(keyedBy: CodingKeys.self)
        self.defaultVariants = try keyed.decodeIfPresent([PaywallProductVariantRemoteConfig].self, forKey: .defaultVariants) ?? []
        self.countries = try keyed.decodeIfPresent([String: PaywallProductCountryVariantsRemoteConfig].self, forKey: .countries)
    }
}

private struct PaywallProductCountryVariantsRemoteConfig: Decodable {
    let name: String?
    let variants: [PaywallProductVariantRemoteConfig]

    private enum CodingKeys: String, CodingKey {
        case name
        case variants
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let list = try? container.decode([PaywallProductVariantRemoteConfig].self) {
            self.name = nil
            self.variants = list
            return
        }

        let keyed = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try keyed.decodeIfPresent(String.self, forKey: .name)
        self.variants = try keyed.decodeIfPresent([PaywallProductVariantRemoteConfig].self, forKey: .variants) ?? []
    }
}

private struct PaywallProductVariantRemoteConfig: Decodable {
    let id: String?
    let traffic: Int?
    let trafic: Int?
    let weeklyProductId: String?
    let yearlyProductId: String?
    let annualProductId: String?
    let yearlyCardPlan: String?
    let chooseCard: String?
    let freeTest: Bool?

    var effectiveTraffic: Int {
        max(traffic ?? trafic ?? 0, 0)
    }
}

private struct PaywallCountryTierMapping {
    private let tier1Countries: Set<String> = [
        "US", "CA", "AU"
    ]
    private let tier2Countries: Set<String> = [
        "AL", "AD", "AT", "BY", "BE", "BA", "BG", "HR", "CY", "CZ",
        "DK", "EE", "FI", "FR", "DE", "GR", "HU", "IS", "IE", "IT",
        "XK", "LV", "LI", "LT", "LU", "MT", "MD", "MC", "ME", "NL",
        "MK", "NO", "PL", "PT", "RO", "RU", "SM", "RS", "SK", "SI",
        "ES", "SE", "CH", "TR", "UA", "GB", "VA"
    ]
    private let tier3Countries: Set<String> = [
        "AE", "AR", "BR", "CL", "CN", "CO", "EC", "HK", "ID", "IL",
        "IN", "JP", "KR", "MX", "MY", "NZ", "PE", "PH", "SA", "SG",
        "TH", "UY", "VE", "VN", "ZA"
    ]

    func tier(for countryCode: String) -> String {
        let code = Self.normalizedCountryCode(countryCode)
        if tier1Countries.contains(code) {
            return "tier_1"
        }
        if tier2Countries.contains(code) {
            return "tier_2"
        }
        if tier3Countries.contains(code) {
            return "tier_3"
        }
        return "tier_3"
    }

    static func normalizedCountryCode(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        let uppercased = trimmed.uppercased()
        if uppercased.count == 2 {
            return uppercased
        }

        let aliases = [
            "BRAZIL": "BR",
            "KOSOVO": "XK",
            "UNITED STATES": "US",
            "UNITED STATES OF AMERICA": "US",
            "UNITED KINGDOM": "GB",
            "GREAT BRITAIN": "GB"
        ]
        if let alias = aliases[uppercased] {
            return alias
        }

        let englishLocale = Locale(identifier: "en_US_POSIX")
        for code in isoRegionCodes() {
            let englishName = englishLocale.localizedString(forRegionCode: code)?.uppercased()
            let currentName = Locale.current.localizedString(forRegionCode: code)?.uppercased()
            if englishName == uppercased || currentName == uppercased {
                return code.uppercased()
            }
        }

        return uppercased
    }

    private static func isoRegionCodes() -> [String] {
        if #available(iOS 16.0, *) {
            return Locale.Region.isoRegions.map { $0.identifier }
        }
        return NSLocale.isoCountryCodes
    }
}

final class PaywallAB {
    static let shared = PaywallAB()

    static let defaultPaywallProductsJSON = """
    {
      "version": 1,
      "paywalls": {
        "first": {
          "weeklyProductId": "kyryloVoinov.WaterEject.subscription.weekly",
          "yearlyProductId": "kyryloVoinov.WaterEject.subscription.yearly",
          "yearlyCardPlan": "yearly",
          "chooseCard": "second",
          "freeTest": false
        },
        "second": {
          "weeklyProductId": "kyryloVoinov.WaterEject.subscription.weekly",
          "yearlyProductId": "kyryloVoinov.WaterEject.subscription.yearly",
          "yearlyCardPlan": "yearly",
          "chooseCard": "second",
          "freeTest": false
        },
        "third": {
          "weeklyProductId": "kyryloVoinov.WaterEject.subscription.weekly",
          "yearlyProductId": "kyryloVoinov.WaterEject.subscription.yearly",
          "yearlyCardPlan": "yearly",
          "chooseCard": "second",
          "freeTest": false
        },
        "fourth": {
          "weeklyProductId": "kyryloVoinov.WaterEject.subscription.weekly",
          "yearlyProductId": "kyryloVoinov.WaterEject.subscription.yearly",
          "yearlyCardPlan": "yearly",
          "chooseCard": "first",
          "freeTest": false
        },
        "fifth": {
          "weeklyProductId": "kyryloVoinov.WaterEject.subscription.weekly",
          "yearlyProductId": "kyryloVoinov.WaterEject.subscription.yearly",
          "yearlyCardPlan": "yearly",
          "chooseCard": "first",
          "freeTest": true
        },
        "special": {
          "weeklyProductId": "kyryloVoinov.WaterEject.subscription.weeklyPecialOffer",
          "chooseCard": "first",
          "freeTest": false
        },
        "paywall_new_black_1": {
          "weeklyProductId": "kyryloVoinov.WaterEject.subscription.weekly",
          "annualProductId": "KyryloVoinov.WaterEject.lifetime.access",
          "chooseCard": "first",
          "freeTest": false
        },
        "paywall_new_black_2": {
          "weeklyProductId": "kyryloVoinov.WaterEject.subscription.weekly",
          "annualProductId": "KyryloVoinov.WaterEject.lifetime.access",
          "chooseCard": "first",
          "freeTest": false
        },
        "paywall_new_black_3": {
          "annualProductId": "KyryloVoinov.WaterEject.lifetime.access",
          "chooseCard": "first",
          "freeTest": false
        },
        "paywall_new_black_4": {
          "annualProductId": "KyryloVoinov.WaterEject.lifetime.access",
          "chooseCard": "first",
          "freeTest": false
        },
        "paywall_new_black_5": {
          "annualProductId": "KyryloVoinov.WaterEject.lifetime.access",
          "chooseCard": "first",
          "freeTest": false
        },
        "paywall_new_white_1": {
          "weeklyProductId": "kyryloVoinov.WaterEject.subscription.weekly",
          "annualProductId": "KyryloVoinov.WaterEject.lifetime.access",
          "chooseCard": "first",
          "freeTest": false
        }
      }
    }
    """

    private init() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 1800 // на проді зроби 3600+
        rc.configSettings = settings
        rc.setDefaults([
            "paywall_share_A": 50 as NSObject,   // якщо колись повернешся до спліта
            "paywall_force":   "" as NSObject, // <- ВСІ бачать PaywallThirdView

            // ⬇️ нові ключі
            "paywall3_enabled": true as NSObject,
            "paywall4_enabled": true as NSObject,
            "paywall5_enabled": true as NSObject,
            "price_mode_control": "both" as NSObject,
            "paywall_products_json": Self.defaultPaywallProductsJSON as NSObject,
            "paywall_text_controll": "" as NSObject
        ])
    }

    private let rc = RemoteConfig.remoteConfig()
    private let storageKey = "paywall_variant_v1"
    private let productsJSONKey = "paywall_products_json"
    private let textJSONKey = "paywall_text_controll"
    private let priceModeControlKey = "price_mode_control"
    private let countryTierMapping = PaywallCountryTierMapping()

    private let allPaywalls: [PaywallVariant] = [.third, .fourth, .fifth]

    private func enabledPaywalls() -> [PaywallVariant] {
        allPaywalls.filter { isEnabled($0) }
    }

    func fetchRemoteConfig(completion: (() -> Void)? = nil) {
        rc.fetchAndActivate { _, _ in completion?() }
    }

    func productSettings(for variant: PaywallVariant) -> PaywallProductSettings {
        productSettings(forKey: variant.rawValue)
    }

    func textSettings(for variant: PaywallVariant) -> PaywallTextSettings {
        textSettings(forKey: variant.rawValue)
    }

    var priceMode: PaywallPriceMode {
        PaywallPriceMode(rawValue: rc[priceModeControlKey].stringValue
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()) ?? .both
    }

    func textSettings(forKey key: String) -> PaywallTextSettings {
        let empty = PaywallTextSettings(mainText: nil, footerTrialText: nil, footerSecureText: nil, plans: [:])
        let json = rc[textJSONKey].stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !json.isEmpty,
              let data = json.data(using: .utf8),
              let config = try? JSONDecoder().decode(PaywallTextRemoteConfig.self, from: data),
              let remote = config.paywalls[key] else {
            return empty
        }

        var plans: [String: PaywallPlanTextSettings] = [:]
        for (planKey, planConfig) in remote.plans ?? [:] {
            plans[planKey] = PaywallPlanTextSettings(
                title: localizedValue(in: planConfig.title),
                trialTitleFormat: localizedValue(in: planConfig.trialTitleFormat),
                sublabel: localizedValue(in: planConfig.sublabel),
                saveText: localizedValue(in: planConfig.saveText)
            )
        }

        return PaywallTextSettings(
            mainText: localizedValue(in: remote.mainText),
            footerTrialText: localizedValue(in: remote.footerTrialText),
            footerSecureText: localizedValue(in: remote.footerSecureText),
            plans: plans
        )
    }

    func productSettings(forKey key: String) -> PaywallProductSettings {
        let fallback = Self.defaultProductSettings(forKey: key)
        let json = rc[productsJSONKey].stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !json.isEmpty,
              let data = json.data(using: .utf8),
              let config = try? JSONDecoder().decode(PaywallProductsRemoteConfig.self, from: data),
              let remote = config.paywalls[key] else {
            return fallback
        }

        let variant = selectedProductVariant(in: remote, forKey: key)
        return PaywallProductSettings(
            variantID: cleanVariantID(variant?.id),
            weeklyProductID: cleanProductID(variant?.weeklyProductId) ?? cleanProductID(remote.weeklyProductId) ?? fallback.weeklyProductID,
            yearlyProductID: cleanProductID(variant?.yearlyProductId) ?? cleanProductID(remote.yearlyProductId) ?? fallback.yearlyProductID,
            annualProductID: cleanProductID(variant?.annualProductId) ?? cleanProductID(remote.annualProductId) ?? fallback.annualProductID,
            yearlyCardPlan: Self.cleanCardPlan(variant?.yearlyCardPlan) ?? Self.cleanCardPlan(remote.yearlyCardPlan) ?? fallback.yearlyCardPlan,
            chooseCard: Self.cleanChooseCard(variant?.chooseCard) ?? Self.cleanChooseCard(remote.chooseCard) ?? fallback.chooseCard,
            freeTest: variant?.freeTest ?? remote.freeTest ?? fallback.freeTest
        )
    }

    private func localizedValue(in values: [String: String]?) -> String? {
        guard let values else { return nil }

        for localeIdentifier in Locale.preferredLanguages + [Locale.current.identifier, "en"] {
            let normalized = localeIdentifier.replacingOccurrences(of: "_", with: "-")
            let candidates = [
                normalized,
                normalized.lowercased(),
                Locale(identifier: normalized).languageCode,
                normalized.split(separator: "-").first.map(String.init)
            ].compactMap { $0 }

            for candidate in candidates {
                if let value = cleanText(values[candidate]) {
                    return value
                }
            }
        }

        return cleanText(values["en"]) ?? values.values.compactMap { cleanText($0) }.first
    }

    private func cleanText(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : value
    }

    private func selectedProductVariant(
        in config: PaywallProductRemoteConfig,
        forKey key: String
    ) -> PaywallProductVariantRemoteConfig? {
        guard let variants = config.variants else { return nil }

        switch variants {
        case .list(let list):
            return selectedProductVariant(from: list, forKey: key)
        case .tiers(let tiers):
            let countryCode = currentCountryCode()
            let tierKey = countryTierMapping.tier(for: countryCode)
            guard let tierConfig = tiers[tierKey] else { return nil }

            if let countryConfig = countryVariantConfig(in: tierConfig, for: countryCode),
               !countryConfig.variants.isEmpty {
                return selectedProductVariant(
                    from: countryConfig.variants,
                    forKey: key,
                    seedScope: "\(tierKey)|\(countryCode)"
                )
            }

            return selectedProductVariant(
                from: tierConfig.defaultVariants,
                forKey: key,
                seedScope: "\(tierKey)|default"
            )
        }
    }

    private func countryVariantConfig(
        in tierConfig: PaywallProductTierVariantsRemoteConfig,
        for countryCode: String
    ) -> PaywallProductCountryVariantsRemoteConfig? {
        guard let countries = tierConfig.countries else { return nil }
        let normalizedCode = PaywallCountryTierMapping.normalizedCountryCode(countryCode)

        if let exact = countries[normalizedCode] {
            return exact
        }

        return countries.first { element in
            PaywallCountryTierMapping.normalizedCountryCode(element.key) == normalizedCode
        }?.value
    }

    private func selectedProductVariant(
        from variants: [PaywallProductVariantRemoteConfig],
        forKey key: String,
        seedScope: String? = nil
    ) -> PaywallProductVariantRemoteConfig? {
        guard !variants.isEmpty else { return nil }
        let totalTraffic = variants.reduce(0) { $0 + $1.effectiveTraffic }
        guard (1...100).contains(totalTraffic) else { return nil }

        let seed = [stableUserID(), key, productsJSONKey, seedScope]
            .compactMap { $0 }
            .joined(separator: "|")
        let bucket = stableBucket(seed: seed, upperBound: 100)
        var cursor = 0
        for variant in variants {
            let traffic = variant.effectiveTraffic
            guard traffic > 0 else { continue }
            cursor += traffic
            if bucket < cursor {
                return variant
            }
        }
        return nil
    }

    private func currentCountryCode() -> String {
        let countryCode: String?
        if #available(iOS 16.0, *) {
            countryCode = Locale.current.region?.identifier ?? Locale.current.regionCode
        } else {
            countryCode = Locale.current.regionCode
        }
        return PaywallCountryTierMapping.normalizedCountryCode(countryCode ?? "unknown")
    }

    private func stableBucket(seed: String, upperBound: Int) -> Int {
        guard upperBound > 0 else { return 0 }
        var hash: UInt64 = 14_695_981_039_346_656_037
        for byte in seed.utf8 {
            hash ^= UInt64(byte)
            hash &*= 1_099_511_628_211
        }
        return Int(hash % UInt64(upperBound))
    }

    private func cleanProductID(_ value: String?) -> String? {
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? nil : trimmed
    }

    private func cleanVariantID(_ value: String?) -> String? {
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? nil : trimmed
    }

    private static func cleanCardPlan(_ value: String?) -> PaywallCardPlan? {
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
        return PaywallCardPlan(rawValue: trimmed)
    }

    private static func cleanChooseCard(_ value: String?) -> PaywallChooseCard? {
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
        return PaywallChooseCard(rawValue: trimmed)
    }

    private static func defaultProductSettings(forKey key: String) -> PaywallProductSettings {
        let weeklyProductID = key == "special"
            ? "kyryloVoinov.WaterEject.subscription.weeklyPecialOffer"
            : "kyryloVoinov.WaterEject.subscription.weekly"
        let defaultChooseCard: PaywallChooseCard = ["first", "second", PaywallVariant.third.rawValue].contains(key)
            ? .second
            : .first

        return PaywallProductSettings(
            variantID: nil,
            weeklyProductID: weeklyProductID,
            yearlyProductID: "kyryloVoinov.WaterEject.subscription.yearly",
            annualProductID: "KyryloVoinov.WaterEject.lifetime.access",
            yearlyCardPlan: .yearly,
            chooseCard: defaultChooseCard,
            freeTest: key == PaywallVariant.fifth.rawValue
        )
    }

    private func stableUserID() -> String {
        let id = Purchases.shared.appUserID
        return id.isEmpty
        ? UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        : id
    }

    private func isEnabled(_ v: PaywallVariant) -> Bool {
        switch v {
        case .third:
            return rc["paywall3_enabled"].boolValue
        case .fourth:
            return rc["paywall4_enabled"].boolValue
        case .fifth:
            return rc["paywall5_enabled"].boolValue
//        case .A, .B:
//            return true
        }
    }

    private func primaryOnboardingVariant(for tag: OnboardTag) -> PaywallVariant {
        switch tag {
        case .v31, .v32, .v33, .v41:        // OnboardingFlowViewTwo / Three
            return .third       // старий пейвол основний
        case .v5, .v6, .v7, .v8, .v9: // нові флоу 5/6/7/8
            return .fourth      // новий пейвол основний
        case .v10:
            return .fifth
        default:
            return .fourth
        }
    }

//    func onboardingPaywallVariant(for tag: OnboardTag) -> PaywallVariant {
//        // 0) форс з RC — як і було, має абсолютний пріоритет
//        let forceKey = rc["paywall_force"].stringValue
//        if !forceKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
//           let forced = parseForcedVariant(forceKey) {
//            return forced
//        }
//
//        let primary  = primaryOnboardingVariant(for: tag)
//        let fallback: PaywallVariant = (primary == .third ? .fourth : .third)
//
//        let primaryEnabled  = isEnabled(primary)
//        let fallbackEnabled = isEnabled(fallback)
//
//        switch (primaryEnabled, fallbackEnabled) {
//        case (true, false):
//            // увімкнений тільки primary → показуємо його
//            return primary
//
//        case (false, true):
//            // увімкнений тільки fallback → показуємо його
//            return fallback
//
//        case (false, false):
//            // обидва вимкнені → безпечний фолбек (щоб не впасти)
//            return primary
//
//        case (true, true):
//            // ⬅️ коли ОБИДВА true робимо стабільний “рандом” 50/50
//            let seed = stableUserID() + "|\(tag.rawValue)|paywallAB"
//            let bucket = abs(seed.hashValue) % 2
//            return (bucket == 0) ? primary : fallback
//        }
//    }

    func onboardingPaywallVariant(for tag: OnboardTag) -> PaywallVariant {
        // 0) RC force
        let forceKey = rc["paywall_force"].stringValue
        if !forceKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
           let forced = parseForcedVariant(forceKey) {
            return forced
        }

        // ✅ 1) якщо увімкнений лише 1 пейвол — він для всіх онбордів
        let enabled = enabledPaywalls()
        if enabled.count == 1 { return enabled[0] }

        let primary = primaryOnboardingVariant(for: tag)

        // якщо раптом всі вимкнені
        guard !enabled.isEmpty else { return primary }

        // fallback = перший увімкнений, який не primary
        let fallback = enabled.first(where: { $0 != primary }) ?? primary

        let primaryEnabled = enabled.contains(primary)
        let fallbackEnabled = enabled.contains(fallback)

        switch (primaryEnabled, fallbackEnabled) {
        case (true, false): return primary
        case (false, true): return fallback
        case (false, false):
            return enabled[0] // ✅ не повертаємо primary, якщо він вимкнений
        case (true, true):
            // стабільний вибір (див. пункт про hashValue нижче)
            let seed = stableUserID() + "|\(tag.rawValue)|paywallAB"
            let bucket = abs(seed.hashValue) % 2

            return (bucket == 0) ? primary : fallback
        }
    }


    func onboardingPaywallView(
        for tag: OnboardTag,
        onFinish: @escaping () -> Void,
        startDelay: Double,
        stepsVisited: [String]?,
        onboardIdOverride: String? = nil
    ) -> AnyView {
        let variant = onboardingPaywallVariant(for: tag)
        let onboardId = onboardIdOverride ?? tag.rawValue

        switch variant {
        case .third:
            return AnyView(
                PaywallThirdView(
                    onFinish: onFinish,
                    onboardId: onboardId,
                    startDelay: startDelay,
                    summaryTag: tag,
                    stepsVisited: stepsVisited
                )
            )

        case .fourth:
            return AnyView(
                PaywallFourView(
                    onFinish: onFinish,
                    onboardId: onboardId,
                    startDelay: startDelay,
                    summaryTag: tag,
                    stepsVisited: stepsVisited
                )
            )

        case .fifth:
            return AnyView(
                PaywallFiveView(
                    onFinish: onFinish,
                    onboardId: onboardId,
                    startDelay: startDelay,
                    summaryTag: tag,
                    stepsVisited: stepsVisited
            )
                )

//        case .A, .B:
//            // якщо колись захочеш ще варіанти – тут можна розширити
//            return AnyView(
//                PaywallStubView(title: "Paywall A/B (stub)", onClose: onFinish)
//            )
        }
    }

    // ❗️Єдина точка, що ставить user property + RC attributes
    private func applyTracking(_ v: PaywallVariant) {
        Analytics.setUserProperty(v.rawValue, forName: "paywall_variant")
        Purchases.shared.attribution.setAttributes(["paywall_variant": v.rawValue])

        let key = "variant_assigned_logged_v1"
        if !UserDefaults.standard.bool(forKey: key) {
            Analytics.logEvent("variant_assigned", parameters: ["variant": v.rawValue])
            UserDefaults.standard.set(true, forKey: key)
        }
    }
    // Допоміжний парсер RC-рядка (ігнорує регістр/пробіли)
    private func parseForcedVariant(_ s: String) -> PaywallVariant? {
        let t = s.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        switch t {
//        case "A":      return .A
//        case "B":      return .B
        case "THIRD", "C", "PAYWALL3": return .third
        case "FOURTH", "PAYWALL4", "D":      // ⬅️ додали
            return .fourth
        case "FIFTH", "PAYWALL5":  return .fifth
        default:       return nil
        }
    }

    func variant() -> PaywallVariant {
        // 1) Якщо у RC заданий форс — він має ПРІОРИТЕТ над кешем
        if let forced = parseForcedVariant(rc["paywall_force"].stringValue) {
            UserDefaults.standard.set(forced.rawValue, forKey: storageKey)
            applyTracking(forced)
            return forced
        }

        // 2) Інакше беремо з кешу
        if let raw = UserDefaults.standard.string(forKey: storageKey),
           let v = PaywallVariant(rawValue: raw) {
            applyTracking(v)
            return v
        }

        // 3) Якщо форсу немає і кешу немає — зробимо спліт (на майбутнє)
        let rawShare = rc["paywall_share_A"].numberValue.intValue
        let shareA = min(max(rawShare, 0), 100)
        let bucket = abs(stableUserID().hashValue) % 100
        //let v: PaywallVariant = (bucket < shareA) ? .A : .B

//        UserDefaults.standard.set(v.rawValue, forKey: storageKey)
//        applyTracking(v)
        return .fourth
    }


    func assignedPaywallView(onFinish: @escaping () -> Void) -> AnyView {
        switch variant() {
        case .third:
            return AnyView(PaywallThirdView(onFinish: onFinish))
        case .fourth:
            // НОВИЙ пейвол як варіант
            return AnyView(
                PaywallFourView(onFinish: onFinish)
            )
        case .fifth:
            return  AnyView(
                PaywallFiveView(onFinish: onFinish)
            )
//        case .A:
//            return AnyView(PaywallStubView(title: "Paywall A (stub)", onClose: onFinish))
//        case .B:
//            return AnyView(PaywallStubView(title: "Paywall B (stub)", onClose: onFinish))
        }
    }
}


// Простенька заглушка, щоб не падало і було що показати
struct PaywallStubView: View {
    let title: String
    let onClose: () -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 16) {
                Text(LocalizedStringKey(title))
                    .foregroundStyle(.white)
                    .font(.title2.bold())
                Button("Close") { onClose() }
                    .buttonStyle(.borderedProminent)
            }
            .padding()
        }
    }
}

enum PaywallRouter {
    static func presentAssigned(from presenter: UIViewController, onFinish: @escaping () -> Void = {}) {
        let view = PaywallAB.shared.assignedPaywallView(onFinish: onFinish)
        let vc = UIHostingController(rootView: view)
        Analytics.logEvent("paywall_exposure", parameters: ["variant": PaywallAB.shared.variant().rawValue])
        Purchases.shared.attribution.setAttributes(["paywall_variant": PaywallAB.shared.variant().rawValue])
        presenter.present(vc, animated: true)
    }
}

extension View {
    func presentAssignedPaywall(onFinish: @escaping () -> Void = {}) {
        guard let root = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?.rootViewController else { return }

        PaywallRouter.presentAssigned(from: root, onFinish: onFinish)
    }
}
