//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable @_spi(AdyenInternal) import AdyenCard
@_spi(AdyenInternal) @testable import Adyen
import XCTest

class CardNumberValidatorTests: XCTestCase {
    
    func testValidCards() {
        let validator = CardNumberValidator(isLuhnCheckEnabled: true, isEnteredBrandSupported: true)
        
        CardNumbers.valid.forEach { cardNumber in
            XCTAssertTrue(validator.isValid(cardNumber))
            XCTAssertTrue(validator.validate(cardNumber).isValid)
        }
    }
    
    func testInvalidCards() {
        let validator = CardNumberValidator(isLuhnCheckEnabled: true, isEnteredBrandSupported: true)
        
        CardNumbers.invalid.forEach { cardNumber in
            XCTAssertFalse(validator.isValid(cardNumber))
        }
    }
    
    func testMaxLength() {
        var validator = CardNumberValidator(isLuhnCheckEnabled: true, isEnteredBrandSupported: true)
        
        XCTAssertEqual(validator.maximumLength(for: ""), 19)
        XCTAssertEqual(validator.maximumLength(for: "124123124512"), 19)
        
        validator = CardNumberValidator(isLuhnCheckEnabled: true, isEnteredBrandSupported: true, panLength: 16)
        
        XCTAssertEqual(validator.maximumLength(for: ""), 16)
        XCTAssertEqual(validator.maximumLength(for: "124123124512"), 16)
    }
    
    func testUnsupportedCard() {
        let validator = CardNumberValidator(isLuhnCheckEnabled: true, isEnteredBrandSupported: false)
        
        CardNumbers.valid.forEach { XCTAssertFalse(validator.isValid($0)) }
    }
    
    func testNonLuhnCheckCards() {
        let validator = CardNumberValidator(isLuhnCheckEnabled: false, isEnteredBrandSupported: true)
        XCTAssertTrue(validator.isValid("4111111111111112"))
        XCTAssertTrue(validator.isValid("370000000000000"))
        XCTAssertFalse(validator.isValid("37000000000"))
        XCTAssertFalse(validator.isValid("0"))
    }
    
    func testUnsupportedValidationError() {
        let validator = CardNumberValidator(isLuhnCheckEnabled: true, isEnteredBrandSupported: false)
        let status = validator.validate("411111")
        let error = status.validationError
        XCTAssertNotNil(error)
        
        let validationError = error as? CardValidationError
        XCTAssertEqual(validationError, CardValidationError.cardUnsupported)
    }
    
    func testEmptyValidationError() {
        let validator = CardNumberValidator(isLuhnCheckEnabled: true, isEnteredBrandSupported: true)
        let status = validator.validate("")
        let error = status.validationError
        XCTAssertNotNil(error)
        
        let validationError = error as? CardValidationError
        XCTAssertEqual(validationError, CardValidationError.cardNumberEmpty)
    }
    
    func testPartialEmptyValidationError() {
        let validator = CardNumberValidator(isLuhnCheckEnabled: true, isEnteredBrandSupported: true)
        let status = validator.validate("4111")
        let error = status.validationError
        XCTAssertNotNil(error)
        
        let validationError = error as? CardValidationError
        XCTAssertEqual(validationError, CardValidationError.cardNumberPartial)
    }
    
    func testLuhnCheckValidationError() {
        let validator = CardNumberValidator(isLuhnCheckEnabled: true, isEnteredBrandSupported: true)
        let status = validator.validate("1111111111111")
        let error = status.validationError
        XCTAssertNotNil(error)
        
        let validationError = error as? CardValidationError
        XCTAssertEqual(validationError, CardValidationError.cardLuhCheckFailed)
    }
    
    func testValidCardLuhnCheckDisabled() {
        let validator = CardNumberValidator(isLuhnCheckEnabled: false, isEnteredBrandSupported: true)
        let status = validator.validate("4111111111111112")
        XCTAssertTrue(status.isValid)
    }
}
