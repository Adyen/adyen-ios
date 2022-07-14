//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import XCTest

class LengthValidatorTests: XCTestCase {
    
    func testValidation() {
        XCTAssertTrue(validate("Hello World", minimumLength: 2))
        XCTAssertTrue(validate("Hello World", minimumLength: 2, maximumLength: 12))
        XCTAssertTrue(validate("", maximumLength: 10))
        XCTAssertFalse(validate("Hello World", minimumLength: 12))
        XCTAssertFalse(validate("Hello World", maximumLength: 10))
        XCTAssertFalse(validate("Hello World", minimumLength: 12, maximumLength: 24))

        XCTAssertTrue(validate("Hello World", exactLength: 11))
        XCTAssertFalse(validate("Hello World", exactLength: 9))
        
        XCTAssertTrue(testMaximumLength("1234", maximumLength: 4))
        XCTAssertFalse(testMaximumLength("1234", maximumLength: nil))
        XCTAssertFalse(testMaximumLength("12345", maximumLength: 4))
        XCTAssertFalse(testMaximumLength("12", maximumLength: 4))
    }
    
    func validate(_ string: String, minimumLength: Int? = nil, maximumLength: Int? = nil) -> Bool {
        LengthValidator(minimumLength: minimumLength, maximumLength: maximumLength).isValid(string)
    }

    func validate(_ string: String, exactLength: Int) -> Bool {
        LengthValidator(exactLength: exactLength).isValid(string)
    }
    
    func testMaximumLength(_ string: String, maximumLength: Int?) -> Bool {
        string.count == LengthValidator(maximumLength: maximumLength).maximumLength(for: string)
    }
    
}
