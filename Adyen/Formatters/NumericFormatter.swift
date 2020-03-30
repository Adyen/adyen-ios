//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// :nodoc:
open class NumericFormatter: Adyen.Formatter {
    
    /// :nodoc:
    public init() {}
    
    /// :nodoc:
    open func formattedValue(for value: String) -> String {
        return sanitizedValue(for: value)
    }
    
    /// :nodoc:
    open func sanitizedValue(for value: String) -> String {
        let sanitizedString = value.filter { $0.isNumber }
        
        // Converts all non-latin digits to latin digits
        let latinString = sanitizedString.applyingTransform(StringTransform.toLatin, reverse: false) ?? sanitizedString
        
        // Filters out non-ASCII digits
        return latinString.filter { $0.isASCII && $0.isNumber }
    }
}
