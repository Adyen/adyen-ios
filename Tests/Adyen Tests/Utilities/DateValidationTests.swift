//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

@testable import Adyen
import XCTest

class DateValidationTests: XCTestCase {

    func testValidation() {
        XCTAssertTrue(validate("891025", format: DateValidator.Format.kcpFormat))
        XCTAssertFalse(validate("89102", format: DateValidator.Format.kcpFormat))

        XCTAssertTrue(validate("1989-10-25", format: "yyyy-MM-dd"))
        XCTAssertFalse(validate("89-10-25", format: "yyyy-MM-dd"))

        XCTAssertTrue(testMaximumLength("891025", format: DateValidator.Format.kcpFormat))
        XCTAssertTrue(testMaximumLength("1989-10-25", format: "yyyy-MM-dd"))
        XCTAssertFalse(testMaximumLength("89-10-25", format: "yyyy-MM-dd"))
    }

    func validate(_ string: String, format: DateValidator.Format) -> Bool {
        DateValidator(format: format).isValid(string)
    }

    func validate(_ string: String, format: String) -> Bool {
        DateValidator(format: format).isValid(string)
    }

    func testMaximumLength(_ string: String, format: DateValidator.Format) -> Bool {
        string.count == DateValidator(format: format).maximumLength(for: string)
    }

    func testMaximumLength(_ string: String, format: String) -> Bool {
        string.count == DateValidator(format: format).maximumLength(for: string)
    }

}
