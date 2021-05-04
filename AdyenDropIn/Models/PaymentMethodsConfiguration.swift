//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenCard)
    import AdyenCard
#endif
import Foundation
import PassKit

public extension DropInComponent {
    
    /// Contains the configuration for the drop in component and the embedded payment method components.
    final class PaymentMethodsConfiguration {
        
        /// Card component related configuration.
        public var card = CardConfiguration()
        
        /// The Apple Pay configuration.
        public var applePay: ApplePayConfiguration?
        
        /// The client key that corresponds to the webservice user you will use for initiating the payment.
        /// See https://docs.adyen.com/user-management/client-side-authentication for more information.
        public var clientKey: String
        
        /// Indicates the localization parameters, leave it nil to use the default parameters.
        public var localizationParameters: LocalizationParameters?

        /// The payment information.
        public var payment: Adyen.Payment?
        
        /// Initializes the drop in configuration.
        public init(clientKey: String) {
            self.clientKey = clientKey
        }
    }

    /// Card component related configuration.
    final class CardConfiguration {

        /// Indicates if the field for entering the holder name should be displayed in the form. Defaults to false.
        public var showsHolderNameField = false

        /// Indicates if the field for storing the card payment method should be displayed in the form. Defaults to true.
        public var showsStorePaymentMethodField = true

        /// Indicates whether to show the security code field in the form.
        public var showsSecurityCodeField = true

        /// Indicates the display mode of the billing address form.
        /// Defaults to none.
        public var billingAddress: CardComponent.AddressFormType = .none

        /// Stored card configuration.
        public var stored = StoredCardConfiguration()

    }

    /// Apple Pay component configuration.
    final class ApplePayConfiguration {

        /// Create new instance of ApplePayConfiguration
        public init(summaryItems: [PKPaymentSummaryItem],
                    merchantIdentifier: String,
                    requiredBillingContactFields: Set<PKContactField> = [],
                    requiredShippingContactFields: Set<PKContactField> = []) {
            self.summaryItems = summaryItems
            self.merchantIdentifier = merchantIdentifier
            self.requiredBillingContactFields = requiredBillingContactFields
            self.requiredShippingContactFields = requiredShippingContactFields
        }

        /// The public key used for encrypting card details.
        public var summaryItems: [PKPaymentSummaryItem]

        /// The merchant identifier for apple pay.
        public var merchantIdentifier: String

        /// A list of fields that you need for a billing contact in order to process the transaction.
        public var requiredBillingContactFields: Set<PKContactField> = []

        /// A list of fields that you need for a shipping contact in order to process the transaction.
        public var requiredShippingContactFields: Set<PKContactField> = []

    }
    
}
