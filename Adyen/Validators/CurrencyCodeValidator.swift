//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// :nodoc:
public struct CurrencyCodeValidator: Validator {

    /// :nodoc:
    public init() { /* Empty initializer */ }

    /// :nodoc:
    public func isValid(_ value: String) -> Bool {
        let allCurrencyCodes = Locale.isoCurrencyCodes
        return allCurrencyCodes.contains(value)
    }

    /// :nodoc:
    public func maximumLength(for value: String) -> Int {
        3
    }
}
