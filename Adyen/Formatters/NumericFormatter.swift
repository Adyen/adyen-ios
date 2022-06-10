//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Represents any numeric field formatter. intended to be subclassed.
open class NumericFormatter: Formatter {
    
    public init() { /* empty init */ }
    
    open func formattedValue(for value: String) -> String {
        sanitizedValue(for: value)
    }
    
    open func sanitizedValue(for value: String) -> String {
        let sanitizedString = value.filter(\.isNumber)
        
        // Converts all non-latin digits to latin digits
        let latinString = sanitizedString.applyingTransform(StringTransform.toLatin, reverse: false) ?? sanitizedString
        
        // Filters out non-ASCII digits
        return latinString.filter { $0.isASCII && $0.isNumber }
    }
}
