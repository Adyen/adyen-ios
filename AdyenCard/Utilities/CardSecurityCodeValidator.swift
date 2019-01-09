//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

class CardSecurityCodeValidator: NumericValidator {
    
    func isMaxLength(_ string: String) -> Bool {
        return string.count >= maxLength
    }
    
    func isValid(_ string: String) -> Bool {
        let sanitized = sanitize(string)
        let minLength = 3
        let isValid = sanitized.count >= minLength && sanitized.count <= maxLength
        return isValid
    }
    
    func format(_ string: String) -> String {
        return sanitize(string)
    }
    
    // MARK: - Private
    
    private let maxLength = 4
    
}
