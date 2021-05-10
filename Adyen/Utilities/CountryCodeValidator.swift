//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal struct CountryCodeValidator: Validator {
    internal func isValid(_ value: String) -> Bool {
        let allCountryCodes = Locale.isoRegionCodes
        return allCountryCodes.contains(value)
    }
    
    internal func maximumLength(for value: String) -> Int {
        3
    }
}
