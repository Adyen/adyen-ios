//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen

extension CardComponent {

    /// The mode of address form of card component
    public enum AddressFormType {

        /// Display full address form
        case full

        /// Display simple form with only zip code field
        case postalCode

        /// Do not display address form
        case none
    }

    /// The mode of input field on Component UI
    public enum FieldVisibility {

        /// Always show the field.
        case show

        /// Never show the field.
        case hide

        /// Show the field when a specific condition is met.
        case auto
    }

    /// Card component configuration.
    public struct Configuration {

        /// Indicates if the field for entering the holder name should be displayed in the form. Defaults to false.
        public var showsHolderNameField: Bool

        /// Indicates if the field for storing the card payment method should be displayed in the form. Defaults to true.
        public var showsStorePaymentMethodField: Bool

        /// Indicates whether to show the security code field at all. Defaults to true.
        public var showsSecurityCodeField: Bool

        /// Indicates whether to show the security fields for South Korea issued cards. Defaults to `auto`.
        /// In AUTO mode the field will appear only for card issued in "KR" (South Korea).
        public var koreanAuthenticationMode: FieldVisibility

        /// Indicates the visibility mode for the social security number field (CPF/CNPJ) for Brazilian cards. Defaults to `auto`.
        /// In `auto` mode the field will appear based on card bin lookup.
        public var socialSecurityNumberMode: FieldVisibility

        /// Indicates the display mode of the billing address form. Defaults to none.
        public var billingAddressMode: AddressFormType

        /// Stored card configuration.
        public var stored: StoredCardConfiguration

        /// The list of allowed card types.  Defaults to nil.
        /// By default list of supported cards is extracted from component's `AnyCardPaymentMethod`.
        /// Use this property to enforce a custom collection of card types.
        public var allowedCardTypes: [CardType]?

        /// Indicates the card brands excluded from the supported brands.
        internal var excludedCardTypes: Set<CardType> = [.bcmc]

        /// Installments options to present to the user.
        public var installmentConfiguration: InstallmentConfiguration?
        
        /// List of ISO country codes that is supported for the billing address.
        /// When nil, all countries are provided.
        public var billingAddressCountryCodes: [String]?

        /// Configuration of Card component.
        /// - Parameters:
        ///   - showsHolderNameField: Indicates if the field for entering the holder name should be displayed in the form.
        ///   Defaults to false.
        ///   - showsStorePaymentMethodField: Indicates if the field for storing the card payment method should be displayed in the form.
        ///   Defaults to true.
        ///   - showsSecurityCodeField: Indicates whether to show the security code field at all.
        ///   Defaults to true.
        ///   - koreanAuthenticationMode: Indicates whether to show the security fields for South Korea issued cards.
        ///   Defaults to .auto.
        ///   - billingAddressMode: Indicates mode of how to display the billing address form.
        ///   Defaults to none.
        ///   - storedCardConfiguration: Stored card configuration.
        ///   - allowedCardTypes: The enforced list of allowed card types.
        ///   - installmentConfiguration: Configuration for installments. Defaults to `nil`.
        ///   - billingAddressCountryCodes: List of ISO country codes that is supported for the billing address.
        ///   Defaults to `nil`, which equals to all countries.
        public init(showsHolderNameField: Bool = false,
                    showsStorePaymentMethodField: Bool = true,
                    showsSecurityCodeField: Bool = true,
                    koreanAuthenticationMode: FieldVisibility = .auto,
                    socialSecurityNumberMode: FieldVisibility = .auto,
                    billingAddressMode: AddressFormType = .none,
                    storedCardConfiguration: StoredCardConfiguration = StoredCardConfiguration(),
                    allowedCardTypes: [CardType]? = nil,
                    installmentConfiguration: InstallmentConfiguration? = nil,
                    billingAddressCountryCodes: [String]? = nil) {
            self.showsHolderNameField = showsHolderNameField
            self.showsSecurityCodeField = showsSecurityCodeField
            self.showsStorePaymentMethodField = showsStorePaymentMethodField
            self.stored = storedCardConfiguration
            self.allowedCardTypes = allowedCardTypes
            self.billingAddressMode = billingAddressMode
            self.koreanAuthenticationMode = koreanAuthenticationMode
            self.socialSecurityNumberMode = socialSecurityNumberMode
            self.installmentConfiguration = installmentConfiguration
            self.billingAddressCountryCodes = billingAddressCountryCodes
        }

        internal func bcmcConfiguration() -> Configuration {
            var storedCardConfiguration = stored
            storedCardConfiguration.showsSecurityCodeField = false
            var configuration = Configuration(showsHolderNameField: showsHolderNameField,
                                              showsStorePaymentMethodField: showsStorePaymentMethodField,
                                              showsSecurityCodeField: false,
                                              billingAddressMode: .none,
                                              storedCardConfiguration: storedCardConfiguration,
                                              allowedCardTypes: [.bcmc])
            configuration.excludedCardTypes = []
            return configuration
        }

        internal func showAdditionalAuthenticationFields(for issuingCountryCode: String?) -> Bool {
            koreanAuthenticationMode != .hide && issuingCountryCode == "KR"
        }
    }

}
