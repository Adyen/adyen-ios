//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenCard
import XCTest

class CardSecurityCodeFormatterTests: XCTestCase {
    
    func testFormatting() {
        let observer = AdyenObservable<CardType?>(.masterCard)
        let formatter = CardSecurityCodeFormatter(publisher: observer)
        XCTAssertEqual(formatter.formattedValue(for: "1"), "1")
        XCTAssertEqual(formatter.formattedValue(for: "101abc"), "101")
        XCTAssertEqual(formatter.formattedValue(for: "12345"), "123")
        
        observer.wrappedValue = nil
        XCTAssertEqual(formatter.formattedValue(for: "1"), "1")
        XCTAssertEqual(formatter.formattedValue(for: "101abc"), "101")
        XCTAssertEqual(formatter.formattedValue(for: "12345"), "123")
        
        observer.wrappedValue = .americanExpress
        XCTAssertEqual(formatter.formattedValue(for: "12345"), "1234")
    }
    
    func testSanitizing() {
        let formatter = CardSecurityCodeFormatter()
        
        XCTAssertEqual(formatter.sanitizedValue(for: "1"), "1")
        XCTAssertEqual(formatter.sanitizedValue(for: "1a2b"), "12")
        XCTAssertEqual(formatter.sanitizedValue(for: "12--"), "12")
        XCTAssertEqual(formatter.sanitizedValue(for: "123456"), "123456")
    }
}
