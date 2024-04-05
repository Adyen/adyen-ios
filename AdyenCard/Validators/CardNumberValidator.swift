//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation

/// Validates a card's number.
/// The input is expected to be sanitized.
@_spi(AdyenInternal)
public final class CardNumberValidator: StatusValidator {
    
    private enum Constants {
        static let maxPanLength = 19
    }
    
    /// Indicates whether to validate for luhn check
    private let isLuhnCheckEnabled: Bool
    
    /// Indicates whether the detected brand is supported or not.
    private let isEnteredBrandSupported: Bool
    
    /// Length of the card number if available.
    private let panLength: Int?
    
    /// Initializes a new instance of `CardNumberValidator`
    ///
    /// - Parameters:
    ///   - isLuhnCheckEnabled: Indicates whether luhn check is enabled.
    ///   - isEnteredBrandSupported: Is the brand being validated supported.
    ///   - panLength: The PAN length.
    public init(isLuhnCheckEnabled: Bool,
                isEnteredBrandSupported: Bool,
                panLength: Int? = nil) {
        self.isLuhnCheckEnabled = isLuhnCheckEnabled
        self.isEnteredBrandSupported = isEnteredBrandSupported
        self.panLength = panLength
    }
    
    public func validate(_ value: String) -> ValidationStatus {
        // order of checks are important to return the correct error.
        
        if !isEnteredBrandSupported {
            return .invalid(CardValidationError.cardUnsupported)
        }
        
        if value.isEmpty {
            return .invalid(CardValidationError.cardNumberEmpty)
        }
        
        if value.count < 12 {
            return .invalid(CardValidationError.cardNumberPartial)
        }
        
        if isLuhnCheckEnabled, !luhnCheck(value) {
            return .invalid(CardValidationError.cardLuhCheckFailed)
        }
        
        return .valid
    }
    
    public func isValid(_ value: String) -> Bool {
        validate(value).isValid
    }
    
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
