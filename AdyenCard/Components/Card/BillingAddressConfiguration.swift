//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
#if canImport(AdyenUI)
    @_spi(AdyenInternal) import AdyenUI
#endif

// TODO: Add a builder type of chaining to address config
/// Billing address fields configurations
public struct BillingAddressConfiguration {
    
    /// Indicates the requirement level of a field.
    public enum RequirementPolicy {

        /// Field is required.
        case required

        /// Field is optional.
        case optional

        /// Field is optional only for provided card types.
        case optionalForCardTypes(Set<CardType>)
    }
    
    /// The mode of the address form of the card component
    public enum AddressDisplayMode {
        
        /// Display a form item that allows address lookup and entering the address on a separate screen
        case lookup(provider: AddressLookupProvider)

        /// Display full address form
        case full
        
        /// Display simple form with only zip code field
        case postalCode

        /// Do not display address form
        case none
    }
    
    // TODO: Should we provide both init and builder functions?
    /// Initializes a new instance of `BillingAddressConfiguration`.
    public init() {
        self.displayMode = .none
        self.countryCodes = nil
        self.requirementPolicy = .required
    }
    
    /// Indicates the display mode of the billing address form.
    package var displayMode: AddressDisplayMode
    
    /// List of ISO country codes that is supported for the billing address.
    /// When nil, all countries are provided.
    package var countryCodes: [String]?
    
    /// Indicates the requirement level of a field.
    package var requirementPolicy: RequirementPolicy
    
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

extension BillingAddressConfiguration {
    
    /// Sets the display mode of the address form.
    /// - Parameter displayMode: The display mode.
    /// - Returns: A modified copy of the configuration.
    public func displayMode(_ displayMode: AddressDisplayMode) -> Self {
        var copy = self
        copy.displayMode = displayMode
        return copy
    }
    
    /// Sets the supported country codes for the address configuration.
    /// - Parameter countryCodes: List of ISO country codes that is supported for the billing address.
    /// - Returns: A modified copy of the configuration.
    public func countryCodes(_ countryCodes: [String]) -> Self {
        var copy = self
        copy.countryCodes = countryCodes
        return copy
    }
    
    /// Sets the requirement level of fields where applicable.
    /// - Parameter requirementPolicy: The requirement level.
    /// - Returns: A modified copy of the configuration.
    public func requirementPolicy(_ requirementPolicy: RequirementPolicy) -> Self {
        var copy = self
        copy.requirementPolicy = requirementPolicy
        return copy
    }

}
