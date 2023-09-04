//
// Copyright (c) 2021 Adyen N.V.
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

/// :nodoc:
public func || (lhs: Validator, rhs: Validator) -> Validator {
    ORValidator(lhs: lhs, rhs: rhs)
}

/// :nodoc:
public func && (lhs: Validator, rhs: Validator) -> Validator {
    ANDValidator(lhs: lhs, rhs: rhs)
}

/// Interface to allow for two validators.
protocol CombinedValidator: Validator {
    var lhs: Validator { get }
    var rhs: Validator { get }
}

extension CombinedValidator {
    
    func maximumLength(for value: String) -> Int {
        max(lhs.maximumLength(for: value), rhs.maximumLength(for: value))
    }
}

/// A validator that is the logical `OR` combination of two `Validator` instances.
final class ORValidator: CombinedValidator {
    let lhs: Validator
    let rhs: Validator
    
    init(lhs: Validator, rhs: Validator) {
        self.lhs = lhs
        self.rhs = rhs
    }
    
    func isValid(_ value: String) -> Bool {
        lhs.isValid(value) || rhs.isValid(value)
    }
}

/// A validator that is the logical `AND` combination of two `Validator` instances.
final class ANDValidator: CombinedValidator {
    let lhs: Validator
    let rhs: Validator
    
    init(lhs: Validator, rhs: Validator) {
        self.lhs = lhs
        self.rhs = rhs
    }
    
    func isValid(_ value: String) -> Bool {
        lhs.isValid(value) && rhs.isValid(value)
    }
}
