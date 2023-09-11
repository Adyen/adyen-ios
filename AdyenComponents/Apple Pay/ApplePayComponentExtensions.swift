//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import PassKit

/// :nodoc:
extension ApplePayComponent: PKPaymentAuthorizationViewControllerDelegate {
    
    /// :nodoc:
    public func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        paymentAuthorizationViewController = nil
        guard case let .finalized(completion) = state else {
            self.delegate?.didFail(with: ComponentError.cancelled, from: self)
            return
        }

        completion?()
    }
    
    /// :nodoc:
    public func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController,
                                                   didAuthorizePayment payment: PKPayment,
                                                   completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        guard payment.token.paymentData.isEmpty == false else {
            completion(.failure)
            delegate?.didFail(with: Error.invalidToken, from: self)
            return
        }

        state = .paid(completion)
        let token = payment.token.paymentData.base64EncodedString()
        let network = payment.token.paymentMethod.network?.rawValue ?? ""
        let billingContact = payment.billingContact
        let shippingContact = payment.shippingContact
        let details = ApplePayDetails(paymentMethod: applePayPaymentMethod,
                                      token: token,
                                      network: network,
                                      billingContact: billingContact,
                                      shippingContact: shippingContact)
        
        submit(data: PaymentComponentData(paymentMethodDetails: details, amount: internalPayment.amount, order: order))
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

        /// A pre-populated billing address.
        public var billingContact: PKContact?

        /// The flag to toggle onboarding.
        /// If true, allow the shopper to add cards to Apple Pay if non exists yet.
        /// If false, then Apple Pay is disabled if the shopper doesn't have supported cards on Apple Pay wallet.
        public var allowOnboarding: Bool

        /// Initializes the configuration.
        ///
        /// - Parameter summaryItems: The line items for this payment.
        /// - Parameter merchantIdentifier: The merchant identifier.
        /// - Parameter requiredBillingContactFields:
        /// A list of fields that you need for a billing contact in order to process the transaction. Ignored on iOS 10.*.
        /// - Parameter requiredShippingContactFields:
        /// A list of fields that you need for a shipping contact in order to process the transaction. Ignored on iOS 10.*.
        /// - Parameter requiredShippingContactFields: The excluded card brands.
        /// - Parameter billingContact: A pre-populated billing address.
        /// - Parameter allowOnboarding: The flag to toggle onboarding.
        /// If true, allow the shopper to add cards to Apple Pay if non exists yet.
        /// If false, then Apple Pay is disabled if the shopper doesn't have supported cards on Apple Pay wallet.
        /// Default is false.
        public init(summaryItems: [PKPaymentSummaryItem],
                    merchantIdentifier: String,
                    requiredBillingContactFields: Set<PKContactField> = [],
                    requiredShippingContactFields: Set<PKContactField> = [],
                    billingContact: PKContact? = nil,
                    allowOnboarding: Bool = false) {
            self.summaryItems = summaryItems
            self.merchantIdentifier = merchantIdentifier
            self.requiredBillingContactFields = requiredBillingContactFields
            self.requiredShippingContactFields = requiredShippingContactFields
            self.billingContact = billingContact
            self.allowOnboarding = allowOnboarding
        }

        internal func createPaymentRequest(payment: Payment,
                                           supportedNetworks: [PKPaymentNetwork]) -> PKPaymentRequest {
            let paymentRequest = PKPaymentRequest()
            paymentRequest.countryCode = payment.countryCode
            paymentRequest.merchantIdentifier = merchantIdentifier
            paymentRequest.currencyCode = payment.amount.currencyCode
            paymentRequest.supportedNetworks = supportedNetworks
            paymentRequest.merchantCapabilities = .capability3DS
            paymentRequest.paymentSummaryItems = summaryItems
            paymentRequest.requiredBillingContactFields = requiredBillingContactFields
            paymentRequest.requiredShippingContactFields = requiredShippingContactFields
            paymentRequest.billingContact = billingContact
            return paymentRequest
        }

        /// :nodoc:
        public mutating func update(amount: Amount, localeIdentifier: String?) {
            var newItems = summaryItems
            guard let lastItem = newItems.last else { return }

            newItems = newItems.dropLast()
            let decimalAmount = AmountFormatter.decimalAmount(amount.value,
                                                              currencyCode: amount.currencyCode,
                                                              localeIdentifier: localeIdentifier)
            newItems.append(PKPaymentSummaryItem(label: lastItem.label, amount: decimalAmount))
            summaryItems = newItems
        }
    }

}

extension ApplePayPaymentMethod {

    internal static var systemSupportedNetworks: [PKPaymentNetwork] {
        let request = PKPaymentRequest()
        request.supportedNetworks = PKPaymentRequest.availableNetworks()
        return request.supportedNetworks
    }

    internal var supportedNetworks: [PKPaymentNetwork] {
        var networks = ApplePayPaymentMethod.systemSupportedNetworks
        if let brands {
            let brandsSet = Set(brands)
            networks = networks.filter { brandsSet.contains($0.adyenName) }
        }
        return networks
    }

}

extension PKPaymentNetwork {

    internal var adyenName: String {
        if self == .masterCard { return "mc" }
        if #available(iOS 11.2, *), self == .cartesBancaires { return "cartebancaire" }
        return self.rawValue.lowercased()
    }

}
