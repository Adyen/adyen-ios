//
// Copyright (c) 2022 Adyen N.V.
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
    
    /// The identifier of the locale.
    public var localeIdentifier: String?

    /// Initializes an Amount.
    ///
    /// - Parameters:
    ///   - value: The value in minor units.
    ///   - currencyCode: The code of the currency.
    ///   - localeIdentifier: The identifier of the locale.
    public init(value: Int, currencyCode: String, localeIdentifier: String? = nil) {
        assert(CurrencyCodeValidator().isValid(currencyCode), "Currency code should be in ISO-4217 format. For example: USD.")
        self.value = value
        self.currencyCode = currencyCode
        self.localeIdentifier = localeIdentifier
    }

    /// Initializes an Amount from a `Decimal` value expressed in major units.
    ///
    /// - Parameters:
    ///   - value: The value in major units.
    ///   - currencyCode: The code of the currency.
    ///   - localeIdentifier: The identifier of the locale.
    public init(value: Decimal, currencyCode: String, localeIdentifier: String? = nil) {
        let minorUnit = AmountFormatter.minorUnitAmount(from: value, currencyCode: currencyCode, localeIdentifier: localeIdentifier)
        
        self.init(value: minorUnit, currencyCode: currencyCode, localeIdentifier: localeIdentifier)
    }

    internal init(value: Int, unsafeCurrencyCode: String) {
        self.value = value
        self.currencyCode = unsafeCurrencyCode
    }

    private enum CodingKeys: String, CodingKey {
        case currencyCode = "currency"
        case value
    }
}

public extension Amount {

    /// Returns a formatted representation of the amount.
    ///
    var formatted: String {
        if let formattedAmount = AmountFormatter.formatted(
            amount: value,
            currencyCode: currencyCode,
            localeIdentifier: localeIdentifier
        ) {
            return formattedAmount
        }

        return String(value) + " " + currencyCode
    }
    
    /// Returns a formatted representation of the amount, split in two components
    ///
    @_spi(AdyenInternal)
    var formattedComponents: AmountComponents {
        AmountComponents(amount: self)
    }

}

@_spi(AdyenInternal)
extension Amount: Comparable {

    public static func < (lhs: Amount, rhs: Amount) -> Bool {
        assert(lhs.currencyCode == rhs.currencyCode, "Currencies should match to compare")
        return lhs.value < rhs.value
    }

    public static func <= (lhs: Amount, rhs: Amount) -> Bool {
        assert(lhs.currencyCode == rhs.currencyCode, "Currencies should match to compare")
        return lhs.value <= rhs.value
    }

    public static func >= (lhs: Amount, rhs: Amount) -> Bool {
        assert(lhs.currencyCode == rhs.currencyCode, "Currencies should match to compare")
        return lhs.value >= rhs.value
    }

    public static func > (lhs: Amount, rhs: Amount) -> Bool {
        assert(lhs.currencyCode == rhs.currencyCode, "Currencies should match to compare")
        return lhs.value > rhs.value
    }

    internal static func - (lhs: Amount, rhs: Amount) -> Amount {
        assert(lhs.currencyCode == rhs.currencyCode, "Currencies should match to subtract")
        return Amount(value: lhs.value - rhs.value, currencyCode: lhs.currencyCode, localeIdentifier: lhs.localeIdentifier)
    }

}

@_spi(AdyenInternal)
public struct AmountComponents {
    
    fileprivate init(amount: Amount) {
        if let comps = Self.extractAmountComponents(from: amount.formatted) {
            (self.formattedCurrencySymbol, self.formattedValue) = comps
        } else {
            self.formattedValue = String(amount.value)
            self.formattedCurrencySymbol = amount.currencyCode
        }
    }
    
    public let formattedValue: String
    
    public let formattedCurrencySymbol: String
    
    private static func extractAmountComponents(
        from formattedString: String
    ) -> (currency: String, value: String)? {
        guard let range = formattedString.range(
            of: "(\\d+(?:[.,\\s]\\d+)+)",
            options: .regularExpression
        ) else { return nil }
        
        let amountString = formattedString[range.lowerBound..<range.upperBound]
        let currencyString: Substring
        
        if range.lowerBound == formattedString.startIndex {
            currencyString = formattedString[range.upperBound...]
        } else {
            currencyString = formattedString[formattedString.startIndex..<range.lowerBound]
        }
        
        return (
            String(currencyString).trimmingCharacters(in: .whitespacesAndNewlines),
            String(amountString).trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }
}
