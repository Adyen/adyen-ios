//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable @_spi(AdyenInternal) import AdyenCard
import XCTest

final class CardHolderNameValidatorTests: XCTestCase {

    func testValidNames() {
        let validator = CardHolderNameValidator()
        
        XCTAssertTrue(validator.isValid("abc"))
        XCTAssertTrue(validator.isValid("test name 123 ,.;[]'."))
        XCTAssertTrue(validator.isValid("holder name longer"))
        XCTAssertTrue(validator.isValid("a"))
        XCTAssertTrue(validator.isValid("holder name longer holder name test"))
        
        let status = validator.validate("123")
        
        XCTAssertNil(status.validationError)
        XCTAssertTrue(status.isValid)
    }
    
    func testInvalidNames() {
        let validator = CardHolderNameValidator()
        
        XCTAssertFalse(validator.isValid(""))
        
        let status = validator.validate("")
        XCTAssertNotNil(status.validationError)
        
        let validationError = status.validationError as? CardValidationError
        XCTAssertEqual(validationError, .holderNameEmpty)
        XCTAssertEqual(validationError?.analyticsErrorCode, AnalyticsConstants.ValidationErrorCodes.holderNameEmpty)
    }

}
