//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

class CardNumberValidator: NumericValidator {
    
    func isValid(_ string: String) -> Bool {
        let sanitizedCardNumber = sanitize(string)
        let minimumValidCardLength = 12
        let isValid = sanitizedCardNumber.count >= minimumValidCardLength && luhnCheck(sanitizedCardNumber)
        
        return isValid
    }
    
    func isMaxLength(_ string: String) -> Bool {
        return string.count >= 23
    }
    
    func format(_ string: String) -> String {
        let sanitizedCardNumber = sanitize(string)
        let formattedCardNumber = sanitizedCardNumber.grouped(length: 4)
        return formattedCardNumber
    }
    
    // MARK: - Private
    
    private func luhnCheck(_ cardNumber: String) -> Bool {
        let reversedCardNumberDigits = cardNumber.reversed().compactMap { Int(String($0)) }
        
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
