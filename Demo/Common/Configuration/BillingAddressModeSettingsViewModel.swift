//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenCard
import SwiftUI

/// Drives ``BillingAddressModeSettingsView`` by exposing the selectable forms and the
/// configuration (card brands, country codes) that applies to the current selection.
///
/// It wraps a `Binding<BillingAddressSetting>` so selections and toggles are written straight back
/// to the source of truth.
internal struct BillingAddressModeSettingsViewModel {

    @Binding private var billingAddress: BillingAddressSetting

    internal init(billingAddress: Binding<BillingAddressSetting>) {
        self._billingAddress = billingAddress
    }

    private var formData: AddressFormViewData {
        get { AddressFormViewData(billingAddress) }
        nonmutating set { billingAddress = newValue.setting }
    }

    // MARK: - Mode selection

    internal let settings = BillingAddressSetting.allCases

    internal func displayName(for setting: BillingAddressSetting) -> String {
        setting.displayName
    }

    internal func isSelected(_ setting: BillingAddressSetting) -> Bool {
        formData.isSameForm(as: setting)
    }

    internal func select(_ setting: BillingAddressSetting) {
        formData.select(setting)
    }

    // MARK: - Hide for card brands

    internal var showsCardBrandHiding: Bool {
        formData.supportsCardBrandHiding
    }

    internal let commonBrands: [CardBrand] = [
        .visa, .masterCard, .americanExpress, .maestro,
        .bcmc, .discover, .jcb, .diners
    ]

    internal var selectedBrandsSummary: String {
        formData.hideForCardBrands
            .map { CardBrand(rawValue: $0).name }
            .sorted()
            .joined(separator: ", ")
    }

    internal func isBrandSelected(_ brand: CardBrand) -> Bool {
        formData.hideForCardBrands.contains(brand.rawValue)
    }

    internal func toggleBrand(_ brand: CardBrand) {
        formData.toggleBrand(brand.rawValue)
    }

    // MARK: - Supported country codes

    internal var showsSupportedCountryCodes: Bool {
        formData.supportsCountryCodeSelection
    }

    internal let commonCountryCodes: [String] = [
        "US", "GB", "NL", "DE", "FR", "BE", "ES", "IT",
        "CA", "AU", "BR", "JP", "CN", "IN", "SG"
    ]

    internal var selectedCountryCodesSummary: String {
        formData.supportedCountryCodes
            .sorted()
            .joined(separator: ", ")
    }

    internal func isCountryCodeSelected(_ code: String) -> Bool {
        formData.supportedCountryCodes.contains(code)
    }

    internal func toggleCountryCode(_ code: String) {
        formData.toggleCountryCode(code)
    }

    internal func countryName(for code: String) -> String {
        Locale.current.localizedString(forRegionCode: code) ?? code
    }
}
