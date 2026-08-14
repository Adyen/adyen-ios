//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable @_spi(AdyenInternal) import AdyenCard
import XCTest

class CardSecurityCodeValidatorTests: XCTestCase {
    
    func test_isValid_givenCorrectLengthForBrand_shouldReturnTrue() {
        let observer = AdyenObservable<CardType?>(.masterCard)
        let validator = CardSecurityCodeValidator(publisher: observer)
        
        XCTAssertTrue(validator.isValid("123"))
        XCTAssertFalse(validator.isValid("1234"))
        
        observer.wrappedValue = .americanExpress
        XCTAssertFalse(validator.isValid("123"))
        XCTAssertTrue(validator.isValid("1234"))
    }
    
    func test_defaultLength_givenNilBrand_shouldExpectThreeDigits() {
        let observer = AdyenObservable<CardType?>(nil)
        let validator = CardSecurityCodeValidator(publisher: observer)

        XCTAssertFalse(validator.isValid("12"))
        XCTAssertTrue(validator.isValid("123"))
        XCTAssertFalse(validator.isValid("1234"))
    }

    func test_isValid_givenIncorrectLength_shouldReturnFalse() {
        let validator = CardSecurityCodeValidator()
        
        XCTAssertFalse(validator.isValid(""))
        XCTAssertFalse(validator.isValid("1"))
        XCTAssertFalse(validator.isValid("12"))
        XCTAssertFalse(validator.isValid("12345"))
    }
    
    func test_validate_givenEmptyCode_shouldReturnEmptyError() {
        let validator = CardSecurityCodeValidator()
        let status = validator.validate("")
        
        XCTAssertNotNil(status.validationError)
        let validationError = status.validationError as? CardValidationError
        XCTAssertEqual(validationError, .securityCodeEmpty)
        XCTAssertEqual(validationError?.analyticsErrorCode, AnalyticsConstants.ValidationErrorCodes.securityCodeEmpty)
    }
    
    func test_validate_givenPartialCode_shouldReturnPartialError() {
        let validator = CardSecurityCodeValidator()
        let status = validator.validate("12")
        
        XCTAssertNotNil(status.validationError)
        let validationError = status.validationError as? CardValidationError
        XCTAssertEqual(validationError, .securityCodePartial)
        XCTAssertEqual(validationError?.analyticsErrorCode, AnalyticsConstants.ValidationErrorCodes.securityCodePartial)
    }
    
    func test_validate_givenValidRegularCode_shouldReturnValidStatus() {
        let validator = CardSecurityCodeValidator()
        let status = validator.validate("123")
        
        XCTAssertNil(status.validationError)
        XCTAssertTrue(status.isValid)
    }
    
    func test_validate_givenAmexBrand_shouldRequireFourDigits() {
        let validator = CardSecurityCodeValidator(cardType: .americanExpress)
        let invalidStatus = validator.validate("123")
        
        XCTAssertNotNil(invalidStatus.validationError)
        XCTAssertFalse(invalidStatus.isValid)
        
        let validStatus = validator.validate("1234")
        XCTAssertNil(validStatus.validationError)
        XCTAssertTrue(validStatus.isValid)
    }
    
}
