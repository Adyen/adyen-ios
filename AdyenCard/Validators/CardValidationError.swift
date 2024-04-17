//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation

internal enum CardValidationError: String, AnalyticsValidationError {
    
    /// Card number is not filled.
    case cardNumberEmpty
    
    /// Card number is partially filled.
    case cardNumberPartial
    
    /// Luhn check for the card bin failed.
    case cardLuhnCheckFailed
    
    /// Card brand is not supported.
    case cardUnsupported
    
    /// Expiry date is not filled.
    case expiryDateEmpty
    
    /// Expiry date is partially filled.
    case expiryDatePartial
    
    /// Card expired.
    case cardExpired
    
    /// Expiry date too far into the future.
    case expiryDateTooFar
    
    /// Security code is not filled.
    case securityCodeEmpty
    
    /// Security code is partially filled.
    case securityCodePartial
    
    internal var analyticsErrorCode: Int {
        switch self {
        case .cardNumberEmpty:
            return 900
        case .cardNumberPartial:
            return 901
        case .cardLuhnCheckFailed:
            return 902
        case .cardUnsupported:
            return 903
        case .expiryDateEmpty:
            return 910
        case .expiryDatePartial:
            return 911
        case .cardExpired:
            return 912
        case .expiryDateTooFar:
            return 913
        case .securityCodeEmpty:
            return 920
        case .securityCodePartial:
            return 921
        }
    }
    
    internal var analyticsErrorMessage: String {
        switch self {
        case .cardNumberEmpty:
            return "Empty card number field."
        case .cardNumberPartial:
            return "Card number has only been partially filled."
        case .cardLuhnCheckFailed:
            return "Luhn check failed."
        case .cardUnsupported:
            return "Unsupported card in binlookup."
        case .expiryDateEmpty:
            return "Empty expiry date field."
        case .expiryDatePartial:
            return "Date has only been partially filled."
        case .cardExpired:
            return "Card expired (expiry date too far in the past)."
        case .expiryDateTooFar:
            return "Expiry date too far in the future."
        case .securityCodeEmpty:
            return "Empty security code field."
        case .securityCodePartial:
            return "Security code field has only been partially filled."
        }
    }
}
