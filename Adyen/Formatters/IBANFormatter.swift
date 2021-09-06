//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

/// Formats an IBAN (International Bank Account Number).
public final class IBANFormatter: Formatter {
    
    /// Initializes the IBAN formatter.
    public init() {}
    
    /// :nodoc:
    public func formattedValue(for value: String) -> String {
        // Sanitize the string first, then group it into sets of 4.
        sanitizedValue(for: value).adyen.components(withLength: 4).joined(separator: " ")
    }
    
    /// :nodoc:
    public func sanitizedValue(for value: String) -> String {
        let alphanumerics = CharacterSet.alphanumerics
        let lowercaseLetters = CharacterSet.lowercaseLetters
        
        let components = value.unicodeScalars.compactMap { unicodeScalar -> String? in
            // Ensure the character is allowed.
            guard alphanumerics.contains(unicodeScalar) else {
                return nil
            }
            
            // If it's a lowercase letter, transform into uppercase.
            if lowercaseLetters.contains(unicodeScalar) {
                return String(unicodeScalar).uppercased()
            }
            
            return String(unicodeScalar)
        }
        
        return components.joined()
    }
    
}
