//
// Copyright (c) 2019 Adyen B.V.
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
