//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation

/// Validates birthdate (YYMMDD) or the Corporate registration number (10 digits) for KCP.
@_spi(AdyenInternal)
public final class CardKCPFieldValidator: CombinedValidator, StatusValidator {
    
    public let firstValidator: Validator
    
    public let secondValidator: Validator
    
    public init() {
        self.firstValidator = NumericStringValidator(exactLength: 10)
        self.secondValidator = DateValidator(format: DateValidator.Format.kcpFormat)
    }
    
    public func validate(_ value: String) -> Adyen.ValidationStatus {
        if value.isEmpty {
            return .invalid(CardValidationError.kcpFieldEmpty)
        }
        
        // Logical OR the 2 possible validators.
        let isValid = firstValidator.isValid(value) || secondValidator.isValid(value)
        
        if !isValid {
            return .invalid(CardValidationError.kcpFieldPartial)
        }
        
        return .valid
    }
    
    public func isValid(_ value: String) -> Bool {
        validate(value).isValid
    }
}

@_spi(AdyenInternal)
public final class CardKCPPasswordValidator: LengthValidator, StatusValidator {
    
    private enum Constants {
        static let exactLength = 2
    }
    
    public init() {
        super.init(exactLength: Constants.exactLength)
    }
    
    public func validate(_ value: String) -> Adyen.ValidationStatus {
        if super.isValid(value) {
            return .valid
        }
        
        if value.isEmpty {
            return .invalid(CardValidationError.kcpPasswordEmpty)
        }
        
        return .invalid(CardValidationError.kcpPasswordPartial)
    }
    
    override public func isValid(_ value: String) -> Bool {
        validate(value).isValid
    }
    
}
