//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes the amount of a payment.
public struct Amount: Codable, Equatable {

    /// The value of the amount in minor units.
    public var value: Int

    /// The code of the currency in which the amount's value is specified.
    public var currencyCode: String

    /// Initializes an Amount.
    ///
    /// - Parameters:
    ///   - value: The value in minor units.
    ///   - currencyCode: The code of the currency.
    public init(value: Int, currencyCode: String) {
        self.value = value
        self.currencyCode = currencyCode
    }

    /// Initializes an Amount from a `Decimal` value expressed in major units.
    ///
    /// - Parameters:
    ///   - value: The value in major units.
    ///   - currencyCode: The code of the currency.
    public init(value: Decimal, currencyCode: String) {
        self.value = AmountFormatter.minorUnitAmount(from: value, currencyCode: currencyCode)
        self.currencyCode = currencyCode
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
        guard let formattedAmount = AmountFormatter.formatted(amount: value, currencyCode: currencyCode) else {
            return String(value) + " " + currencyCode
        }

        return formattedAmount
    }

}

/// :nodoc:
extension Amount: Comparable {

    /// :nodoc:
    public static func < (lhs: Amount, rhs: Amount) -> Bool {
        lhs.value < rhs.value
    }

    /// :nodoc:
    public static func <= (lhs: Amount, rhs: Amount) -> Bool {
        lhs.value <= rhs.value
    }

    /// :nodoc:
    public static func >= (lhs: Amount, rhs: Amount) -> Bool {
        lhs.value >= rhs.value
    }

    /// :nodoc:
    public static func > (lhs: Amount, rhs: Amount) -> Bool {
        lhs.value > rhs.value
    }

}
