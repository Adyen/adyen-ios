//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

@_spi(AdyenInternal)
public enum ValidationStatus {
    case valid
    case invalid(ValidationError?)
    
    public var isValid: Bool {
        switch self {
        case .valid:
            return true
        case .invalid:
            return false
        }
    }
}

/// Protocol that defines the interface for validation errors.
@_spi(AdyenInternal)
public protocol ValidationError: LocalizedError {}

/// Protocol created spefically for analytics related validation error.
@_spi(AdyenInternal)
public protocol AnalyticsValidationError: ValidationError {
    
    /// Code of the error for analytics.
    var analyticsErrorCode: Int { get }
    
    /// Message describing the error for analytics.
    var analyticsErrorMessage: String { get }
}

@_spi(AdyenInternal)
public struct GenericValidationError: ValidationError {}
