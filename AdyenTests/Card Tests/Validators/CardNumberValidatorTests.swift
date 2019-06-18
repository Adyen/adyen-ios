//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenCard
import XCTest

class CardNumberValidatorTests: XCTestCase {
    
    func testValidCards() {
        let validator = CardNumberValidator()
        
        CardNumbers.valid.forEach { cardNumber in
            XCTAssertTrue(validator.isValid(cardNumber))
        }
    }
    
    func testInvalidCards() {
        let validator = CardNumberValidator()
        
        CardNumbers.invalid.forEach { cardNumber in
            XCTAssertFalse(validator.isValid(cardNumber))
        }
    }
}
