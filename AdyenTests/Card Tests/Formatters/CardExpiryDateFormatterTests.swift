//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenCard
import XCTest

class CardExpiryDateFormatterTests: XCTestCase {
    
    func testFormatting() {
        let formatter = CardExpiryDateFormatter()
        
        XCTAssertEqual(formatter.formattedValue(for: "1"), "1")
        XCTAssertEqual(formatter.formattedValue(for: "10"), "10")
        XCTAssertEqual(formatter.formattedValue(for: "101"), "10 / 1")
        XCTAssertEqual(formatter.formattedValue(for: "9"), "09")
        XCTAssertEqual(formatter.formattedValue(for: "092"), "09 / 2")
        XCTAssertEqual(formatter.formattedValue(for: "0921"), "09 / 21")
    }
    
    func testSanitizing() {
        let formatter = CardExpiryDateFormatter()
        
        XCTAssertEqual(formatter.sanitizedValue(for: "1"), "1")
        XCTAssertEqual(formatter.sanitizedValue(for: "10 / 1"), "101")
        XCTAssertEqual(formatter.sanitizedValue(for: "09 / 21"), "0921")
    }
}
