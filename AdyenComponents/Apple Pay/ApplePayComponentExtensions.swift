//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
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
        let details = ApplePayDetails(paymentMethod: configuration.paymentMethod,
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

        /// The payment method for Apple Pay.
        public let paymentMethod: ApplePayPaymentMethod
        
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

        // :nodoc:
        internal var supportedNetworks: [PKPaymentNetwork] {
            var networks = ApplePayComponent.defaultNetworks
            
            if let brands = paymentMethod.brands {
                let brandsSet = Set(brands)
                networks = networks.filter { brandsSet.contains($0.adyenName) }
            }

            return networks.filter { !excludedCardNetworks.contains($0) }
        }
        
        /// Initializes the configuration.
        ///
        /// - Parameter paymentMethod: The Apple Pay payment method.
        /// - Parameter summaryItems: The line items for this payment.
        /// - Parameter merchantIdentifier: The merchant identifier.
        /// - Parameter requiredBillingContactFields:
        /// A list of fields that you need for a billing contact in order to process the transaction. Ignored on iOS 10.*.
        /// - Parameter requiredShippingContactFields:
        /// A list of fields that you need for a shipping contact in order to process the transaction. Ignored on iOS 10.*.
        /// - Parameter requiredShippingContactFields: The excluded card brands.
        public init(paymentMethod: ApplePayPaymentMethod,
                    summaryItems: [PKPaymentSummaryItem],
                    merchantIdentifier: String,
                    requiredBillingContactFields: Set<PKContactField> = [],
                    requiredShippingContactFields: Set<PKContactField> = [],
                    excludedCardNetworks: [PKPaymentNetwork] = []) {
            self.paymentMethod = paymentMethod
            self.summaryItems = summaryItems
            self.merchantIdentifier = merchantIdentifier
            self.requiredBillingContactFields = requiredBillingContactFields
            self.requiredShippingContactFields = requiredShippingContactFields
            self.excludedCardNetworks = excludedCardNetworks
        }
    }

    // Adyen supports: interac, visa, mc, electron, maestro, amex, jcb, discover, elodebit, elo.
    // Will support girocard in future versions
    internal static var defaultNetworks: [PKPaymentNetwork] {
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

        return networks
    }
}

extension PKPaymentNetwork {

    internal var adyenName: String {
        if self == .masterCard { return "mc" }
        return self.rawValue.lowercased()
    }

}
