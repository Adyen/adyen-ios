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

    /// The amount for this payment in minor units.
    public private(set) var amountMinorUnits: Int

    /// The public key used for encrypting card details.
    public private(set) var summaryItems: [PKPaymentSummaryItem]

    /// The code of the country in which the payment is made.
    public private(set) var countryCode: String

    /// The code of the currency in which the amount's value is specified.
    public private(set) var currencyCode: String

    internal var brand: String

    internal let localeIdentifier: String?

    /// Create a new instance of ApplePayPayment.
    /// - Parameters:
    ///   - countryCode: The code of the country in which the payment is made.
    ///   - currencyCode: The code of the currency in which the amount's value is specified.
    ///   - summaryItems: The summary items in a payment request—for example, total, tax, discount, or grand total.
    ///   - localizationParameters: The localization parameters to control how monetary amount are localized.
    /// - Throws: `ApplePayComponent.Error.emptySummaryItems` if the summaryItems array is empty.
    /// - Throws: `ApplePayComponent.Error.negativeGrandTotal` if the grand total is negative.
    /// - Throws: `ApplePayComponent.Error.invalidSummaryItem` if at least one of the summary items has an invalid amount.
    /// - Throws: `ApplePayComponent.Error.invalidCountryCode` if the `payment.countryCode` is not a valid ISO country code.
    /// - Throws: `ApplePayComponent.Error.invalidCurrencyCode` if the `Amount.currencyCode` is not a valid ISO currency code.
    public init(countryCode: String,
                currencyCode: String,
                summaryItems: [PKPaymentSummaryItem],
                localizationParameters: LocalizationParameters? = nil) throws {
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
                                                        currencyCode: currencyCode,
                                                        localeIdentifier: localizationParameters?.locale)
        self.init(amount: amountInt,
                  currencyCode: currencyCode,
                  countryCode: countryCode,
                  summaryItems: summaryItems,
                  brand: lastItem.label,
                  localeIdentifier: localizationParameters?.locale)
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

        self.init(amount: payment.amount.value,
                  currencyCode: payment.amount.currencyCode,
                  countryCode: payment.countryCode,
                  summaryItems: [PKPaymentSummaryItem(label: brand, amount: decimalValue)],
                  brand: brand,
                  localeIdentifier: localizationParameters?.locale)
    }

    /// Updates Apple Pay payment with new amount
    /// - Parameters:
    ///   - amount: The new amount value
    ///   - localeIdentifier: The localization parameters to control how monetary amount are localized.
    internal mutating func update(amount: Amount) {
        var newItems = summaryItems
        guard let lastItem = newItems.last else { return }

        newItems = newItems.dropLast()
        let decimalAmount = AmountFormatter.decimalAmount(amount.value,
                                                          currencyCode: amount.currencyCode,
                                                          localeIdentifier: amount.localeIdentifier)
        newItems.append(PKPaymentSummaryItem(label: lastItem.label, amount: decimalAmount))
        summaryItems = newItems
        amountMinorUnits = amount.value
    }

    private init(amount: Int,
                 currencyCode: String,
                 countryCode: String,
                 summaryItems: [PKPaymentSummaryItem],
                 brand: String,
                 localeIdentifier: String?) {
        self.summaryItems = summaryItems
        amountMinorUnits = amount
        self.brand = brand
        self.countryCode = countryCode
        self.currencyCode = currencyCode
        self.localeIdentifier = localeIdentifier
    }

}

extension ApplePayPayment {

    @_spi(AdyenInternal)
    public var amount: Amount {
        Amount(value: amountMinorUnits, currencyCode: currencyCode)
    }

    internal func replacing(summaryItems: [PKPaymentSummaryItem]) throws -> ApplePayPayment {
        try ApplePayPayment(countryCode: self.countryCode,
                            currencyCode: currencyCode,
                            summaryItems: summaryItems,
                            localizationParameters: .init(locale: self.localeIdentifier))
    }

}
