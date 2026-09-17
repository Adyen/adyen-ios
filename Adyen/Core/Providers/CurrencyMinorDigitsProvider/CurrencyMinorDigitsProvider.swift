//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Provides the number of minor digits (decimal places) for a given ISO 4217 currency code.
package protocol AnyCurrencyMinorDigitsProvider {

    /// Returns the number of minor digits for the given currency code.
    ///
    /// - Parameter currencyCode: The ISO 4217 currency code, e.g. `"EUR"`.
    /// - Returns: The number of minor digits for the currency. Falls back to ``CurrencyMinorDigitsProvider/defaultMinorDigits``
    ///   when the currency code is not recognized.
    func minorDigits(for currencyCode: String) -> Int
}

/// Provides the number of minor digits (decimal places) for ISO 4217 currency codes,
/// based on the list maintained by Adyen.
///
/// Source: https://docs.adyen.com/development-resources/currency-codes
package struct CurrencyMinorDigitsProvider: AnyCurrencyMinorDigitsProvider {

    /// The number of minor digits returned when a currency code is not found in the list.
    package static let defaultMinorDigits = 2

    package init() {}

    package func minorDigits(for currencyCode: String) -> Int {
        Self.minorDigitsByCurrencyCode[currencyCode.uppercased()] ?? Self.defaultMinorDigits
    }
}
