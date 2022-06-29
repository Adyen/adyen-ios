//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation
import PassKit

// MARK: - Apple Pay component configuration.

/// Describes the Apple Pay payment.
public struct ApplePayPayment {

    /// The amount for this payment.
    public private(set) var payment: Payment

    /// The public key used for encrypting card details.
    public private(set) var summaryItems: [PKPaymentSummaryItem]

    /// The code of the country in which the payment is made.
    public var countryCode: String { payment.countryCode }

    /// The code of the currency in which the amount's value is specified.
    public var currencyCode: String { payment.amount.currencyCode }

    internal var brand: String

    /// Create a new instance of ApplePayPayment.
    /// - Parameters:
    ///   - countryCode: The code of the country in which the payment is made.
    ///   - currencyCode: The code of the currency in which the amount's value is specified.
    ///   - summaryItems: The summary items in a payment request—for example, total, tax, discount, or grand total.
    /// - Throws: `ApplePayComponent.Error.emptySummaryItems` if the summaryItems array is empty.
    /// - Throws: `ApplePayComponent.Error.negativeGrandTotal` if the grand total is negative.
    /// - Throws: `ApplePayComponent.Error.invalidSummaryItem` if at least one of the summary items has an invalid amount.
    /// - Throws: `ApplePayComponent.Error.invalidCountryCode` if the `payment.countryCode` is not a valid ISO country code.
    /// - Throws: `ApplePayComponent.Error.invalidCurrencyCode` if the `Amount.currencyCode` is not a valid ISO currency code.
    public init(countryCode: String,
                currencyCode: String,
                summaryItems: [PKPaymentSummaryItem]) throws {
        guard CountryCodeValidator().isValid(countryCode) else {
            throw ApplePayComponent.Error.invalidCountryCode
        }
        guard CurrencyCodeValidator().isValid(currencyCode) else {
            throw ApplePayComponent.Error.invalidCurrencyCode
        }
        guard summaryItems.count > 0 else {
            throw ApplePayComponent.Error.emptySummaryItems
        }
        guard let lastItem = summaryItems.last, lastItem.amount.doubleValue >= 0 else {
            throw ApplePayComponent.Error.negativeGrandTotal
        }
        guard summaryItems.map(\.amount).contains(NSDecimalNumber.notANumber) == false else {
            throw ApplePayComponent.Error.invalidSummaryItem
        }

        let amountInt = AmountFormatter.minorUnitAmount(from: lastItem.amount.decimalValue,
                                                        currencyCode: currencyCode)
        let amount = Amount(value: amountInt, currencyCode: currencyCode)
        let payment = Payment(amount: amount, countryCode: countryCode)
        self.init(payment: payment, summaryItems: summaryItems, brand: lastItem.label)
    }

    /// Create a new instance of ApplePayPayment.
    /// - Parameters:
    ///   - payment: The combination of amount and country code.
    ///   - localizationParameters: The localization parameters to control how monetary amount are localized.
    ///   - brand: The business name shopper will see when they look for the charge on their bank or credit card statement.
    /// - Throws: `ApplePayComponent.Error.negativeGrandTotal` if the grand total is negative.
    /// - Throws: `ApplePayComponent.Error.invalidSummaryItem` if at least one of the summary items has an invalid amount.
    /// - Throws: `ApplePayComponent.Error.invalidCountryCode` if the `payment.countryCode` is not a valid ISO country code.
    /// - Throws: `ApplePayComponent.Error.invalidCurrencyCode` if the `Amount.currencyCode` is not a valid ISO currency code.
    public init(payment: Payment, brand: String, localizationParameters: LocalizationParameters? = nil) throws {
        guard CountryCodeValidator().isValid(payment.countryCode) else {
            throw ApplePayComponent.Error.invalidCountryCode
        }
        guard CurrencyCodeValidator().isValid(payment.amount.currencyCode) else {
            throw ApplePayComponent.Error.invalidCurrencyCode
        }

        let decimalValue = AmountFormatter.decimalAmount(payment.amount.value,
                                                         currencyCode: payment.amount.currencyCode,
                                                         localeIdentifier: localizationParameters?.locale)
        guard decimalValue.doubleValue >= 0,
              decimalValue.isEqual(to: NSDecimalNumber.notANumber) == false
        else {
            throw ApplePayComponent.Error.negativeGrandTotal
        }

        self.init(payment: payment,
                  summaryItems: [PKPaymentSummaryItem(label: brand, amount: decimalValue)],
                  brand: brand)
    }

    /// Updates Apple Pay payment with new amount
    /// - Parameters:
    ///   - amount: The new amount value
    ///   - localeIdentifier: The localization parameters to control how monetary amount are localized.
    internal mutating func update(amount: Amount, localeIdentifier: String?) {
        var newItems = summaryItems
        guard let lastItem = newItems.last else { return }

        newItems = newItems.dropLast()
        let decimalAmount = AmountFormatter.decimalAmount(amount.value,
                                                          currencyCode: amount.currencyCode,
                                                          localeIdentifier: localeIdentifier)
        newItems.append(PKPaymentSummaryItem(label: lastItem.label, amount: decimalAmount))
        summaryItems = newItems
        payment = Payment(amount: amount, countryCode: payment.countryCode)
    }

    private init(payment: Payment, summaryItems: [PKPaymentSummaryItem], brand: String) {
        self.summaryItems = summaryItems
        self.payment = payment
        self.brand = brand
    }

}

extension ApplePayPayment {

    internal func update(with summaryItems: [PKPaymentSummaryItem]) throws -> ApplePayPayment {
        try .init(countryCode: countryCode,
                  currencyCode: currencyCode,
                  summaryItems: summaryItems)
    }

}
