//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// :nodoc:
/// Validates three-character ISO standard 4217 currency codes.
public struct CurrencyCodeValidator: Validator {

    private static let allCurrencyCodes = Set(Locale.isoCurrencyCodes)

    /// :nodoc:
    public init() {}

    /// :nodoc:
    public func isValid(_ value: String) -> Bool {
        CurrencyCodeValidator.allCurrencyCodes.contains(value)
    }

    /// :nodoc:
    public func maximumLength(for value: String) -> Int {
        3
    }
}
