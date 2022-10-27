//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenCard)
    import AdyenCard
#endif
#if canImport(AdyenComponents)
    import AdyenComponents
#endif
import Foundation
import PassKit

/// :nodoc:
public extension DropInComponent {
    
    /// Contains the configuration for the drop in component and the embedded payment method components.
    final class Configuration: APIContextAware {
        
        /// Card component related configuration.
        public var card = CardComponent.Configuration()
        
        /// The Apple Pay configuration.
        public var applePay: ApplePayComponent.Configuration?
        
        /// Payment methods list related configurations.
        public var paymentMethodsList = PaymentMethodListConfiguration()
        
        /// Shopper related information
        public var shopper: PrefilledShopperInformation?
        
        /// API context used to retrieve internal resources.
        public let apiContext: APIContext
        
        /// Indicates the localization parameters, leave it nil to use the default parameters.
        public var localizationParameters: LocalizationParameters?

        /// The payment information.
        public var payment: Adyen.Payment?
        
        /// Determines whether to enable skipping payment list step
        /// when there is only one non-instant payment method.
        /// Default value: `false`.
        public let allowsSkippingPaymentList: Bool

        /// Determines whether to enable preselected stored payment method view step.
        /// Default value: `true`.
        public let allowPreselectedPaymentView: Bool
        
        /// Initializes the drop in configuration.
        /// - Parameters:
        ///   - apiContext: The API context used to retrieve internal resources.
        ///   - allowsSkippingPaymentList: Boolean to enable skipping payment list when there is only one one non-instant payment method.
        public init(apiContext: APIContext,
                    allowsSkippingPaymentList: Bool = false,
                    allowPreselectedPaymentView: Bool = true) {
            self.apiContext = apiContext
            self.allowsSkippingPaymentList = allowsSkippingPaymentList
            self.allowPreselectedPaymentView = allowPreselectedPaymentView
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
