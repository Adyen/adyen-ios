//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable @_spi(AdyenInternal) import AdyenCard
import XCTest

final class CardKCPValidatorsTests: XCTestCase {

    func testValidBirthDate() {
        let validator = CardKCPFieldValidator()
        
        XCTAssertTrue(validator.isValid("110523"))
        XCTAssertTrue(validator.isValid("880523"))
        XCTAssertTrue(validator.isValid("330518"))
        XCTAssertTrue(validator.isValid("440523"))
        XCTAssertTrue(validator.isValid("680523"))
        XCTAssertTrue(validator.isValid("050523"))
        
        let status = validator.validate("110205")
        XCTAssertNil(status.validationError)
        XCTAssertTrue(status.isValid)
    }
    
    func testValidCorporateNumber() {
        let validator = CardKCPFieldValidator()
        
        XCTAssertTrue(validator.isValid("1234567890"))
        XCTAssertTrue(validator.isValid("3344556689"))
        
        let status = validator.validate("3456789012")
        XCTAssertNil(status.validationError)
        XCTAssertTrue(status.isValid)
    }
    
    func testEmptyInvalidField() {
        let validator = CardKCPFieldValidator()
        let status = validator.validate("")
        
        XCTAssertNotNil(status.validationError)
        let validationError = status.validationError as? CardValidationError
        XCTAssertEqual(validationError, .kcpFieldEmpty)
    }
    
    func testPartialInvalidField() {
        let validator = CardKCPFieldValidator()
        var status = validator.validate("123")
        
        XCTAssertNotNil(status.validationError)
        var validationError = status.validationError as? CardValidationError
        XCTAssertEqual(validationError, .kcpFieldPartial)
        
        status = validator.validate("1234567")
        validationError = status.validationError as? CardValidationError
        XCTAssertEqual(validationError, .kcpFieldPartial)
        
        status = validator.validate("123456789012")
        validationError = status.validationError as? CardValidationError
        XCTAssertEqual(validationError, .kcpFieldPartial)
    }
    
    func testValidPassword() {
        let validator = CardKCPPasswordValidator()
        
        XCTAssertTrue(validator.isValid("12"))
        XCTAssertTrue(validator.isValid("33"))
        XCTAssertTrue(validator.isValid("68"))
        
        let status = validator.validate("23")
        XCTAssertNil(status.validationError)
        XCTAssertTrue(status.isValid)
    }
    
    func testEmptyInvalidPassword() {
        let validator = CardKCPPasswordValidator()
        let status = validator.validate("")
        
        XCTAssertNotNil(status.validationError)
        let validationError = status.validationError as? CardValidationError
        XCTAssertEqual(validationError, .kcpPasswordEmpty)
    }
    
    func testPartialInvalidPassword() {
        let validator = CardKCPPasswordValidator()
        let status = validator.validate("1")
        
        XCTAssertNotNil(status.validationError)
        let validationError = status.validationError as? CardValidationError
        XCTAssertEqual(validationError, .kcpPasswordPartial)
    }

}
