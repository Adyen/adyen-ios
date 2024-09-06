//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Validates a value.
public protocol Validator {
    
    /// Returns a boolean value indicating if the given value is valid.
    ///
    /// - Parameter value: The value to validate.
    /// - Returns: A boolean value indicating if the given value is valid.
    func isValid(_ value: String) -> Bool
    
    /// Returns the maximum length for the given value.
    ///
    /// - Parameter value: The value for which to determine the maximum length.
    /// - Returns: The maximum length for the given value.
    func maximumLength(for value: String) -> Int
}

@_spi(AdyenInternal)
public protocol StatusValidator: Validator {
    
    /// Validates the value and returns the result.
    /// - Parameter value: The value to validate.
    /// - Returns: A `ValidationStatus` indicating the result.
    func validate(_ value: String) -> ValidationStatus
}

/// Defines the `||` operator for two `Validator` operands.
@_spi(AdyenInternal)
public func || (lhs: Validator, rhs: Validator) -> Validator {
    ORValidator(firstValidator: lhs, secondValidator: rhs)
}

/// Defines the `&&` operator for two `Validator` operands.
@_spi(AdyenInternal)
public func && (lhs: Validator, rhs: Validator) -> Validator {
    ANDValidator(firstValidator: lhs, secondValidator: rhs)
}

/// Interface to allow for two validators.
public protocol CombinedValidator: Validator {
    var firstValidator: Validator { get }
    var secondValidator: Validator { get }
}

extension CombinedValidator {
    
    public func maximumLength(for value: String) -> Int {
        max(firstValidator.maximumLength(for: value), secondValidator.maximumLength(for: value))
    }
}

/// A validator that is the logical `OR` combination of two `Validator` instances.
@_spi(AdyenInternal)
public final class ORValidator: CombinedValidator {
    public let firstValidator: Validator
    public let secondValidator: Validator
    
    public init(firstValidator: Validator, secondValidator: Validator) {
        self.firstValidator = firstValidator
        self.secondValidator = secondValidator
    }
    
    public func isValid(_ value: String) -> Bool {
        firstValidator.isValid(value) || secondValidator.isValid(value)
    }
}

/// A validator that is the logical `AND` combination of two `Validator` instances.
@_spi(AdyenInternal)
public final class ANDValidator: CombinedValidator {
    public let firstValidator: Validator
    public let secondValidator: Validator
    
    public init(firstValidator: Validator, secondValidator: Validator) {
        self.firstValidator = firstValidator
        self.secondValidator = secondValidator
    }
    
    public func isValid(_ value: String) -> Bool {
        firstValidator.isValid(value) && secondValidator.isValid(value)
    }
}
