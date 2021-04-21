//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// Formats a card's expiration date for display.
/// The input is expected to be sanitized as "MMYY", which will result in "MM / YY".
public final class CardExpiryDateFormatter: NumericFormatter {
    
    /// :nodoc:
    override public func formattedValue(for value: String) -> String {
        let separator = " / "
        
        let sanitizedString = sanitizedValue(for: value).adyen.truncate(to: maxLength)
        
        var formattedDate = sanitizedString
        var month = 0
        
        switch sanitizedString.count {
        case 0: break
        case 1:
            month = Int(sanitizedString)!
            if month > 1 {
                formattedDate = "0" + sanitizedString + separator
            }
        case 2:
            month = Int(sanitizedString)!
            formattedDate = sanitizedString
            
            // Only add the separator when the input value is 2 characters,
            // or if the input value already had the separator appended.
            // This is to allow for deleting the separator (going from "09 / 2" to "09").
            if value.count == 2 || value.contains(separator) {
                formattedDate += separator
            }
        case 3:
            month = Int(sanitizedString.adyen[0...1])!
            formattedDate = sanitizedString.adyen[0...1] + separator + sanitizedString.adyen[2]
        case 4:
            month = Int(sanitizedString.adyen[0...1])!
            formattedDate = sanitizedString.adyen[0...1] + separator + sanitizedString.adyen[2...3]
        default:
            break
        }
        
        let isMonthValid = (month >= 1 && month <= 12) || sanitizedString.count < 2
        if !isMonthValid {
            formattedDate = ""
        }
        
        return formattedDate
    }
    
    // MARK: - Private
    
    private let maxLength = 4
}
