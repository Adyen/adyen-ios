//
// Copyright (c) 2021 Adyen N.V.
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

    /// Initializes the length validator.
    ///
    /// - Parameters:
    ///   - exactLength: The required length.
    public init(exactLength: Int) {
        self.minimumLength = exactLength
        self.maximumLength = exactLength
    }
    
    /// :nodoc:
    open func isValid(_ value: String) -> Bool {
        let length = value.count
        
        if let minimumLength, length < minimumLength {
            return false
        }
        
        if let maximumLength, length > maximumLength {
            return false
        }
        
        return true
    }
    
    /// :nodoc:
    public func maximumLength(for value: String) -> Int {
        maximumLength ?? .max
    }
    
}
