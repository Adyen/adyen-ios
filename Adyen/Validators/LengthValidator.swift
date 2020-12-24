//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A generic validator that validates the length of a string.
open class LengthValidator: Validator {
    
    /// The minimum length of the string.
    open var minimumLength: Int?
    
    /// The maximum length of the string.
    open var maximumLength: Int?
    
    /// Initializes the length validator.
    ///
    /// - Parameters:
    ///   - minimumLength: The minimum length of the string.
    ///   - maximumLength: The maximum length of the string.
    public init(minimumLength: Int? = nil, maximumLength: Int? = nil) {
        self.minimumLength = minimumLength
        self.maximumLength = maximumLength
    }
    
    /// :nodoc:
    open func isValid(_ value: String) -> Bool {
        let length = value.count
        
        if let minimumLength = minimumLength, length < minimumLength {
            return false
        }
        
        if let maximumLength = maximumLength, length > maximumLength {
            return false
        }
        
        return true
    }
    
    /// :nodoc:
    public func maximumLength(for value: String) -> Int {
        return maximumLength ?? .max
    }
    
}
