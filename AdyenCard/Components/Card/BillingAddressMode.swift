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
    ///
    /// Supply `AddressCallbacks` in the checkout callbacks to look up and complete addresses.
    /// Without them, `Checkout.setup` throws `CheckoutError` with the `invalidConfiguration` code.
    case lookup(
        hideForCardBrands: Set<CardBrand> = []
    )
}
