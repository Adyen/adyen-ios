//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
#if canImport(AdyenUI)
    @_spi(AdyenInternal) import AdyenUI
#endif

/// The display mode for the billing address form.
public enum BillingAddressMode {
    
    /// Billing address form is not displayed.
    case none
    
    /// Displays a simplified form with only a postal code field.
    case postalCode

    /// Displays the full billing address form with all address fields.
    case full
    
    /// Displays an address lookup interface that allows the shopper to search for their address.
    ///
    /// - Parameters:
    ///   - onAddressLookup: Called when the shopper enters a search term. Returns matching addresses.
    ///   - onAddressSelected: Called when the shopper selects an address from the search results.
    ///     Use this to fetch the complete address details if the initial result was partial.
    ///     If not provided, the selected address is used as-is.
    case lookup(
        onAddressLookup: (String) async -> [AddressLookupResult],
        onAddressSelected: ((AddressLookupResult) async throws -> PostalAddress)? = nil
    )
}

/// Billing address fields configurations
package struct BillingAddressConfiguration {
    
    /// Indicates the requirement level of a field.
    public enum RequirementPolicy {

        /// Field is required.
        case required

        /// Field is optional.
        case optional

        /// Field is optional only for provided card types.
        case optionalForCardTypes(Set<CardType>)
    }
    
    /// Initializes a new instance of `BillingAddressConfiguration`.
    package init() {
        self.mode = .none
        self.countryCodes = nil
        self.requirementPolicy = .required
    }
    
    /// Indicates the display mode of the billing address form.
    package var mode: BillingAddressMode = .none
    
    /// List of ISO country codes that is supported for the billing address.
    /// When nil, all countries are provided.
    package var countryCodes: [String]?
    
    /// Indicates the requirement level of a field.
    package var requirementPolicy: RequirementPolicy = .required
    
    package func isOptional(for cardTypes: [CardType]) -> Bool {
        switch requirementPolicy {
        case .required:
            return false
        case .optional:
            return true
        case let .optionalForCardTypes(optionalCardTypes):
            return !optionalCardTypes.isDisjoint(with: cardTypes)
        }
    }
}
