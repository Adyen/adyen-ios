//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
@_spi(AdyenInternal) import enum Adyen.ValidationStatus
import Foundation

/// Validates a card's security code.
public final class CardSecurityCodeValidator: NumericStringValidator, AdyenObserver {
    
    /// Initiate new instance of CardSecurityCodeValidator
    public init() {
        super.init(minimumLength: 3, maximumLength: 4)
    }
    
    /// Initiate new instance of CardSecurityCodeValidator
    /// - Parameter publisher: Observable of a card type
    public init(publisher: AdyenObservable<CardBrand?>) {
        super.init(minimumLength: 3, maximumLength: 4)
        
        updateExpectedLength(from: publisher.wrappedValue)
        
        observe(publisher) { [weak self] cardBrand in
            self?.updateExpectedLength(from: cardBrand)
        }
    }
    
    /// Initiate new instance of CardSecurityCodeValidator with a fixed ``CardBrand``
    /// - Parameter cardBrand: The card brand to validate the security code for
    public init(cardBrand: CardBrand) {
        super.init(minimumLength: 3, maximumLength: 4)
        
        updateExpectedLength(from: cardBrand)
    }
    
    private func updateExpectedLength(from cardBrand: CardBrand?) {
        let length = cardBrand == .americanExpress ? 4 : 3
        maximumLength = length
        minimumLength = length
    }
    
    override public func isValid(_ value: String) -> Bool {
        validate(value).isValid
    }
    
}

@_spi(AdyenInternal)
extension CardSecurityCodeValidator: StatusValidator {
    
    public func validate(_ value: String) -> ValidationStatus {
        if super.isValid(value) {
            return .valid
        }
        
        if value.isEmpty {
            return .invalid(CardValidationError.securityCodeEmpty)
        }
        
        return .invalid(CardValidationError.securityCodePartial)
    }
}
