//
//  CountryTierResolver.swift
//  WaterEject
//

import Foundation
import StoreKit

struct CountryTierResolution {
    let countryCode: String
    let source: String
    let tier: String
}

final class CountryTierResolver {
    static let shared = CountryTierResolver()

    private let defaults = UserDefaults.standard
    private let storefrontCountryKey = "country_tier_storefront_country_v1"

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

    private init() {}

    /// Refresh once during boot. The App Store storefront is a better commercial
    /// country signal than the Region selected in Settings.
    func refreshStorefrontCountry() async {
        guard let storefront = await Storefront.current else { return }
        let code = Self.normalizedCountryCode(storefront.countryCode)
        guard code.count == 2 else { return }
        defaults.set(code, forKey: storefrontCountryKey)
    }

    func resolution() -> CountryTierResolution {
        if let cached = defaults.string(forKey: storefrontCountryKey) {
            let code = Self.normalizedCountryCode(cached)
            if code.count == 2 {
                return CountryTierResolution(
                    countryCode: code,
                    source: "app_store_storefront",
                    tier: tier(for: code)
                )
            }
        }

        let localeCode: String?
        if #available(iOS 16.0, *) {
            localeCode = Locale.current.region?.identifier ?? Locale.current.regionCode
        } else {
            localeCode = Locale.current.regionCode
        }
        let code = Self.normalizedCountryCode(localeCode ?? "unknown")
        return CountryTierResolution(
            countryCode: code,
            source: "locale_fallback",
            tier: tier(for: code)
        )
    }

    func tier(for countryCode: String) -> String {
        let code = Self.normalizedCountryCode(countryCode)
        if tier1Countries.contains(code) { return "tier_1" }
        if tier2Countries.contains(code) { return "tier_2" }
        if tier3Countries.contains(code) { return "tier_3" }
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
            return Locale.Region.isoRegions.map(\.identifier)
        }
        return NSLocale.isoCountryCodes
    }
}
