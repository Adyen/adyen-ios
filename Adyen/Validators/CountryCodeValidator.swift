//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Validates two-character ISO standard 3166 2-character country codes.
public struct CountryCodeValidator: Validator {

    private static let allCountryCodes = Set(Locale.isoRegionCodes)

    public init() {}

    public func isValid(_ value: String) -> Bool {
        CountryCodeValidator.allCountryCodes.contains(value)
    }

    public func maximumLength(for value: String) -> Int {
        2
    }
}
