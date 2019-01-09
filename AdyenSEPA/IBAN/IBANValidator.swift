//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// An object that provides a static method to validate IBAN values.
internal class IBANValidator: Validator {
    
    func sanitize(_ string: String) -> String {
        return canonicalize(string)
    }
    
    func isMaxLength(_ string: String) -> Bool {
        // Max possible length, as per IBANSpecification
        return sanitize(string).count >= 32
    }
    
    /// Checks if the given string is a valid IBAN value.
    ///
    /// - Parameter string: The IBAN value to check for validity.
    /// - Returns: A Boolean value indicating whether the given string is a valid IBAN.
    func isValid(_ string: String) -> Bool {
        let canonicalizedString = canonicalize(string)
        
        guard let countryCode = countryCode(in: canonicalizedString) else {
            return false
        }
        
        guard let specification = IBANSpecification(forCountryCode: countryCode) else {
            return false
        }
        
        guard canonicalizedString.count == specification.length else {
            return false
        }
        
        let rearrangedString = rearrange(canonicalizedString)
        let numerifiedString = numerify(rearrangedString)
        
        guard let modulus = mod97(numerifiedString) else {
            return false
        }
        
        return modulus == 1
    }
    
    func format(_ string: String) -> String {
        let string = canonicalize(string)
        return string.grouped(length: 4)
    }
    
    // MARK: - Internal
    
    /// Prepares the given string for IBAN validation. Removes all invalid characters and converts lowercase letters to uppercase letters.
    func canonicalize(_ string: String) -> String {
        let alphanumerics = CharacterSet.alphanumerics
        let lowercaseLetters = CharacterSet.lowercaseLetters
        
        let components = string.unicodeScalars.compactMap { unicodeScalar -> String? in
            guard alphanumerics.contains(unicodeScalar) else {
                return nil
            }
            
            if lowercaseLetters.contains(unicodeScalar) {
                return String(unicodeScalar).uppercased()
            }
            
            return String(unicodeScalar)
            
        }
        
        return components.joined()
    }
    
    /// Retrieves the country code (the first two letters of an IBAN) from a given string.
    func countryCode(in string: String) -> String? {
        guard string.count >= 2 else {
            return nil
        }
        
        let lowerBound = string.startIndex
        let upperBound = string.index(lowerBound, offsetBy: 2)
        let range = lowerBound..<upperBound
        
        let countryCode = String(string[range])
        
        // Verify that the country code only contains uppercase letters.
        guard countryCode.rangeOfCharacter(from: CharacterSet.uppercaseLetters.inverted) == nil else {
            return nil
        }
        
        return countryCode
    }
    
    /// Rearranges the string to prepare for IBAN validation.
    /// The country code and check numbers (the four initial characters) are moved to the end of the string.
    /// The string is expected to be at least 4 characters.
    func rearrange(_ string: String) -> String {
        let index = string.index(string.startIndex, offsetBy: 4)
        let lowerSubstring = string[..<index]
        let upperSubstring = string[index...]
        
        return String(upperSubstring + lowerSubstring)
    }
    
    /// Converts every letter in a string to a number, where A is 10, B is 11, Z is 35.
    /// All letters should be uppercased.
    func numerify(_ string: String) -> String {
        let startIndex = ("A" as UnicodeScalar).value
        let endIndex = ("Z" as UnicodeScalar).value
        let range = startIndex...endIndex
        
        let components = string.unicodeScalars.map { unicodeScalar -> String in
            guard range.contains(unicodeScalar.value) else {
                return String(unicodeScalar)
            }
            
            let numericalValue = 10 + unicodeScalar.value - startIndex
            
            return String(numericalValue)
        }
        
        return components.joined()
    }
    
    /// Performs a mod-97 operation on a given string. The string can be of infinite length, but should contain numbers only.
    func mod97(_ string: String) -> Int? {
        func modulo(_ string: String) -> Int? {
            guard let integer = Int(string) else {
                return nil
            }
            
            return integer % 97
        }
        
        guard string.count < 9 else {
            let splitIndex = string.index(string.startIndex, offsetBy: 9)
            let lowerSubstring = String(string[..<splitIndex])
            let upperSubstring = String(string[splitIndex...])
            
            guard let lowerSubstringModulus = modulo(lowerSubstring) else {
                return nil
            }
            
            return mod97(String(lowerSubstringModulus) + upperSubstring)
        }
        
        return modulo(string)
    }
    
}
