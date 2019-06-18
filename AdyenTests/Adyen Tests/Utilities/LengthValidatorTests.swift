//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
import XCTest

class LengthValidatorTests: XCTestCase {
    
    func testValidation() {
        XCTAssertTrue(validate("Hello World", minimumLength: 2))
        XCTAssertTrue(validate("Hello World", minimumLength: 2, maximumLenght: 12))
        XCTAssertTrue(validate("", maximumLenght: 10))
        XCTAssertFalse(validate("Hello World", minimumLength: 12))
        XCTAssertFalse(validate("Hello World", maximumLenght: 10))
        XCTAssertFalse(validate("Hello World", minimumLength: 12, maximumLenght: 24))
        
        XCTAssertTrue(testMaximumLength("1234", maximumLength: 4))
        XCTAssertFalse(testMaximumLength("1234", maximumLength: nil))
        XCTAssertFalse(testMaximumLength("12345", maximumLength: 4))
        XCTAssertFalse(testMaximumLength("12", maximumLength: 4))
    }
    
    func validate(_ string: String, minimumLength: Int? = nil, maximumLenght: Int? = nil) -> Bool {
        return LengthValidator(minimumLength: minimumLength, maximumLength: maximumLenght).isValid(string)
    }
    
    func testMaximumLength(_ string: String, maximumLength: Int?) -> Bool {
        return string.count == LengthValidator(maximumLength: maximumLength).maximumLength(for: string)
    }
    
}
