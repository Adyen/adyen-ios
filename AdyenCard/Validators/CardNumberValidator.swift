//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Validates a card's number.
/// The input is expected to be sanitized.
public final class CardNumberValidator: Validator {
    
    /// :nodoc:
    public func isValid(_ value: String) -> Bool {
        let minimumValidCardLength = 12
        let isValid = value.count >= minimumValidCardLength && luhnCheck(value)
        
        return isValid
    }
    
    /// :nodoc:
    public func maximumLength(for value: String) -> Int {
        return 19
    }
    
    // MARK: - Private
    
    /// Performs Luhn Check in a given card number.
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
