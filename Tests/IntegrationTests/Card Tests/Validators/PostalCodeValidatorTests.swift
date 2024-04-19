//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import XCTest

final class PostalCodeValidatorTests: XCTestCase {

    func testValidCodes() {
        let validator = PostalCodeValidator(minimumLength: 2, maximumLength: 10)
        
        XCTAssertTrue(validator.isValid("10"))
        XCTAssertTrue(validator.isValid("10HB"))
        XCTAssertTrue(validator.isValid("1053PP"))
        XCTAssertTrue(validator.isValid("BH 10"))
        XCTAssertTrue(validator.isValid("NY 955"))
        
        let status = validator.validate("1045 GZ")
        XCTAssertNil(status.validationError)
        XCTAssertTrue(status.isValid)
    }
    
    func testEmptyInvalidCodes() {
        let validator = PostalCodeValidator(minimumLength: 2, maximumLength: 10)
        let status = validator.validate("")
        
        XCTAssertNotNil(status.validationError)
        let validationError = status.validationError as? AddressAnalyticsValidationError
        XCTAssertEqual(validationError, .postalCodeEmpty)
    }
    
    func testPartialInvalidCodes() {
        let validator = PostalCodeValidator(minimumLength: 3, maximumLength: 10)
        var status = validator.validate("B")
        
        XCTAssertNotNil(status.validationError)
        var validationError = status.validationError as? AddressAnalyticsValidationError
        XCTAssertEqual(validationError, .postalCodePartial)
        
        status = validator.validate("11")
        XCTAssertNotNil(status.validationError)
        validationError = status.validationError as? AddressAnalyticsValidationError
        XCTAssertEqual(validationError, .postalCodePartial)
    }

}
