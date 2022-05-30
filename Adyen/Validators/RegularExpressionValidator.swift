//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Validates a string using a regular expression.
public class RegularExpressionValidator: LengthValidator {
    
    private let regularExpression: String
    
    /// Initializes a new instance of `RegularExpressionValidator`
    ///
    /// - Parameters:
    ///   - regularExpression: The regex to validate against
    ///   - minimumLength: The minimum length allowed.
    ///   - maximumLength: The maximum length allowed.
    public init(regularExpression: String, minimumLength: Int? = nil, maximumLength: Int? = nil) {
        self.regularExpression = regularExpression
        super.init(minimumLength: minimumLength, maximumLength: maximumLength)
    }
    
    override public func isValid(_ value: String) -> Bool {
        guard super.isValid(value) else { return false }
        guard let range = value.range(of: regularExpression, options: .regularExpression) else { return false }
        return range == (value.startIndex..<value.endIndex)
    }
    
    override public func maximumLength(for value: String) -> Int {
        maximumLength ?? .max
    }
    
}
