//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation
import PassKit

#if canImport(AdyenUI)
    import AdyenUI
#endif

/// Configuration for the Apple Pay payment component.
public struct ApplePayConfiguration: CheckoutComponentConfiguration {

    package let componentType: CheckoutComponentType = .payment(.applePay)

    /// Meaningless for Apple Pay (the system renders its own button); kept to satisfy the protocol.
    package var showsSubmitButton: Bool = true

    package var theme: CheckoutTheme = .default

    package var localizationParameters: LocalizationParameters?

    /// The flag to toggle onboarding.
    /// If true, allow the shopper to add cards to Apple Pay if non exists yet.
    /// If false, then Apple Pay is disabled if the shopper doesn't have supported cards on Apple Pay wallet.
    /// Default is false.
    public var allowOnboarding: Bool = false

    /// Called when the shopper authorizes the payment, before `onSubmit`.
    ///
    /// Use this closure to validate the shopper's payment information (e.g., billing/shipping address)
    /// before the payment is submitted. You can perform synchronous or asynchronous validation,
    /// including backend calls if needed.
    ///
    /// Return `.success` to proceed with submission, or `.failure` with errors to let the shopper retry.
    ///
    /// - Note: Return `.failure` with non-empty `errors` to keep the sheet open for correction.
    ///   Use `PKPaymentRequest.paymentBillingAddressInvalidError(withKey:localizedDescription:)` or similar
    ///   factory methods to create field-specific errors.
    public var onAuthorize: (@MainActor (PKPayment) async -> PKPaymentAuthorizationResult)?

    /// Called when the shopper selects a shipping contact.
    ///
    /// Return an updated `PKPaymentRequestShippingContactUpdate` with revised summary items
    /// and optionally updated shipping methods or errors.
    public var onShippingContactChange: (@MainActor (PKContact, [PKPaymentSummaryItem]) async -> PKPaymentRequestShippingContactUpdate)?

    /// Called when the shopper selects a shipping method.
    ///
    /// Return an updated `PKPaymentRequestShippingMethodUpdate` with revised summary items.
    public var onShippingMethodChange: (@MainActor (PKShippingMethod, [PKPaymentSummaryItem]) async -> PKPaymentRequestShippingMethodUpdate)?

    /// Called when the shopper enters or updates a coupon code.
    ///
    /// Return an updated `PKPaymentRequestCouponCodeUpdate` with revised summary items.
    public var onCouponCodeChange: (@MainActor (String, [PKPaymentSummaryItem]) async -> PKPaymentRequestCouponCodeUpdate)?

    /// The payment request object needed for Apple Pay. Must contain all the required fields
    /// such as `merchantIdentifier`, `summaryItems`, `currencyCode`, and `countryCode`.
    internal var paymentRequest: PKPaymentRequest

    /// Initializes the Apple Pay configuration with a Payment Request.
    /// - Parameters:
    ///   - paymentRequest: The payment request object needed for Apple Pay. Must contain all the required fields
    ///   such as `merchantIdentifier`, `summaryItems`, `currencyCode`, and `countryCode`.
    ///   - allowOnboarding: Flag to allow shoppers to add new cards for Apple Pay  if there is none. Default is `false`.
    /// - Warning: The instance of `paymentRequest` may be mutated.
    /// - Note: Use this initializer to support any new additions to the `PKPaymentRequest` object,
    ///  such as recurring payments via its `recurringPaymentRequest` property.
    /// - Throws: `ApplePayComponent.Error.emptyMerchantIdentifier` if the merchant identifier is empty.
    /// - Throws: `ApplePayComponent.Error.invalidCountryCode` if the country code is not valid.
    /// - Throws: `ApplePayComponent.Error.invalidCurrencyCode` if the currency code is not valid.
    /// - Throws: `ApplePayComponent.Error.emptySummaryItems` if the summaryItems array is empty.
    /// - Throws: `ApplePayComponent.Error.negativeGrandTotal` if the grand total is negative.
    /// - Throws: `ApplePayComponent.Error.invalidSummaryItem` if at least one of the summary items has an invalid amount.
    public init(
        paymentRequest: PKPaymentRequest,
        allowOnboarding: Bool = false
    ) throws {
        guard !paymentRequest.merchantIdentifier.isEmpty else {
            throw ApplePayComponent.Error.emptyMerchantIdentifier
        }
        guard CountryCodeValidator().isValid(paymentRequest.countryCode) else {
            throw ApplePayComponent.Error.invalidCountryCode
        }
        guard CurrencyCodeValidator().isValid(paymentRequest.currencyCode) else {
            throw ApplePayComponent.Error.invalidCurrencyCode
        }
        try Self.validate(summaryItems: paymentRequest.paymentSummaryItems)

        self.paymentRequest = paymentRequest
        self.allowOnboarding = allowOnboarding
    }

    internal static func validate(summaryItems: [PKPaymentSummaryItem]) throws {
        guard !summaryItems.isEmpty else {
            throw ApplePayComponent.Error.emptySummaryItems
        }
        guard let lastItem = summaryItems.last,
              lastItem.amount.doubleValue >= 0 else {
            throw ApplePayComponent.Error.negativeGrandTotal
        }
        guard !summaryItems.map(\.amount).contains(NSDecimalNumber.notANumber) else {
            throw ApplePayComponent.Error.invalidSummaryItem
        }
    }

    internal mutating func paymentRequest(with supportedNetworks: [PKPaymentNetwork]) -> PKPaymentRequest {
        paymentRequest.supportedNetworks = supportedNetworks
        return paymentRequest
    }

    package var currentAmount: Amount? {
        guard let lastItem = paymentRequest.paymentSummaryItems.last else { return nil }
        let minorUnits = AmountFormatter.minorUnitAmount(
            from: lastItem.amount.decimalValue,
            currencyCode: paymentRequest.currencyCode
        )
        return Amount(value: minorUnits, currencyCode: paymentRequest.currencyCode)
    }

    package func replacing(amount: Amount) -> Self {
        let newConfig = self
        guard let lastItem = newConfig.paymentRequest.paymentSummaryItems.last else { return newConfig }

        var newItems = Array(newConfig.paymentRequest.paymentSummaryItems.dropLast())
        let decimalAmount = AmountFormatter.decimalAmount(
            amount.value,
            currencyCode: amount.currencyCode,
            localeIdentifier: amount.localeIdentifier
        )
        newItems.append(PKPaymentSummaryItem(label: lastItem.label, amount: decimalAmount))
        newConfig.paymentRequest.paymentSummaryItems = newItems
        return newConfig
    }
}

extension ApplePayPaymentMethod {

    internal func supportedNetworks(
        provider: ApplePayNetworksProviding = ApplePayNetworksProvider()
    ) -> [PKPaymentNetwork] {
        let networks = provider.availableNetworks()
        guard let brands else { return networks }

        // Build a lookup table from txVariantName → PKPaymentNetwork.
        // Some networks appear more than once on iOS (e.g., cartebancaire), so we
        // keep the first occurrence and ignore duplicates.
        let networkByBrand: [String: PKPaymentNetwork] = networks.reduce(into: [:]) { dict, network in
            if dict[network.txVariantName] == nil {
                dict[network.txVariantName] = network
            }
        }

        return brands.compactMap { networkByBrand[$0] }
    }
}

extension PKPaymentNetwork {

    internal var txVariantName: String {
        if self == .masterCard { return "mc" }
        if self == .cartesBancaires { return "cartebancaire" }
        return self.rawValue.lowercased()
    }

}
