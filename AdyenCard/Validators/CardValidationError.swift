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
    
    /// Holder name is not filled.
    case holderNameEmpty
    
    /// KCP password is not filled.
    case kcpPasswordEmpty
    
    /// KCP password is partially filled.
    case kcpPasswordPartial
    
    /// KCP birthdate or corporate number is not filled.
    case kcpFieldEmpty
    
    /// KCP birthdate or corporate number is partially filled.
    case kcpFieldPartial
    
    internal var analyticsErrorCode: Int {
        switch self {
        case .cardNumberEmpty:
            return AnalyticsConstants.ValidationErrorCodes.cardNumberEmpty
        case .cardNumberPartial:
            return AnalyticsConstants.ValidationErrorCodes.cardNumberPartial
        case .cardLuhnCheckFailed:
            return AnalyticsConstants.ValidationErrorCodes.cardLuhnCheckFailed
        case .cardUnsupported:
            return AnalyticsConstants.ValidationErrorCodes.cardUnsupported
        case .expiryDateEmpty:
            return AnalyticsConstants.ValidationErrorCodes.expiryDateEmpty
        case .expiryDatePartial:
            return AnalyticsConstants.ValidationErrorCodes.expiryDatePartial
        case .cardExpired:
            return AnalyticsConstants.ValidationErrorCodes.cardExpired
        case .expiryDateTooFar:
            return AnalyticsConstants.ValidationErrorCodes.expiryDateTooFar
        case .securityCodeEmpty:
            return AnalyticsConstants.ValidationErrorCodes.securityCodeEmpty
        case .securityCodePartial:
            return AnalyticsConstants.ValidationErrorCodes.securityCodePartial
        case .holderNameEmpty:
            return AnalyticsConstants.ValidationErrorCodes.holderNameEmpty
        case .kcpPasswordEmpty:
            return AnalyticsConstants.ValidationErrorCodes.kcpPasswordEmpty
        case .kcpPasswordPartial:
            return AnalyticsConstants.ValidationErrorCodes.kcpPasswordPartial
        case .kcpFieldEmpty:
            return AnalyticsConstants.ValidationErrorCodes.kcpFieldEmpty
        case .kcpFieldPartial:
            return AnalyticsConstants.ValidationErrorCodes.kcpFieldPartial
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
        case .holderNameEmpty:
            return "Empty holder name."
        case .kcpPasswordEmpty:
            return "Empty KCP password field."
        case .kcpPasswordPartial:
            return "KCP password has only been partially filled."
        case .kcpFieldEmpty:
            return "Empty KCP birthdate or corporate registration number."
        case .kcpFieldPartial:
            return "KCP birthdate or corporate registration number has only been partially filled."
        }
    }
}
