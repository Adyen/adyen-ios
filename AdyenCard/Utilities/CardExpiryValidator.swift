//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

class CardExpiryValidator: NumericValidator {
    
    func isMaxLength(_ string: String) -> Bool {
        return sanitize(string).count >= maxLength
    }
    
    func isValid(_ string: String) -> Bool {
        let sanitizedString = sanitize(string)
        
        guard sanitizedString.count == maxLength else {
            return false
        }
        
        let month = Int(sanitizedString[0...1])!
        let yearPrefix = "20"
        let year = Int(yearPrefix + sanitizedString[2...3])!
        
        let isMonthValid = (month >= 1 && month <= 12) || sanitizedString.count < 2
        
        var isValid = false
        if year > 0 {
            let date = Date()
            let calendar = Calendar.current
            let components = calendar.dateComponents([.month, .year], from: date)
            let currentMonth = components.month!
            let currentYear = components.year!
            
            // year already has "20"+ here
            if year == currentYear && month < currentMonth {
                isValid = false
            } else if year == currentYear && isMonthValid && month >= currentMonth {
                isValid = true
            } else if year > currentYear && isMonthValid {
                isValid = true
            } else {
                isValid = false
            }
        }
        
        return isValid
    }
    
    func format(_ string: String) -> String {
        let separator = "/"
        
        let sanitizedString = sanitize(string)
        
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
            formattedDate = sanitizedString + separator
        case 3:
            month = Int(sanitizedString[0...1])!
            formattedDate = sanitizedString[0...1] + separator + sanitizedString[2]
        case 4:
            month = Int(sanitizedString[0...1])!
            formattedDate = sanitizedString[0...1] + separator + sanitizedString[2...3]
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
    
    let maxLength = 4
}
