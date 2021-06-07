//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes the amount of a payment.
public struct Amount: Codable, Equatable {

    /// The value of the amount in minor units.
    public let value: Int

    /// The code of the currency in which the amount's value is specified.
    public let currencyCode: String

    /// Initializes an Amount.
    ///
    /// - Parameters:
    ///   - value: The value in minor units.
    ///   - currencyCode: The code of the currency.
    public init(value: Int, currencyCode: String) {
        assert(CurrencyCodeValidator().isValid(currencyCode), "Currency code should be in ISO-4217 format. For example: USD.")
        self.value = value
        self.currencyCode = currencyCode
    }

    /// Initializes an Amount from a `Decimal` value expressed in major units.
    ///
    /// - Parameters:
    ///   - value: The value in major units.
    ///   - currencyCode: The code of the currency.
    public init(value: Decimal, currencyCode: String) {
        let minorUnit = AmountFormatter.minorUnitAmount(from: value, currencyCode: currencyCode)
        self.init(value: minorUnit, currencyCode: currencyCode)
    }

    /// :nodoc:
    internal init(value: Int, unsafeCurrencyCode: String) {
        self.value = value
        self.currencyCode = unsafeCurrencyCode
    }

    private enum CodingKeys: String, CodingKey {
        case currencyCode = "currency"
        case value
    }
}

/// :nodoc:
public extension Amount {

    /// Returns a formatter representation of the amount.
    ///
    /// :nodoc:
    var formatted: String {
        if let formattedAmount = AmountFormatter.formatted(amount: value, currencyCode: currencyCode) {
            return formattedAmount
        }

        return String(value) + " " + currencyCode
    }

}

/// :nodoc:
extension Amount: Comparable {

    /// :nodoc:
    public static func < (lhs: Amount, rhs: Amount) -> Bool {
        assert(lhs.currencyCode == rhs.currencyCode, "Currencies should match to compate")
        return lhs.value < rhs.value
    }

    /// :nodoc:
    public static func <= (lhs: Amount, rhs: Amount) -> Bool {
        assert(lhs.currencyCode == rhs.currencyCode, "Currencies should match to compate")
        return lhs.value <= rhs.value
    }

    /// :nodoc:
    public static func >= (lhs: Amount, rhs: Amount) -> Bool {
        assert(lhs.currencyCode == rhs.currencyCode, "Currencies should match to compate")
        return lhs.value >= rhs.value
    }

    /// :nodoc:
    public static func > (lhs: Amount, rhs: Amount) -> Bool {
        assert(lhs.currencyCode == rhs.currencyCode, "Currencies should match to compate")
        return lhs.value > rhs.value
    }

    internal static func - (lhs: Amount, rhs: Amount) -> Amount {
        assert(lhs.currencyCode == rhs.currencyCode, "Currencies should match to substract")
        return Amount(value: lhs.value - rhs.value, currencyCode: lhs.currencyCode)
    }

}
