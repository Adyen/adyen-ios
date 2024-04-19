//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation

@_spi(AdyenInternal)
public final class CardHolderNameValidator: StatusValidator {
    
    public func isValid(_ value: String) -> Bool {
        validate(value).isValid
    }
    
    public func maximumLength(for value: String) -> Int {
        .max
    }
    
    public func validate(_ value: String) -> Adyen.ValidationStatus {
        if value.isEmpty {
            return .invalid(CardValidationError.holderNameEmpty)
        }
        
        return .valid
    }
}
