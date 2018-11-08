//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

public class CardSecurityCodeValidator: NumericValidator {
    
    public init() {}
    
    public func isMaxLength(_ string: String) -> Bool {
        return string.count >= maxLength
    }
    
    public func isValid(_ string: String) -> Bool {
        let sanitized = sanitize(string)
        let minLength = 3
        let isValid = sanitized.count >= minLength && sanitized.count <= maxLength
        return isValid
    }
    
    public func format(_ string: String) -> String {
        return sanitize(string)
    }
    
    // MARK: - Private
    
    private let maxLength = 4
    
}
