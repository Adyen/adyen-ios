//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenUI
import Foundation
import PassKit

/// Configuration for the Apple Pay payment component.
public struct ApplePayConfiguration: CheckoutComponentConfiguration {

    package let componentType: CheckoutComponentType = .payment(.applePay)

    /// Whether the component shows the Apple Pay button.
    package var showsSubmitButton: Bool = true

    package var theme: CheckoutTheme = .default

    package var localizationParameters: LocalizationParameters?

    package var localizationProvider: (any CheckoutLocalizationProvider)?

    /// The flag to toggle onboarding.
    /// If true, allow the shopper to add cards to Apple Pay if none exists yet.
    /// If false, then Apple Pay is disabled if the shopper doesn't have supported cards on Apple Pay wallet.
    internal var allowOnboarding: Bool = true

    internal var buttonAppearance = ApplePayButtonAppearance()

    /// The payment request object needed for Apple Pay. Must contain all the required fields
    /// such as `merchantIdentifier`, `summaryItems`, `currencyCode`, and `countryCode`.
    internal var paymentRequest: PKPaymentRequest

    /// Initializes the Apple Pay configuration with a Payment Request.
    /// - Parameters:
    ///   - paymentRequest: The payment request object needed for Apple Pay. Must contain all the required fields
    ///   such as `merchantIdentifier`, `summaryItems`, `currencyCode`, and `countryCode`.
    /// - Warning: The instance of `paymentRequest` may be mutated.
    /// - Throws: ``CheckoutError`` with the ``CheckoutError/Code/invalidConfiguration`` code if the payment request is invalid:
    ///   `merchantIdentifier` is empty, the country or currency code is invalid, `paymentSummaryItems` is empty,
    ///   the grand total is negative, or a summary item has an invalid amount.
    public init(
        paymentRequest: PKPaymentRequest
    ) throws {
        do {
            try Self.validate(paymentRequest: paymentRequest)
        } catch {
            throw CheckoutError(code: .invalidConfiguration, message: error.localizedDescription, underlyingError: error)
        }

        self.paymentRequest = paymentRequest
    }

    private static func validate(paymentRequest: PKPaymentRequest) throws {
        guard !paymentRequest.merchantIdentifier.isEmpty else {
            throw ApplePayComponent.Error.emptyMerchantIdentifier
        }
        guard CountryCodeValidator().isValid(paymentRequest.countryCode) else {
            throw ApplePayComponent.Error.invalidCountryCode
        }
        guard CurrencyCodeValidator().isValid(paymentRequest.currencyCode) else {
            throw ApplePayComponent.Error.invalidCurrencyCode
        }
        try validate(summaryItems: paymentRequest.paymentSummaryItems)
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
            currencyCode: amount.currencyCode
        )
        newItems.append(PKPaymentSummaryItem(label: lastItem.label, amount: decimalAmount))
        newConfig.paymentRequest.paymentSummaryItems = newItems
        return newConfig
    }
}

extension ApplePayConfiguration {

    /// Sets whether to allow adding new cards to Apple Pay if there is none.
    /// - Parameter allowOnboarding: Flag to allow shoppers to add new cards if there is none configured for Apple pay.
    /// - Returns: A modified copy of the configuration.
    public func allowOnboarding(_ allowOnboarding: Bool) -> Self {
        var copy = self
        copy.allowOnboarding = allowOnboarding
        return copy
    }

    /// Sets the appearance of the Apple Pay button.
    /// - Parameter buttonAppearance: The Apple Pay button appearance.
    /// - Returns: A modified copy of the configuration.
    public func buttonAppearance(_ buttonAppearance: ApplePayButtonAppearance) -> Self {
        var copy = self
        copy.buttonAppearance = buttonAppearance
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
