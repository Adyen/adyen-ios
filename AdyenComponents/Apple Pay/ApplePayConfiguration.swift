//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import PassKit

// MARK: - Apple Pay component configuration.

extension ApplePayComponent {

    /// Apple Pay component configuration.
    public struct Configuration {

        /// The context of a current payment. Contains 
        public let payment: ApplePayPayment

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
        /// If true, allow the shopper to add cards to Apple Pay if none exists yet.
        /// If false, then Apple Pay is disabled if the shopper doesn't have supported cards on Apple Pay wallet.
        /// Default is false.
        public init(payment: ApplePayPayment,
                    merchantIdentifier: String,
                    requiredBillingContactFields: Set<PKContactField> = [],
                    requiredShippingContactFields: Set<PKContactField> = [],
                    billingContact: PKContact? = nil,
                    allowOnboarding: Bool = false) {
            self.payment = payment
            self.merchantIdentifier = merchantIdentifier
            self.requiredBillingContactFields = requiredBillingContactFields
            self.requiredShippingContactFields = requiredShippingContactFields
            self.billingContact = billingContact
            self.allowOnboarding = allowOnboarding
        }

        internal func createPaymentRequest(supportedNetworks: [PKPaymentNetwork]) -> PKPaymentRequest {
            let paymentRequest = PKPaymentRequest()
            paymentRequest.countryCode = payment.countryCode
            paymentRequest.merchantIdentifier = merchantIdentifier
            paymentRequest.currencyCode = payment.currencyCode
            paymentRequest.supportedNetworks = supportedNetworks
            paymentRequest.merchantCapabilities = .capability3DS
            paymentRequest.paymentSummaryItems = payment.summaryItems
            paymentRequest.requiredBillingContactFields = requiredBillingContactFields
            paymentRequest.requiredShippingContactFields = requiredShippingContactFields
            paymentRequest.billingContact = billingContact
            return paymentRequest
        }
    }

    // Adyen supports: interac, visa, mc, electron, maestro, amex, jcb, discover, elodebit, elo.
    // Will support girocard in future versions
    internal static var defaultNetworks: [PKPaymentNetwork] {
        var networks: [PKPaymentNetwork] = [
            .visa,
            .masterCard,
            .amex,
            .discover,
            .interac,
            .JCB,
            .suica,
            .quicPay,
            .idCredit,
            .chinaUnionPay
        ]

        if #available(iOS 11.2, *) {
            networks.append(.cartesBancaires)
        }

        if #available(iOS 12.1.1, *) {
            networks.append(.elo)
            networks.append(.mada)
        }

        if #available(iOS 12.0, *) {
            networks.append(.maestro)
            networks.append(.electron)
            networks.append(.vPay)
            networks.append(.eftpos)
        }

        if #available(iOS 14.0, *) {
            networks.append(.girocard)
        }

        if #available(iOS 14.5, *) {
            networks.append(.mir)
        }

        return networks
    }

}

extension ApplePayPaymentMethod {

    internal var supportedNetworks: [PKPaymentNetwork] {
        var networks = ApplePayComponent.defaultNetworks
        if let brands = brands {
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
