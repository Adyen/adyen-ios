//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// :nodoc:
open class PhoneNumberFormatter: Adyen.Formatter {
    
    /// :nodoc:
    public init() { /* empty init */ }
    
    /// :nodoc:
    open func formattedValue(for value: String) -> String {
        sanitizedValue(for: value)
    }
    
    /// :nodoc:
    open func sanitizedValue(for value: String) -> String {
        let sanitizedString = value.filter { isValid(character: $0) }
        
        // Converts all non-latin digits to latin digits
        let latinString = sanitizedString.applyingTransform(StringTransform.toLatin, reverse: false) ?? sanitizedString
        
        // Filters out non-ASCII digits
        return latinString.filter { $0.isASCII && isValid(character: $0) }
    }
    
    private func isValid(character: Character) -> Bool {
        character.isNumber || character == "+"
    }
}
