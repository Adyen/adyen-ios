//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen

extension CardComponent {

    /// Card component configuration.
    public struct Configuration {

        /// Indicates if the field for entering the holder name should be displayed in the form. Defaults to false.
        public var showsHolderNameField: Bool

        /// Indicates if the field for storing the card payment method should be displayed in the form. Defaults to true.
        public var showsStorePaymentMethodField: Bool

        /// Indicates whether to show the security code field at all. Defaults to true.
        public var showsSecurityCodeField: Bool

        /// Indicates whether to show the address verification form for supported issuing countries. Defaults to true.
        public var showsAddressVerification: Bool

        /// Stored card configuration.
        public var stored: StoredCardConfiguration

        /// The list of allowed card types.  Defaults to nil.
        /// By default list of supported cards is extracted from component's `AnyCardPaymentMethod`.
        /// Use this property to enforce a custom collection of card types.
        public var allowedCardTypes: [CardType]?

        /// Indicates the card brands excluded from the supported brands.
        internal var excludedCardTypes: Set<CardType> = [.bcmc]

        /// Indicates the list of issuing countries where address verification is supported.
        internal var addressVerificationSupportingCountryCodes: Set<String> = ["CA", "US", "UK"] // swiftlint:disable:this identifier_name

        /// Configuration of Card component.
        /// - Parameters:
        ///   - showsHolderNameField: Indicates if the field for entering the holder name should be displayed in the form.
        ///   Defaults to false.
        ///   - showsStorePaymentMethodField: Indicates if the field for storing the card payment method should be displayed in the form.
        ///   Defaults to true.
        ///   - showsSecurityCodeField: Indicates whether to show the security code field at all.
        ///   Defaults to true.
        ///   - showsAddressVerification: Indicates whether to show the address verification form for supported issuing countries.
        ///   Defaults to true.
        ///   - storedCardConfiguration: Stored card configuration.
        ///   - allowedCardTypes: The enforced list of allowed card types.
        public init(showsHolderNameField: Bool = false,
                    showsStorePaymentMethodField: Bool = true,
                    showsSecurityCodeField: Bool = true,
                    showsAddressVerification: Bool = true,
                    storedCardConfiguration: StoredCardConfiguration = StoredCardConfiguration(),
                    allowedCardTypes: [CardType]? = nil) {
            self.showsHolderNameField = showsHolderNameField
            self.showsSecurityCodeField = showsSecurityCodeField
            self.showsStorePaymentMethodField = showsStorePaymentMethodField
            self.stored = storedCardConfiguration
            self.allowedCardTypes = allowedCardTypes
            self.showsAddressVerification = showsAddressVerification
        }

        internal func bcmcConfiguration() -> Configuration {
            var storedCardConfiguration = stored
            storedCardConfiguration.showsSecurityCodeField = false
            var configuration = Configuration(showsHolderNameField: showsHolderNameField,
                                              showsStorePaymentMethodField: showsStorePaymentMethodField,
                                              showsSecurityCodeField: false,
                                              storedCardConfiguration: storedCardConfiguration,
                                              allowedCardTypes: [.bcmc])
            configuration.excludedCardTypes = []
            return configuration
        }
    }

}
