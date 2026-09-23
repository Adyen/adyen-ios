//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Provides the number of minor digits (decimal places) for a given ISO 4217 currency code.
@_spi(AdyenInternal)
public protocol AnyCurrencyMinorDigitsProvider {

    /// Returns the number of minor digits for the given currency code.
    ///
    /// - Parameter currencyCode: The ISO 4217 currency code, e.g. `"EUR"`.
    /// - Returns: The number of minor digits for the currency. Falls back to the system's ICU currency data.
    func minorDigits(for currencyCode: String) -> Int
}

/// Provides the number of minor digits (decimal places) for ISO 4217 currency codes,
/// based on the list maintained by Adyen.
///
/// Source: https://docs.adyen.com/development-resources/currency-codes
@_spi(AdyenInternal)
public struct CurrencyMinorDigitsProvider: AnyCurrencyMinorDigitsProvider {

    public init() {}

    public func minorDigits(for currencyCode: String) -> Int {
        let normalizedCurrencyCode = currencyCode.uppercased()
        return Self.minorDigitsByCurrencyCode[normalizedCurrencyCode] ?? Self.systemMinorDigits(for: normalizedCurrencyCode)
    }

    /// Falls back to the system's ICU/CLDR currency data for ISO 4217 codes that are valid
    /// but not on Adyen's official currency list (e.g. `CLF`, `UYW`).
    private static func systemMinorDigits(for currencyCode: String) -> Int {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter.maximumFractionDigits
    }
}
