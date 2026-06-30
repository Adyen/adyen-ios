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
    /// - Parameter hideForCardBrands: Card brands for which the postal code field should be hidden
    ///   when detected via BIN lookup.
    case postalCode(
        hideForCardBrands: Set<CardBrand> = []
    )

    /// Displays the full billing address form with all address fields.
    ///
    /// - Parameters:
    ///   - supportedCountryCodes: List of ISO country codes supported for the billing address.
    ///     When empty, all countries are available.
    ///   - hideForCardBrands: Card brands for which the address form should be hidden
    ///     when detected via BIN lookup.
    case full(
        supportedCountryCodes: [String] = [],
        hideForCardBrands: Set<CardBrand> = []
    )
    
    /// Displays an address lookup interface that allows the shopper to search for their address.
    ///
    /// - Parameters:
    ///   - hideForCardBrands: Card brands for which the address lookup should be hidden
    ///     when detected via BIN lookup.
    ///   - onAddressLookup: Called when the shopper enters a search term. Returns matching addresses.
    ///   - onAddressSelected: Called when the shopper selects an address from the search results.
    ///     Use this to fetch the complete address details if the initial result was partial.
    ///     If not provided, the selected address is used as-is.
    case lookup(
        hideForCardBrands: Set<CardBrand> = [],
        onAddressLookup: (String) async -> [AddressLookupResult],
        onAddressSelected: ((AddressLookupResult) async throws -> PostalAddress)? = nil
    )
}
