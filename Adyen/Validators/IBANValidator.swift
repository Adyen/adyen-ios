//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Validates an IBAN (International Bank Account Number).
/// The input is expected to be sanitized.
public final class IBANValidator: Validator {
    
    /// :nodoc:
    public init() {}
    
    /// :nodoc:
    public func isValid(_ value: String) -> Bool {
        let minimumLength = 4
        guard minimumLength...maximumLength(for: value) ~= value.count else {
            return false
        }
        
        let rearrangedValue = rearrange(value)
        let numberValue = convertToNumber(rearrangedValue)
        
        guard let modulus = mod97(numberValue) else {
            return false
        }
        
        return modulus == 1
    }
    
    /// :nodoc:
    public func maximumLength(for value: String) -> Int {
        guard let countryCode = countryCode(in: value) else {
            return IBANSpecification.highestMaximumLength
        }
        
        guard let specification = IBANSpecification(forCountryCode: countryCode) else {
            return IBANSpecification.highestMaximumLength
        }
        
        return specification.length
    }
    
    // MARK: - Private
    
    /// Retrieves the country code (the first two letters of an IBAN) from a given string.
    private func countryCode(in string: String) -> String? {
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
    private func rearrange(_ string: String) -> String {
        let index = string.index(string.startIndex, offsetBy: 4)
        let lowerSubstring = string[..<index]
        let upperSubstring = string[index...]
        
        return String(upperSubstring + lowerSubstring)
    }
    
    /// Converts every letter in a string to a number, where A is 10, B is 11, Z is 35.
    /// All letters should be uppercased.
    private func convertToNumber(_ string: String) -> String {
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
    
    /// Performs a mod-97 operation on a given string.
    /// The string can be of infinite length, but should contain numbers only.
    private func mod97(_ string: String) -> Int? {
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
