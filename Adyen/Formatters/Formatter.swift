//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Formats a value for display purposes.
public protocol Formatter: Sanitizer {
    
    /// Formats the given value.
    ///
    /// - Parameter value: The value to format.
    /// - Returns: A formatted version of the given value.
    func formattedValue(for value: String) -> String
    
}

/// Sanitizes the value, e.g remove illegal characters.
public protocol Sanitizer {
    /// Sanitizes (removes any illegal character) the given value.
    ///
    /// - Parameter value: The value to be sanitized.
    /// - Returns: The given value without any illegal characters.
    func sanitizedValue(for value: String) -> String
}
