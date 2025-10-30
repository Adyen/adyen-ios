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
    
    /// Initializes a new instance of `BillingAddressConfiguration`.
    public init() { /* Empty initializer */ }
    
    /// Indicates the display mode of the billing address form. Defaults to none.
    public var mode: CardComponentConfiguration.AddressFormType = .none
    
    /// List of ISO country codes that is supported for the billing address.
    /// When nil, all countries are provided.
    public var countryCodes: [String]?
    
    /// Indicates the requirement level of a field.
    public var requirementPolicy: RequirementPolicy = .required
    
    /// Indicates the requirement level of a field.
    public enum RequirementPolicy {

        /// Field is required.
        case required

        /// Field is optional.
        case optional

        /// Field is optional only for provided card types.
        case optionalForCardTypes(Set<CardType>)
    }
    
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

extension CardComponentConfiguration {
    
    /// The mode of the address form of the card component
    public enum AddressFormType {
        
        /// Display a form item that allows address lookup and entering the address on a separate screen
        case lookup(provider: AddressLookupProvider)

        /// Display full address form
        case full
        
        /// Display simple form with only zip code field
        case postalCode

        /// Do not display address form
        case none
    }

}
