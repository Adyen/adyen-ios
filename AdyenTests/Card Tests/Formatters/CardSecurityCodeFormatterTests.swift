//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenCard
import XCTest

class CardSecurityCodeFormatterTests: XCTestCase {
    
    func testFormatting() {
        let formatter = CardSecurityCodeFormatter()
        
        XCTAssertEqual(formatter.formattedValue(for: "1"), "1")
        XCTAssertEqual(formatter.formattedValue(for: "12345"), "12345")
        XCTAssertEqual(formatter.formattedValue(for: "101abc"), "101")
    }
    
    func testSanitizing() {
        let formatter = CardSecurityCodeFormatter()
        
        XCTAssertEqual(formatter.sanitizedValue(for: "1"), "1")
        XCTAssertEqual(formatter.sanitizedValue(for: "1a2b"), "12")
        XCTAssertEqual(formatter.sanitizedValue(for: "12--"), "12")
        XCTAssertEqual(formatter.sanitizedValue(for: "123456"), "123456")
    }
}
