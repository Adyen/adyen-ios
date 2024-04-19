//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

@_spi(AdyenInternal)
public final class BrazilSocialSecurityNumberValidator: CombinedValidator, StatusValidator {
    
    private enum Constants {
        static let firstMaxLength = 11
        static let secondMaxLength = 14
    }
    
    public let firstValidator: Validator
    
    public let secondValidator: Validator
    
    public init() {
        self.firstValidator = NumericStringValidator(exactLength: Constants.firstMaxLength)
        self.secondValidator = NumericStringValidator(exactLength: Constants.secondMaxLength)
    }
    
    public func validate(_ value: String) -> Adyen.ValidationStatus {
        if value.isEmpty {
            return .invalid(BrazilAnalyticsValidationError.socialSecurityNumberEmpty)
        }
        
        let isValid = firstValidator.isValid(value) || secondValidator.isValid(value)
        
        if !isValid {
            return .invalid(BrazilAnalyticsValidationError.socialSecurityNumberPartial)
        }
        
        return .valid
    }
    
    public func isValid(_ value: String) -> Bool {
        validate(value).isValid
    }
}

internal enum BrazilAnalyticsValidationError: String, AnalyticsValidationError {
    
    /// Social security number for Brazil is not filled.
    case socialSecurityNumberEmpty
    
    /// Social security number for Brazil is partially filled.
    case socialSecurityNumberPartial
    
    internal var analyticsErrorCode: Int {
        switch self {
        case .socialSecurityNumberEmpty:
            return 926
        case .socialSecurityNumberPartial:
            return 927
        }
    }
    
    internal var analyticsErrorMessage: String {
        switch self {
        case .socialSecurityNumberEmpty:
            return "Empty social security number field."
        case .socialSecurityNumberPartial:
            return "Empty social security number has only been partially field."
        }
    }
    
}
