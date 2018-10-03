//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

public protocol Validator {
    func isValid(_ string: String) -> Bool
    func isMaxLength(_ string: String) -> Bool
    func format(_ string: String) -> String
    func sanitize(_ string: String) -> String
}

public extension Validator {
    func isValid(_ string: String) -> Bool {
        return true
    }
    
    func isMaxLength(_ string: String) -> Bool {
        return false
    }
    
    func format(_ string: String) -> String {
        return string
    }
    
    func sanitize(_ string: String) -> String {
        return string
    }
}

public protocol NumericValidator: Validator {}

public extension NumericValidator {
    func sanitize(_ string: String) -> String {
        let allowedCharacters = CharacterSet.decimalDigits
        let filteredUnicodeScalars = string.unicodeScalars.filter(allowedCharacters.contains(_:))
        
        let sanitizedString = filteredUnicodeScalars.reduce("") { (string, unicodeScalar) -> String in
            return string + String(unicodeScalar)
        }
        
        return sanitizedString
    }
}
