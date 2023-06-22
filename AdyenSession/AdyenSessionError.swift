//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

public enum AdyenSessionError: LocalizedError {
    case noCountryCode

    public var errorDescription: String? {
        "CountryCode value was not passed via /sessions. " +
            "Make sure to provide 'countryCode' value to AdyenSession.Configuration."
    }
}
