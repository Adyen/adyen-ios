//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
@_spi(AdyenInternal) import enum Adyen.ValidationStatus
import Foundation

/// Validates birthdate (YYMMDD) or the Corporate registration number (10 digits) for KCP.
package final class CardKCPFieldValidator: CombinedValidator, StatusValidator {

    private enum Constants {
        static let exactLength = 10
    }
    
    package let firstValidator: Validator

    package let secondValidator: Validator

    package init() {
        self.firstValidator = NumericStringValidator(exactLength: Constants.exactLength)
        self.secondValidator = DateValidator(format: DateValidator.Format.kcpFormat)
    }
    
    package func validate(_ value: String) -> ValidationStatus {
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
    
    package func isValid(_ value: String) -> Bool {
        validate(value).isValid
    }
}

package final class CardKCPPasswordValidator: LengthValidator, StatusValidator {

    private enum Constants {
        static let exactLength = 2
    }
    
    package init() {
        super.init(exactLength: Constants.exactLength)
    }
    
    package func validate(_ value: String) -> ValidationStatus {
        if super.isValid(value) {
            return .valid
        }
        
        if value.isEmpty {
            return .invalid(CardValidationError.kcpPasswordEmpty)
        }
        
        return .invalid(CardValidationError.kcpPasswordPartial)
    }
    
    override package func isValid(_ value: String) -> Bool {
        validate(value).isValid
    }
    
}
