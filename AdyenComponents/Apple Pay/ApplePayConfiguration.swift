//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation
import PassKit

// MARK: - Apple Pay component configuration.

extension ApplePayComponent {

    /// Apple Pay component configuration.

    public struct Configuration {

        /// The context of a current payment. Contains
        public private(set) var applePayPayment: ApplePayPayment

        /// The merchant identifier for apple pay.
        public let merchantIdentifier: String

        /// A list of fields that you need for a billing contact in order to process the transaction.
        /// Ignored on iOS 10.*.
        public var requiredBillingContactFields: Set<PKContactField> = []

        /// A list of fields that you need for a shipping contact in order to process the transaction.
        /// Ignored on iOS 10.*.
        public var requiredShippingContactFields: Set<PKContactField> = []

        /// A pre-filled billing address.
        public var billingContact: PKContact?

        /// The flag to toggle onboarding.
        /// If true, allow the shopper to add cards to Apple Pay if non exists yet.
        /// If false, then Apple Pay is disabled if the shopper doesn't have supported cards on Apple Pay wallet.
        /// Default is false.
        public var allowOnboarding: Bool = false

        /// A pre-filled shipping address.
        public var shippingContact: PKContact?

        /// Indicates the display mode for the shipping (e.g, "Pick Up", "Ship To", "Deliver To"). Localized.
        /// The default is PKShippingTypeShipping
        public var shippingType: PKShippingType = .shipping

        /// Determine whether to disable editing of the shipping contact field before displaying the payment sheet.
        /// The default is true.
        public let allowShippingContactEditing: Bool = true

        /// An array of shipping method objects that describe the supported shipping methods.
        public var shippingMethods: [PKShippingMethod]?

        /// Optional merchant-supplied information about the payment request.  Examples of this are an order
        /// or cart identifier.  It will be signed and included in the resulting PKPaymentToken.
        public var applicationData: Data?

        /// A list of ISO 3166 country codes to limit payments to cards from specific countries or regions.
        public var supportedCountries: Set<String>?

        /// Indicates whether the merchant supports coupon code entry and validation. Defaults to NO.
        public var supportsCouponCode: Bool = false

        /// An optional coupon code that is valid and has been applied to the payment request already.
        public var couponCode: String?

        /// Initializes the configuration.
        ///
        /// - Parameter payment: Instance of ApplePay Payment object.
        /// - Parameter merchantIdentifier: The merchant identifier.
        public init(payment: ApplePayPayment,
                    merchantIdentifier: String) {
            self.applePayPayment = payment
            self.merchantIdentifier = merchantIdentifier
        }

        internal func createPaymentRequest(supportedNetworks: [PKPaymentNetwork]) -> PKPaymentRequest {
            let paymentRequest = PKPaymentRequest()
            paymentRequest.countryCode = applePayPayment.countryCode
            paymentRequest.merchantIdentifier = merchantIdentifier
            paymentRequest.currencyCode = applePayPayment.currencyCode
            paymentRequest.supportedNetworks = supportedNetworks
            paymentRequest.merchantCapabilities = .capability3DS
            paymentRequest.paymentSummaryItems = applePayPayment.summaryItems
            paymentRequest.requiredBillingContactFields = requiredBillingContactFields
            paymentRequest.requiredShippingContactFields = requiredShippingContactFields
            paymentRequest.billingContact = billingContact
            paymentRequest.shippingContact = shippingContact
            paymentRequest.shippingType = shippingType
            paymentRequest.supportedCountries = supportedCountries
            paymentRequest.shippingMethods = shippingMethods

            if #available(iOS 15.0, *) {
                paymentRequest.couponCode = couponCode
                paymentRequest.supportsCouponCode = supportsCouponCode
                paymentRequest.shippingContactEditingMode = allowShippingContactEditing ? .enabled : .storePickup
            }

            return paymentRequest
        }

        @_spi(AdyenInternal)
        public func replacing(amount: Amount) -> Self {
            var newConfig = self
            newConfig.applePayPayment.update(amount: amount)
            return newConfig
        }

    }

}

extension ApplePayPaymentMethod {

    internal var supportedNetworks: [PKPaymentNetwork] {
        var networks = PKPaymentRequest.availableNetworks()
        if let brands = brands {
            let brandsSet = Set(brands)
            networks = networks.filter { brandsSet.contains($0.txVariantName) }
        }
        return networks
    }

}

extension PKPaymentNetwork {

    internal var txVariantName: String {
        if self == .masterCard { return "mc" }
        if #available(iOS 11.2, *), self == .cartesBancaires { return "cartebancaire" }
        return self.rawValue.lowercased()
    }

}
