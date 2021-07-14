//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import PassKit

// MARK: - PKPaymentAuthorizationViewControllerDelegate

/// :nodoc:
extension ApplePayComponent: PKPaymentAuthorizationViewControllerDelegate {
    
    /// :nodoc:
    public func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        if isUserCancel {
            self.delegate?.didFail(with: ComponentError.cancelled, from: self)
        }
    }
    
    /// :nodoc:
    public func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController,
                                                   didAuthorizePayment payment: PKPayment,
                                                   completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        paymentAuthorizationCompletion = completion
        
        let token = String(data: payment.token.paymentData, encoding: .utf8) ?? ""
        let network = payment.token.paymentMethod.network?.rawValue ?? ""
        let billingContact = payment.billingContact
        let shippingContact = payment.shippingContact
        let details = ApplePayDetails(paymentMethod: applePayPaymentMethod,
                                      token: token,
                                      network: network,
                                      billingContact: billingContact,
                                      shippingContact: shippingContact)
        
        submit(data: PaymentComponentData(paymentMethodDetails: details))
    }
}

// MARK: - Apple Pay component configuration.

extension ApplePayComponent {
    
    /// Apple Pay component configuration.
    public struct Configuration {
        
        /// The public key used for encrypting card details.
        public var summaryItems: [PKPaymentSummaryItem]
        
        /// The merchant identifier for apple pay.
        public var merchantIdentifier: String
        
        /// A list of fields that you need for a billing contact in order to process the transaction.
        /// Ignored on iOS 10.*.
        public var requiredBillingContactFields: Set<PKContactField> = []
        
        /// A list of fields that you need for a shipping contact in order to process the transaction.
        /// Ignored on iOS 10.*.
        public var requiredShippingContactFields: Set<PKContactField> = []
        
        /// The excluded card brands.
        public var excludedCardNetworks: [PKPaymentNetwork] = []
        
        /// Initializes the configuration.
        ///
        /// - Parameter summaryItems: The line items for this payment.
        /// - Parameter merchantIdentifier: The merchant identifier.
        /// - Parameter requiredBillingContactFields:
        /// A list of fields that you need for a billing contact in order to process the transaction. Ignored on iOS 10.*.
        /// - Parameter requiredShippingContactFields:
        /// A list of fields that you need for a shipping contact in order to process the transaction. Ignored on iOS 10.*.
        /// - Parameter requiredShippingContactFields: The excluded card brands.
        public init(summaryItems: [PKPaymentSummaryItem],
                    merchantIdentifier: String,
                    requiredBillingContactFields: Set<PKContactField> = [],
                    requiredShippingContactFields: Set<PKContactField> = [],
                    excludedCardNetworks: [PKPaymentNetwork] = []) {
            self.summaryItems = summaryItems
            self.merchantIdentifier = merchantIdentifier
            self.requiredBillingContactFields = requiredBillingContactFields
            self.requiredShippingContactFields = requiredShippingContactFields
            self.excludedCardNetworks = excludedCardNetworks
        }
        
        internal var supportedNetworks: [PKPaymentNetwork] {
            var networks: [PKPaymentNetwork] = [.visa, .masterCard, .amex, .discover, .interac]

            if #available(iOS 14.0, *) {
                networks.append(.girocard)
            }
            
            if #available(iOS 12.1.1, *) {
                networks.append(.elo)
            }

            if #available(iOS 12.0, *) {
                networks.append(.maestro)
                networks.append(.electron)
            }
            
            if #available(iOS 10.1, *) {
                networks.append(.JCB)
            }
            
            return networks.filter { !excludedCardNetworks.contains($0) }
        }
        
    }
}
