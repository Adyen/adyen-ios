//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal struct CurrencyCodeValidator: Validator {
    internal func isValid(_ value: String) -> Bool {
        let allCurrencyCodes = Locale.isoCurrencyCodes
        return allCurrencyCodes.contains(value)
    }
    
    internal func maximumLength(for value: String) -> Int {
        3
    }
}
