//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// Validates a card's number.
/// The input is expected to be sanitized.
public final class CardNumberValidator: Validator {
    
    private enum Constants {
        static let maxPanLength = 19
    }
    
    /// Indicates whether to validate for luhn check
    private let isLuhnCheckEnabled: Bool
    
    /// Indicates whether the detected brand is supported or not.
    private let isEnteredBrandSupported: Bool
    
    /// Length of the card number if available.
    private let panLength: Int?
    
    /// :nodoc:
    public init(isLuhnCheckEnabled: Bool,
                isEnteredBrandSupported: Bool,
                panLength: Int? = nil) {
        self.isLuhnCheckEnabled = isLuhnCheckEnabled
        self.isEnteredBrandSupported = isEnteredBrandSupported
        self.panLength = panLength
    }
    
    /// :nodoc:
    public func isValid(_ value: String) -> Bool {
        guard isEnteredBrandSupported else { return false }
        let minimumValidCardLength = 12
        let isValid = value.count >= minimumValidCardLength && (!isLuhnCheckEnabled || luhnCheck(value))
        
        return isValid
    }
    
    /// :nodoc:
    public func maximumLength(for value: String) -> Int {
        panLength ?? Constants.maxPanLength
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
