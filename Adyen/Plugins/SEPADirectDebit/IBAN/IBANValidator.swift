//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// An object that provides a static method to validate IBAN values.
public class IBANValidator {
    
    // MARK: - Validating
    
    /// Checks if the given string is a valid IBAN value.
    ///
    /// - Parameter string: The IBAN value to check for validity.
    /// - Returns: A Boolean value indicating whether the given string is a valid IBAN.
    public static func isValid(_ string: String) -> Bool {
        // Canonicalize the string for processing.
        let canonicalizedString = canonicalize(string)
        
        // Retrieve the country code from the IBAN.
        guard let countryCode = countryCode(in: canonicalizedString) else {
            return false
        }
        
        // Retrieve the IBAN specification for the country.
        guard let specification = IBANSpecification(forCountryCode: countryCode) else {
            return false
        }
        
        // Check if the string matches the length of a valid IBAN according to the country's specification.
        guard canonicalizedString.characters.count == specification.length else {
            return false
        }
        
        // Rearrange the string.
        let rearrangedString = rearrange(canonicalizedString)
        
        // Convert the string to numbers.
        let numerifiedString = numerify(rearrangedString)
        
        // Calculate the modulus of the numerified string.
        guard let modulus = mod97(numerifiedString) else {
            return false
        }
        
        // The IBAN is valid of the mod97 operation returns 1.
        return modulus == 1
    }
    
    // MARK: - Internal
    
    /// Prepares the given string for IBAN validation. Removes all invalid characters and converts lowercase letters to uppercase letters.
    ///
    /// - Parameter string: The string to canonicalize.
    /// - Returns: A canonicalized string.
    internal static func canonicalize(_ string: String) -> String {
        let alphanumerics = CharacterSet.alphanumerics
        let lowercaseLetters = CharacterSet.lowercaseLetters
        
        let components = string.unicodeScalars.flatMap { unicodeScalar -> String? in
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
    ///
    /// - Parameter string: The string to retrieve the country code from.
    /// - Returns: The country code in the string, or `nil` if the country code couldn't be found.
    internal static func countryCode(in string: String) -> String? {
        guard string.characters.count >= 2 else {
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
    ///
    /// - Parameter string: The string to rearrange.
    /// - Returns: A rearranged string.
    internal static func rearrange(_ string: String) -> String {
        let index = string.index(string.startIndex, offsetBy: 4)
        let lowerSubstring = string[..<index]
        let upperSubstring = string[index...]
        
        return String(upperSubstring + lowerSubstring)
    }
    
    /// Converts every letter in a string to a number, where A is 10, B is 11, Z is 35.
    /// All letters should be uppercased.
    ///
    /// - Parameter string: The string to convert to numbers.
    /// - Returns: A numbers-only string.
    internal static func numerify(_ string: String) -> String {
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
    ///
    /// - Parameter string: A numbers-only string on which to perform the mod-97 operation.
    /// - Returns: The remainder of the string divided by 97, or `nil` if the operation failed.
    internal static func mod97(_ string: String) -> Int? {
        func modulo(_ string: String) -> Int? {
            guard let integer = Int(string) else {
                return nil
            }
            
            return integer % 97
        }
        
        guard string.characters.count < 9 else {
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
