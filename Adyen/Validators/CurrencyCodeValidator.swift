//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Validates three-character ISO standard 4217 currency codes.
public struct CurrencyCodeValidator: Validator {

    private static let allCurrencyCodes = Set(Locale.isoCurrencyCodes)

    public init() {}

    public func isValid(_ value: String) -> Bool {
        CurrencyCodeValidator.allCurrencyCodes.contains(value)
    }

    public func maximumLength(for value: String) -> Int {
        3
    }
}
