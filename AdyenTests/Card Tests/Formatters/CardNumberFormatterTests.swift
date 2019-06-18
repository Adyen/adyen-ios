//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenCard
import XCTest

class CardNumberFormatterTests: XCTestCase {
    
    func testFormatting() {
        let formatter = CardNumberFormatter()
        
        XCTAssertEqual(formatter.formattedValue(for: "12345"), "1234 5")
        XCTAssertEqual(formatter.formattedValue(for: "123456789"), "1234 5678 9")
        XCTAssertEqual(formatter.formattedValue(for: "4444444444444444"), "4444 4444 4444 4444")
        XCTAssertEqual(formatter.formattedValue(for: "44444444444444449999"), "4444 4444 4444 4444 9999")
    }
    
    func testAmexFormatting() {
        let formatter = CardNumberFormatter()
        formatter.cardType = CardType.americanExpress
        
        XCTAssertEqual(formatter.formattedValue(for: "37000"), "3700 0")
        XCTAssertEqual(formatter.formattedValue(for: "37000000000"), "3700 000000 0")
        XCTAssertEqual(formatter.formattedValue(for: "370000000000002"), "3700 000000 00002")
        XCTAssertEqual(formatter.formattedValue(for: "3700000000000024444"), "3700 000000 00002")
    }
    
    func testSanitizing() {
        let formatter = CardNumberFormatter()
        
        XCTAssertEqual(formatter.sanitizedValue(for: "4444 4444 4444 4444"), "4444444444444444")
        XCTAssertEqual(formatter.sanitizedValue(for: "3700 000000 00002"), "370000000000002")
        XCTAssertEqual(formatter.sanitizedValue(for: "4444 4444 4444 4444 999"), "4444444444444444999")
        XCTAssertEqual(formatter.sanitizedValue(for: "1a2b3c4!"), "1234")
    }
}
