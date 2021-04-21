//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Validates a string using a regular expression.
/// :nodoc:
public class RegularExpressionValidator: LengthValidator {
    
    private let regularExpression: String

    /// :nodoc:
    public init(regularExpression: String, minimumLength: Int? = nil, maximumLength: Int? = nil) {
        self.regularExpression = regularExpression
        super.init(minimumLength: minimumLength, maximumLength: maximumLength)
    }
    
    /// :nodoc:
    override public func isValid(_ value: String) -> Bool {
        guard super.isValid(value) else { return false }
        guard let range = value.range(of: regularExpression, options: .regularExpression) else { return false }
        return range == (value.startIndex..<value.endIndex)
    }
    
    /// :nodoc:
    override public func maximumLength(for value: String) -> Int {
        maximumLength ?? .max
    }
    
}
