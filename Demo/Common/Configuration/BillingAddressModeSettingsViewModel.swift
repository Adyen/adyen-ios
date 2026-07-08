//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenCard
import SwiftUI

internal struct BillingAddressModeSettingsViewModel {

    @Binding private var billingAddress: BillingAddressModeDemoSetting

    internal init(billingAddress: Binding<BillingAddressModeDemoSetting>) {
        self._billingAddress = billingAddress
    }

    // MARK: - Mode selection

    internal let settings = BillingAddressModeDemoSetting.allCases

    internal func displayName(for setting: BillingAddressModeDemoSetting) -> String {
        setting.displayName
    }

    /// Whether `setting` is the currently selected form, disregarding its configuration.
    internal func isSelected(_ setting: BillingAddressModeDemoSetting) -> Bool {
        switch (billingAddress, setting) {
        case (.none, .none),
             (.postalCode, .postalCode),
             (.full, .full),
             (.lookup, .lookup),
             (.lookupMapKit, .lookupMapKit):
            return true
        default:
            return false
        }
    }

    internal func select(_ setting: BillingAddressModeDemoSetting) {
        guard !isSelected(setting) else { return }
        billingAddress = setting
    }

    // MARK: - Hide for card brands

    internal var showsCardBrandHiding: Bool {
        switch billingAddress {
        case .postalCode, .full, .lookup, .lookupMapKit: return true
        case .none: return false
        }
    }

    internal let commonBrands: [CardBrand] = [
        .visa, .masterCard, .americanExpress, .maestro,
        .bcmc, .discover, .jcb, .diners
    ]

    internal var selectedBrandsSummary: String {
        hideForCardBrands
            .map { CardBrand(rawValue: $0).name }
            .sorted()
            .joined(separator: ", ")
    }

    internal func isBrandSelected(_ brand: CardBrand) -> Bool {
        hideForCardBrands.contains(brand.rawValue)
    }

    internal func toggleBrand(_ brand: CardBrand) {
        var brands = hideForCardBrands
        let rawValue = brand.rawValue
        if brands.contains(rawValue) {
            brands.remove(rawValue)
        } else {
            brands.insert(rawValue)
        }
        billingAddress = billingAddress.withConfiguration(
            hideForCardBrands: brands,
            supportedCountryCodes: supportedCountryCodes
        )
    }

    // MARK: - Supported country codes

    internal var showsSupportedCountryCodes: Bool {
        switch billingAddress {
        case .full: return true
        case .none, .postalCode, .lookup, .lookupMapKit: return false
        }
    }

    internal let commonCountryCodes: [String] = [
        "US", "GB", "NL", "DE", "FR", "BE", "ES", "IT",
        "CA", "AU", "BR", "JP", "CN", "IN", "SG"
    ]

    internal var selectedCountryCodesSummary: String {
        supportedCountryCodes
            .sorted()
            .joined(separator: ", ")
    }

    internal func isCountryCodeSelected(_ code: String) -> Bool {
        supportedCountryCodes.contains(code)
    }

    internal func toggleCountryCode(_ code: String) {
        var countryCodes = supportedCountryCodes
        if let index = countryCodes.firstIndex(of: code) {
            countryCodes.remove(at: index)
        } else {
            countryCodes.append(code)
        }
        billingAddress = billingAddress.withConfiguration(
            hideForCardBrands: hideForCardBrands,
            supportedCountryCodes: countryCodes
        )
    }

    internal func countryName(for code: String) -> String {
        Locale.current.localizedString(forRegionCode: code) ?? code
    }

    // MARK: - Current configuration

    private var hideForCardBrands: Set<String> {
        switch billingAddress {
        case .none:
            return []
        case let .postalCode(brands),
             let .lookup(brands),
             let .lookupMapKit(brands):
            return brands
        case let .full(_, brands):
            return brands
        }
    }

    private var supportedCountryCodes: [String] {
        guard case let .full(countryCodes, _) = billingAddress else { return [] }
        return countryCodes
    }
}

private extension BillingAddressModeDemoSetting {
    func withConfiguration(hideForCardBrands: Set<String>, supportedCountryCodes: [String]) -> BillingAddressModeDemoSetting {
        switch self {
        case .none: return .none
        case .postalCode: return .postalCode(hideForCardBrands: hideForCardBrands)
        case .full: return .full(supportedCountryCodes: supportedCountryCodes, hideForCardBrands: hideForCardBrands)
        case .lookup: return .lookup(hideForCardBrands: hideForCardBrands)
        case .lookupMapKit: return .lookupMapKit(hideForCardBrands: hideForCardBrands)
        }
    }
}
