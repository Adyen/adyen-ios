//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import XCTest

final class BrazilSocialSecurityNumberValidatorTests: XCTestCase {

    func testValidNumbers() {
        let validator = BrazilSocialSecurityNumberValidator()
        
        XCTAssertTrue(validator.isValid("12312312312"))
        XCTAssertTrue(validator.isValid("12345678956"))
        XCTAssertTrue(validator.isValid("55667799436712"))
        XCTAssertTrue(validator.isValid("12547806369854"))
        
        let status = validator.validate("55667799436712")
        XCTAssertNil(status.validationError)
        XCTAssertTrue(status.isValid)
    }
    
    func testEmptyInvalidNumber() {
        let validator = BrazilSocialSecurityNumberValidator()
        let status = validator.validate("")
        
        XCTAssertNotNil(status.validationError)
        let validationError = status.validationError as? BrazilAnalyticsValidationError
        XCTAssertEqual(validationError, .socialSecurityNumberEmpty)
        XCTAssertEqual(validationError?.analyticsErrorCode, AnalyticsConstants.ValidationErrorCodes.brazilSSNEmpty)
    }
    
    func testPartialInvalidNumber() {
        let validator = BrazilSocialSecurityNumberValidator()
        var status = validator.validate("123")
        
        XCTAssertNotNil(status.validationError)
        var validationError = status.validationError as? BrazilAnalyticsValidationError
        XCTAssertEqual(validationError, .socialSecurityNumberPartial)
        
        status = validator.validate("1234567895612")
        validationError = status.validationError as? BrazilAnalyticsValidationError
        XCTAssertEqual(validationError, .socialSecurityNumberPartial)
        XCTAssertEqual(validationError?.analyticsErrorCode, AnalyticsConstants.ValidationErrorCodes.brazilSSNPartial)
    }

}
