//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

class CardValidator {
    // Based on maestro card
    private static let minValidCardLength = 12
    
    private static func matchesRegex(_ regex: String!, text: String!) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [.caseInsensitive])
            let nsString = text as NSString
            let match = regex.firstMatch(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
            return (match != nil)
        } catch {
            return false
        }
    }
    
    private static func luhnCheck(_ number: String) -> Bool {
        var sum = 0
        let digitStrings = number.characters.reversed().map { String($0) }
        
        for tuple in digitStrings.enumerated() {
            
            guard let digit = Int(tuple.element) else { return false }
            let odd = tuple.offset % 2 == 1
            
            switch (odd, digit) {
            case (true, 9):
                sum += 9
            case (true, 0...8):
                sum += (digit * 2) % 9
            default:
                sum += digit
            }
        }
        
        return sum % 10 == 0
    }
    
    static func validate(card: String, acceptedCards: [CardType]) -> (type: CardType, formatted: String, valid: Bool) {
        let numberOnly = card.numberOnly()
        
        var type: CardType = .unknown
        var formatted = ""
        var valid = false
        
        for card in acceptedCards {
            if matchesRegex(card.regex, text: numberOnly) {
                type = card
                break
            }
        }
        
        valid = luhnCheck(numberOnly) && numberOnly.characters.count >= minValidCardLength
        
        var formatted4 = ""
        for character in numberOnly.characters {
            if formatted4.characters.count == 4 {
                formatted += formatted4 + " "
                formatted4 = ""
            }
            formatted4.append(character)
        }
        
        formatted += formatted4 // the rest
        
        return (type, formatted, valid)
    }
    
    static func validate(expiryDate: String, split: Bool = true) -> (formatted: String, valid: Bool, month: String, year: String) {
        let suffix = split ? " / " : ""
        
        let numberOnly = expiryDate.numberOnly()
        var formatted = numberOnly
        var valid = false
        var month = 0
        var year = 0
        
        let yearPrefix = "20"
        
        switch numberOnly.characters.count {
        case 0: break
        case 1:
            month = Int(numberOnly)!
            if month > 1 {
                formatted = "0" + numberOnly + suffix
            }
            
        case 2:
            month = Int(numberOnly)!
            formatted = numberOnly + suffix
        case 3:
            month = Int(numberOnly[0...1])!
            formatted = numberOnly[0...1] + suffix + numberOnly[2]
        case 4:
            month = Int(numberOnly[0...1])!
            year = Int(yearPrefix + numberOnly[2...3])!
            formatted = numberOnly[0...1] + suffix + numberOnly[2...3]
        default:
            break
        }
        
        let validMonth = (month >= 1 && month <= 12) ? true : false
        
        if month > 12 {
            formatted = ""
        }
        
        if year > 0 {
            let date = Date()
            let calendar = Calendar.current
            let components = (calendar as NSCalendar).components([.month, .year], from: date)
            let currentYear = components.year
            let currentMonth = components.month
            
            // year already has "20"+ here
            if year == currentYear! && month < currentMonth! {
                valid = false
            } else if year == currentYear! && validMonth && month >= currentMonth! {
                valid = true
            } else if year > currentYear! && validMonth {
                valid = true
            } else {
                valid = false
            }
        }
        
        return (formatted, valid, String(month), String(year))
    }
}
