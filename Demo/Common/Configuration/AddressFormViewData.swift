//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Shared view-model logic for interpreting and mutating a ``BillingAddressSetting``.
///
/// Embedded by the billing-address view models so the setting itself can stay a pure data enum
/// while the derived checks and configuration mutations live in one place.
internal struct AddressFormViewData {

    internal var setting: BillingAddressSetting

    internal init(_ setting: BillingAddressSetting) {
        self.setting = setting
    }

    // MARK: - Interpretation

    /// Whether the form can be hidden for specific card brands (all forms except `.none`).
    internal var supportsCardBrandHiding: Bool {
        if case .none = setting { return false }
        return true
    }

    /// Whether the form supports restricting the available country codes (only `.full`).
    internal var supportsCountryCodeSelection: Bool {
        if case .full = setting { return true }
        return false
    }

    /// Whether `setting` and `other` represent the same form, disregarding their configuration.
    internal func isSameForm(as other: BillingAddressSetting) -> Bool {
        switch (setting, other) {
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

    // MARK: - Configuration

    internal var hideForCardBrands: Set<String> {
        get {
            switch setting {
            case .none: return []
            case let .postalCode(brands),
                 let .lookup(brands),
                 let .lookupMapKit(brands): return brands
            case let .full(_, brands): return brands
            }
        }
        set {
            switch setting {
            case .none: break
            case .postalCode: setting = .postalCode(hideForCardBrands: newValue)
            case let .full(countryCodes, _): setting = .full(supportedCountryCodes: countryCodes, hideForCardBrands: newValue)
            case .lookup: setting = .lookup(hideForCardBrands: newValue)
            case .lookupMapKit: setting = .lookupMapKit(hideForCardBrands: newValue)
            }
        }
    }

    internal var supportedCountryCodes: [String] {
        get {
            guard case let .full(countryCodes, _) = setting else { return [] }
            return countryCodes
        }
        set {
            guard case let .full(_, brands) = setting else { return }
            setting = .full(supportedCountryCodes: newValue, hideForCardBrands: brands)
        }
    }

    // MARK: - Mutation

    /// Switches to `newSetting`, carrying over any configuration shared with the current form.
    internal mutating func select(_ newSetting: BillingAddressSetting) {
        let brands = hideForCardBrands
        let countryCodes = supportedCountryCodes
        setting = newSetting
        hideForCardBrands = brands
        supportedCountryCodes = countryCodes
    }

    internal mutating func toggleBrand(_ rawValue: String) {
        hideForCardBrands.formSymmetricDifference([rawValue])
    }

    internal mutating func toggleCountryCode(_ code: String) {
        if let index = supportedCountryCodes.firstIndex(of: code) {
            supportedCountryCodes.remove(at: index)
        } else {
            supportedCountryCodes.append(code)
        }
    }
}
