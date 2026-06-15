//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
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

    package var localizationProvider: (any CheckoutLocalizationProvider)?

    /// The flag to toggle onboarding.
    /// If true, allow the shopper to add cards to Apple Pay if none exists yet.
    /// If false, then Apple Pay is disabled if the shopper doesn't have supported cards on Apple Pay wallet.
    internal var allowOnboarding: Bool = true

    internal var onAuthorize: (@MainActor (PKPayment) async -> PKPaymentAuthorizationResult)?

    internal var onSelectShippingContact: (
        @MainActor (
            PKContact,
            [PKPaymentSummaryItem]
        ) async -> PKPaymentRequestShippingContactUpdate
    )?

    internal var onSelectShippingMethod: (
        @MainActor (
            PKShippingMethod,
            [PKPaymentSummaryItem]
        ) async -> PKPaymentRequestShippingMethodUpdate
    )?

    internal var onChangeCouponCode: (
        @MainActor (
            String,
            [PKPaymentSummaryItem]
        ) async -> PKPaymentRequestCouponCodeUpdate
    )?

    internal var onPaymentMethodChange: (
        @MainActor (
            PKPaymentMethod,
            [PKPaymentSummaryItem]
        ) async -> PKPaymentRequestPaymentMethodUpdate
    )?

    /// The payment request object needed for Apple Pay. Must contain all the required fields
    /// such as `merchantIdentifier`, `summaryItems`, `currencyCode`, and `countryCode`.
    internal var paymentRequest: PKPaymentRequest

    /// Initializes the Apple Pay configuration with a Payment Request.
    /// - Parameters:
    ///   - paymentRequest: The payment request object needed for Apple Pay. Must contain all the required fields
    ///   such as `merchantIdentifier`, `summaryItems`, `currencyCode`, and `countryCode`.
    /// - Warning: The instance of `paymentRequest` may be mutated.
    /// - Throws: `ApplePayComponent.Error.emptyMerchantIdentifier` if the merchant identifier is empty.
    /// - Throws: `ApplePayComponent.Error.invalidCountryCode` if the country code is not valid.
    /// - Throws: `ApplePayComponent.Error.invalidCurrencyCode` if the currency code is not valid.
    /// - Throws: `ApplePayComponent.Error.emptySummaryItems` if the summaryItems array is empty.
    /// - Throws: `ApplePayComponent.Error.negativeGrandTotal` if the grand total is negative.
    /// - Throws: `ApplePayComponent.Error.invalidSummaryItem` if at least one of the summary items has an invalid amount.
    public init(
        paymentRequest: PKPaymentRequest
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
    }

    internal static func validate(summaryItems: [PKPaymentSummaryItem]) throws {
        guard !summaryItems.isEmpty else {
            throw ApplePayComponent.Error.emptySummaryItems
        }
        guard let lastItem = summaryItems.last,
              lastItem.amount.doubleValue >= 0 else {
            throw ApplePayComponent.Error.negativeGrandTotal
        }
        guard summaryItems.allSatisfy({ $0.amount != .notANumber }) else {
            throw ApplePayComponent.Error.invalidSummaryItem
        }
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

extension ApplePayConfiguration {
    
    /// Sets the handler called when the shopper authorizes the payment, before `onSubmit`.
    ///
    /// Use this closure to validate the shopper's payment information (e.g., billing/shipping address)
    /// before the payment is submitted. You can perform synchronous or asynchronous validation,
    /// including backend calls if needed.
    ///
    /// Return `.success` to proceed with submission, or `.failure` with errors to let the shopper retry.
    ///
    /// - Note: Return `.failure` with non-empty `errors` to keep the sheet open for correction.
    ///   Use `PKPaymentRequest.paymentBillingAddressInvalidError(withKey:localizedDescription:)` or similar
    ///   factory methods to create field-specific errors. If `errors` parameter is empty, the system will dismiss
    ///   the sheet.
    /// - Parameter onAuthorize: The closure to call when the payment is authorized.
    ///   - Parameters:
    ///     - payment: The `PKPayment` object containing the payment token, billing/shipping contact, and shipping method.
    ///   - Returns: A `PKPaymentAuthorizationResult` indicating success or failure with optional field-specific errors.
    /// - Returns: A modified copy of the configuration.
    public func onAuthorize(
        _ onAuthorize: @escaping @MainActor (PKPayment) async -> PKPaymentAuthorizationResult
    ) -> Self {
        var copy = self
        copy.onAuthorize = onAuthorize
        return copy
    }

    /// Sets the handler called when the shopper selects a shipping contact.
    ///
    /// Return an updated `PKPaymentRequestShippingContactUpdate` with revised summary items
    /// and optionally updated shipping methods or errors.
    /// - Parameter onSelectShippingContact: The closure to call when the shopper selects a shipping contact.
    ///   - Parameters:
    ///     - contact: The selected `PKContact` containing the shipping address and contact information.
    ///     - summaryItems: The current array of `PKPaymentSummaryItem` objects representing line items and total.
    ///   - Returns: A `PKPaymentRequestShippingContactUpdate` with updated summary items, shipping methods, and/or errors.
    /// - Returns: A modified copy of the configuration.
    public func onSelectShippingContact(
        _ onSelectShippingContact: @escaping @MainActor (
            PKContact,
            [PKPaymentSummaryItem]
        ) async -> PKPaymentRequestShippingContactUpdate
    ) -> Self {
        var copy = self
        copy.onSelectShippingContact = onSelectShippingContact
        return copy
    }

    /// Sets the handler called when the shopper selects a shipping method.
    ///
    /// Return an updated `PKPaymentRequestShippingMethodUpdate` with revised summary items.
    /// - Parameter onSelectShippingMethod: The closure to call when the shopper selects a shipping method.
    ///   - Parameters:
    ///     - shippingMethod: The selected `PKShippingMethod` containing the shipping option details.
    ///     - summaryItems: The current array of `PKPaymentSummaryItem` objects representing line items and total.
    ///   - Returns: A `PKPaymentRequestShippingMethodUpdate` with updated summary items reflecting the new shipping cost.
    /// - Returns: A modified copy of the configuration.
    public func onSelectShippingMethod(
        _ onSelectShippingMethod: @escaping @MainActor (
            PKShippingMethod,
            [PKPaymentSummaryItem]
        ) async -> PKPaymentRequestShippingMethodUpdate
    ) -> Self {
        var copy = self
        copy.onSelectShippingMethod = onSelectShippingMethod
        return copy
    }

    /// Sets the handler called when the shopper enters or updates a coupon code.
    ///
    /// Return an updated `PKPaymentRequestCouponCodeUpdate` with revised summary items.
    /// - Parameter onChangeCouponCode: The closure to call when the shopper enters or updates a coupon code.
    ///   - Parameters:
    ///     - couponCode: The entered or updated coupon code string.
    ///     - summaryItems: The current array of `PKPaymentSummaryItem` objects representing line items and total.
    ///   - Returns: A `PKPaymentRequestCouponCodeUpdate` with updated summary items reflecting the applied discount
    ///    or errors if the code is invalid.
    /// - Returns: A modified copy of the configuration.
    public func onChangeCouponCode(
        _ onChangeCouponCode: @escaping @MainActor (
            String,
            [PKPaymentSummaryItem]
        ) async -> PKPaymentRequestCouponCodeUpdate
    ) -> Self {
        var copy = self
        copy.onChangeCouponCode = onChangeCouponCode
        return copy
    }

    /// Sets the handler called when the shopper selects a payment method.
    ///
    /// Return an updated `PKPaymentRequestPaymentMethodUpdate` with revised summary items.
    /// - Parameter onPaymentMethodChange: The closure to call when the payment method changes.
    ///   - Parameters:
    ///     - paymentMethod: The selected `PKPaymentMethod` containing the payment card details.
    ///     - summaryItems: The current array of `PKPaymentSummaryItem` objects representing line items and total.
    ///   - Returns: A `PKPaymentRequestPaymentMethodUpdate` with updated summary items reflecting any changes based on the payment method.
    /// - Returns: A modified copy of the configuration.
    public func onPaymentMethodChange(
        _ onPaymentMethodChange: @escaping @MainActor (
            PKPaymentMethod,
            [PKPaymentSummaryItem]
        ) async -> PKPaymentRequestPaymentMethodUpdate
    ) -> Self {
        var copy = self
        copy.onPaymentMethodChange = onPaymentMethodChange
        return copy
    }
    
    /// Sets whether to allow adding new cards to Apple Pay if there is none.
    /// - Parameter allowOnboarding: Flag to allow shoppers to add new cards if there is none configured for Apple pay.
    /// - Returns: A modified copy of the configuration.
    public func allowOnboarding(_ allowOnboarding: Bool) -> Self {
        var copy = self
        copy.allowOnboarding = allowOnboarding
        return copy
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
