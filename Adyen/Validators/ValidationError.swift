//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

@_spi(AdyenInternal)
public enum ValidationStatus {
    case valid
    case invalid(ValidationError)
    
    public var isValid: Bool {
        switch self {
        case .valid:
            return true
        case .invalid:
            return false
        }
    }
    
    /// Convenience access to the validation error if invalid.
    public var validationError: ValidationError? {
        switch self {
        case .valid:
            return nil
        case let .invalid(validationError):
            return validationError
        }
    }
}

/// Protocol that defines the interface for validation errors.
@_spi(AdyenInternal)
public protocol ValidationError: LocalizedError {}
