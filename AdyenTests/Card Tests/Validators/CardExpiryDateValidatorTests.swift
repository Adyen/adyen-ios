//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenCard
import XCTest

class CardExpiryDateValidatorTests: XCTestCase {
    
    func testValidExpiryDates() {
        let validator = CardExpiryDateValidator()
        
        XCTAssertTrue(validator.isValid("1020"))
        XCTAssertTrue(validator.isValid("0820"))
        XCTAssertTrue(validator.isValid("0121"))
    }
    
    func testInvalidExpiryDates() {
        let validator = CardExpiryDateValidator()
        
        XCTAssertFalse(validator.isValid(""))
        XCTAssertFalse(validator.isValid("1"))
        XCTAssertFalse(validator.isValid("12"))
        XCTAssertFalse(validator.isValid("12345"))
        XCTAssertFalse(validator.isValid("0817"))
        XCTAssertFalse(validator.isValid("1320"))
        XCTAssertFalse(validator.isValid("0020"))
    }
    
}
