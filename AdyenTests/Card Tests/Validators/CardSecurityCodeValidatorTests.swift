//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenCard
import XCTest

class CardSecurityCodeValidatorTests: XCTestCase {
    
    func testValidSecurityCodes() {
        let validator = CardSecurityCodeValidator()
        
        XCTAssertTrue(validator.isValid("123"))
        XCTAssertTrue(validator.isValid("1234"))
    }
    
    func testInvalidSecurityCodes() {
        let validator = CardSecurityCodeValidator()
        
        XCTAssertFalse(validator.isValid(""))
        XCTAssertFalse(validator.isValid("1"))
        XCTAssertFalse(validator.isValid("12"))
        XCTAssertFalse(validator.isValid("12345"))
        XCTAssertFalse(validator.isValid("12c"))
        XCTAssertFalse(validator.isValid("abc"))
    }
    
}
