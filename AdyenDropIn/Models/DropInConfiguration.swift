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
    final class Configuration: APIContextAware {
        
        /// Card component related configuration.
        public var card = CardComponent.Configuration()
        
        /// The Apple Pay configuration.
        public var applePay: ApplePayConfiguration?
        
        /// Shopper related information
        public var shopper: PrefilledShopperInformation?
        
        /// API context used to retrieve internal resources.
        public let apiContext: APIContext
        
        /// Indicates the localization parameters, leave it nil to use the default parameters.
        public var localizationParameters: LocalizationParameters?

        /// The payment information.
        public var payment: Adyen.Payment?
        
        /// Initializes the drop in configuration.
        /// - Parameters:
        ///   - apiContext: The API context used to retrieve internal resources.
        public init(apiContext: APIContext) {
            self.apiContext = apiContext
        }
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
