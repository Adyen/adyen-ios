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

    /// The mode of imput field on Component UI
    public enum FieldMode {

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

        /// Indicates whether to show the security fields for South Korea issued cards. Defaults to .auto.
        public var showsKoreanAuthentication: FieldMode

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

        /// Configuration of Card component.
        /// - Parameters:
        ///   - showsHolderNameField: Indicates if the field for entering the holder name should be displayed in the form.
        ///   Defaults to false.
        ///   - showsStorePaymentMethodField: Indicates if the field for storing the card payment method should be displayed in the form.
        ///   Defaults to true.
        ///   - showsSecurityCodeField: Indicates whether to show the security code field at all.
        ///   Defaults to true.
        ///   - showsKoreanAuthentication: Indicates whether to show the security fields for South Korea issued cards.
        ///   Defaults to .auto.
        ///   - billingAddressMode: Indicates mode of how to dispaly the billing address form.
        ///   Defaults to none.
        ///   - storedCardConfiguration: Stored card configuration.
        ///   - allowedCardTypes: The enforced list of allowed card types.
        public init(showsHolderNameField: Bool = false,
                    showsStorePaymentMethodField: Bool = true,
                    showsSecurityCodeField: Bool = true,
                    showsKoreanAuthentication: FieldMode = .auto,
                    billingAddressMode: AddressFormType = .none,
                    storedCardConfiguration: StoredCardConfiguration = StoredCardConfiguration(),
                    allowedCardTypes: [CardType]? = nil) {
            self.showsHolderNameField = showsHolderNameField
            self.showsSecurityCodeField = showsSecurityCodeField
            self.showsStorePaymentMethodField = showsStorePaymentMethodField
            self.stored = storedCardConfiguration
            self.allowedCardTypes = allowedCardTypes
            self.billingAddressMode = billingAddressMode
            self.showsKoreanAuthentication = showsKoreanAuthentication
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
            self.showsKoreanAuthentication != .hide && issuingCountryCode == "KR"
        }
    }

}
