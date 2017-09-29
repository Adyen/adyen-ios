//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// An object that provides static methods for validating and formatting card numbers, expiry dates, and cvc values, and detecting card types.
public final class CardValidator {
    
    // MARK: - Validating
    
    /// Validates and formats the given card number, and detects the corresponding card type.
    ///
    /// - Parameters:
    ///   - cardNumber: The card number to validate and format. The card number is sanitized before validating and formatting, to filter out non-numerical characters.
    ///   - acceptedCardTypes: The card types to check against for detecting the card type.
    /// - Returns: A tuple containing a boolean value indicating whether the card number is valid, the detected card type, and the formatted card number.
    public static func validate(cardNumber: String, acceptedCardTypes: [CardType] = CardType.all) -> (isValid: Bool, type: CardType?, formattedNumber: String) {
        let sanitizedCardNumber = sanitize(cardNumber)
        
        let cardType = acceptedCardTypes.first { $0.matches(cardNumber: sanitizedCardNumber) }
        let formattedCardNumber = sanitizedCardNumber.grouped(length: 4)
        let isValid = sanitizedCardNumber.characters.count >= minimumValidCardLength && luhnCheck(sanitizedCardNumber)
        
        return (isValid, cardType, formattedCardNumber)
    }
    
    /// Validates and formats the given expiration date.
    ///
    /// - Parameters:
    ///   - expiryDate: The expiry date to validate and format. The expiry date is sanitized before validating and formatting, to filter out non-numerical characters.
    ///   - separator: The optional string to use to separate the month and year in the formatted date, default is `/`.
    /// - Returns: A tuple containing a boolean value indicating whether the expiry date is valid, and a formatted expiry date.
    public static func validate(expiryDate: String, separator: String? = "/") -> (isValid: Bool, formattedDate: String) {
        let separator = separator ?? ""
        
        let sanitizedString = sanitize(expiryDate)
        
        let yearPrefix = "20"
        var formattedDate = sanitizedString
        var month = 0
        var year = 0
        
        switch sanitizedString.characters.count {
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
            year = Int(yearPrefix + sanitizedString[2...3])!
            formattedDate = sanitizedString[0...1] + separator + sanitizedString[2...3]
        default:
            break
        }
        
        let isMonthValid = (month >= 1 && month <= 12) || sanitizedString.characters.count < 2
        if !isMonthValid {
            formattedDate = ""
        }
        
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
        
        return (isValid, formattedDate)
    }
    
    /// Validates and formats the given cvc.
    ///
    /// - Parameters:
    ///   - cvc: The cvc value to validate and format. The cvc is sanitized before validating and formatting, to filter out non-numerical characters.
    /// - Returns: A tuple containing a boolean value indicating whether the cvc is valid, and the formatted cvc string.
    public static func validate(cvc: String) -> (isValid: Bool, formattedCvc: String) {
        let sanitizedCvc = sanitize(cvc)
        let isValid = sanitizedCvc.characters.count >= 3 && sanitizedCvc.characters.count <= 4
        return (isValid, sanitizedCvc)
    }
    
    // MARK: - Private
    
    private static let minimumValidCardLength = 12
    
    private static func sanitize(_ string: String) -> String {
        let allowedCharacters = CharacterSet.decimalDigits
        let filteredUnicodeScalars = string.unicodeScalars.filter(allowedCharacters.contains(_:))
        
        let sanitizedString = filteredUnicodeScalars.reduce("") { (string, unicodeScalar) -> String in
            return string + String(unicodeScalar)
        }
        
        return sanitizedString
    }
    
    private static func luhnCheck(_ cardNumber: String) -> Bool {
        let reversedCardNumberDigits = cardNumber.characters.reversed().flatMap { Int(String($0)) }
        
        var sum = 0
        for (index, digit) in reversedCardNumberDigits.enumerated() {
            let isOdd = index % 2 == 1
            
            switch (isOdd, digit) {
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
    
}

fileprivate extension CardType {
    
    fileprivate func matches(cardNumber: String) -> Bool {
        guard let pattern = regex else {
            return false
        }
        
        do {
            let regularExpression = try NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(location: 0, length: cardNumber.characters.count)
            
            return regularExpression.firstMatch(in: cardNumber, options: [], range: range) != nil
        } catch {
            return false
        }
    }
    
}
