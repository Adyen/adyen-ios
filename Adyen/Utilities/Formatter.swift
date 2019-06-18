//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Formats a value for display purposes.
public protocol Formatter {
    
    /// Formats the given value.
    ///
    /// - Parameter value: The value to format.
    /// - Returns: A formatted version of the given value.
    func formattedValue(for value: String) -> String
    
    /// Sanitizes (unformats) the given value.
    ///
    /// - Parameter value: The formatted value to remove the formatting from.
    /// - Returns: The given value but without any formatting.
    func sanitizedValue(for value: String) -> String
    
}
