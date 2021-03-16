//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// :nodoc:
public struct CountryCodeValidator: Validator {

    /// :nodoc:
    public init() { /* Empty initializer */ }

    /// :nodoc:
    public func isValid(_ value: String) -> Bool {
        let allCountryCodes = Locale.isoRegionCodes
        return allCountryCodes.contains(value)
    }

    /// :nodoc:
    public func maximumLength(for value: String) -> Int {
        3
    }
}
