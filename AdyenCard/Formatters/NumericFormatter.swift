//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// :nodoc:
public class NumericFormatter: Adyen.Formatter {
    
    /// :nodoc:
    public func formattedValue(for value: String) -> String {
        return sanitizedValue(for: value)
    }
    
    /// :nodoc:
    public func sanitizedValue(for value: String) -> String {
        let allowedCharacters = CharacterSet.decimalDigits
        let filteredUnicodeScalars = value.unicodeScalars.filter(allowedCharacters.contains(_:))
        
        let sanitizedString = filteredUnicodeScalars.reduce("") { (string, unicodeScalar) -> String in
            string + String(unicodeScalar)
        }
        
        return sanitizedString
    }
}
