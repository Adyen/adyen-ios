//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenUI)
    import AdyenUI
#endif

/// The display mode for the billing address form.
public enum BillingAddressMode {
    
    /// Billing address form is not displayed.
    case none
    
    /// Displays a simplified form with only a postal code field.
    ///
    /// - Parameter hideForCardTypes: Card types for which the postal code field should be hidden
    ///   when detected via BIN lookup.
    case postalCode(
        hideForCardTypes: Set<CardType> = []
    )

    /// Displays the full billing address form with all address fields.
    ///
    /// - Parameters:
    ///   - supportedCountryCodes: List of ISO country codes supported for the billing address.
    ///     When empty, all countries are available.
    ///   - hideForCardTypes: Card types for which the address form should be hidden
    ///     when detected via BIN lookup.
    case full(
        supportedCountryCodes: [String] = [],
        hideForCardTypes: Set<CardType> = []
    )
    
    /// Displays an address lookup interface that allows the shopper to search for their address.
    ///
    /// - Parameters:
    ///   - onAddressLookup: Called when the shopper enters a search term. Returns matching addresses.
    ///   - onAddressSelected: Called when the shopper selects an address from the search results.
    ///     Use this to fetch the complete address details if the initial result was partial.
    ///     If not provided, the selected address is used as-is.
    ///   - hideForCardTypes: Card types for which the address lookup should be hidden
    ///     when detected via BIN lookup.
    case lookup(
        onAddressLookup: (String) async -> [AddressLookupResult],
        onAddressSelected: ((AddressLookupResult) async throws -> PostalAddress)? = nil,
        hideForCardTypes: Set<CardType> = []
    )
}

extension BillingAddressMode {
    
    internal var supportedCountryCodes: [String]? {
        switch self {
        case let .full(supportedCountryCodes, _):
            return supportedCountryCodes.isEmpty ? nil : supportedCountryCodes
        case .none, .postalCode, .lookup:
            return nil
        }
    }
    
    internal var hideForCardTypes: Set<CardType> {
        switch self {
        case .none:
            return []
        case let .postalCode(hideForCardTypes):
            return hideForCardTypes
        case let .full(_, hideForCardTypes):
            return hideForCardTypes
        case let .lookup(_, _, hideForCardTypes):
            return hideForCardTypes
        }
    }
    
    internal func shouldHide(for cardTypes: [CardType]) -> Bool {
        !hideForCardTypes.isDisjoint(with: cardTypes)
    }
}
