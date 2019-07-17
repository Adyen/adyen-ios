//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Validates a card's expiration date.
/// The input is expected to be sanitized as "MMYY".
/// Validation will fail when the format is invalid or the date is in the past.
public final class CardExpiryDateValidator: Validator {
    
    /// :nodoc:
    public func isValid(_ string: String) -> Bool {
        guard string.count == maximumLength(for: string) else {
            return false
        }
        
        let month = Int(string[0...1])!
        let yearPrefix = "20"
        let year = Int(yearPrefix + string[2...3])!
        
        let isMonthValid = (month >= 1 && month <= 12) || string.count < 2
        
        var isValid = false
        if year > 0 {
            let date = Date()
            let calendar = Calendar(identifier: .gregorian)
            let components = calendar.dateComponents([.month, .year], from: date)
            let currentMonth = components.month!
            let currentYear = components.year!
            
            // year already has "20"+ here
            if year == currentYear, month < currentMonth {
                isValid = false
            } else if year == currentYear, isMonthValid, month >= currentMonth {
                isValid = true
            } else if year > currentYear, isMonthValid {
                isValid = true
            } else {
                isValid = false
            }
        }
        
        return isValid
    }
    
    /// :nodoc:
    public func maximumLength(for value: String) -> Int {
        return 4
    }
    
}
