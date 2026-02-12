//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

@_spi(AdyenInternal)
public enum AddressAnalyticsValidationError: AnalyticsValidationError {
    
    /// Postal code is not filled.
    case postalCodeEmpty
    
    /// Postal code is partially filled.
    case postalCodePartial
    
    public var analyticsErrorCode: Int {
        switch self {
        case .postalCodeEmpty:
            return AnalyticsConstants.ValidationErrorCodes.postalCodeEmpty
        case .postalCodePartial:
            return AnalyticsConstants.ValidationErrorCodes.postalCodePartial
        }
    }
    
    public var analyticsErrorMessage: String {
        switch self {
        case .postalCodeEmpty:
            return "Empty postal code field."
        case .postalCodePartial:
            return "Postal code has only been partially filled."
        }
    }
}
