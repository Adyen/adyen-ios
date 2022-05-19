//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable @_spi(AdyenInternal) import AdyenCard
import XCTest

class CardExpiryDateFormatterTests: XCTestCase {
    
    private var sut: CardExpiryDateFormatter!
    
    override func setUp() {
        super.setUp()
        
        sut = CardExpiryDateFormatter()
    }
    
    override func tearDown() {
        super.tearDown()
        
        sut = nil
    }
    
    func testFormatting() {
        XCTAssertEqual(sut.formattedValue(for: "0"), "0")
        XCTAssertEqual(sut.formattedValue(for: "1"), "1")
        XCTAssertEqual(sut.formattedValue(for: "01"), "01 / ")
        XCTAssertEqual(sut.formattedValue(for: "10"), "10 / ")
        XCTAssertEqual(sut.formattedValue(for: "101"), "10 / 1")
        XCTAssertEqual(sut.formattedValue(for: "9"), "09 / ")
        
        XCTAssertEqual(sut.formattedValue(for: "092"), "09 / 2")
        XCTAssertEqual(sut.formattedValue(for: "0921"), "09 / 21")
        
        XCTAssertEqual(sut.formattedValue(for: "12 / 3"), "12 / 3")
        XCTAssertEqual(sut.formattedValue(for: "12 / "), "12 / ")
        XCTAssertEqual(sut.formattedValue(for: "12 / a"), "12 / ")
        XCTAssertEqual(sut.formattedValue(for: "12 /"), "12")
        
        // Invalid months.
        XCTAssertEqual(sut.formattedValue(for: "00"), "")
        XCTAssertEqual(sut.formattedValue(for: "13"), "")
        XCTAssertEqual(sut.formattedValue(for: "92"), "")
        XCTAssertEqual(sut.formattedValue(for: "a"), "")
        XCTAssertEqual(sut.formattedValue(for: "="), "")
        XCTAssertEqual(sut.formattedValue(for: " "), "")
        XCTAssertEqual(sut.formattedValue(for: "1 "), "1")
    }
    
    func testNonLatinFormatting() {
        
        // Indo-Arabic numerals supported
        XCTAssertEqual(sut.formattedValue(for: "٠"), "0")
        XCTAssertEqual(sut.formattedValue(for: "١"), "1")
        XCTAssertEqual(sut.formattedValue(for: "٢"), "02 / ")
        XCTAssertEqual(sut.formattedValue(for: "١١ / ٢٣"), "11 / 23")
        
        XCTAssertEqual(sut.formattedValue(for: "০"), "0")
        XCTAssertEqual(sut.formattedValue(for: "১"), "1")
        XCTAssertEqual(sut.formattedValue(for: "২"), "02 / ")
        XCTAssertEqual(sut.formattedValue(for: "১১ / ২৩"), "11 / 23")
        
        XCTAssertEqual(sut.formattedValue(for: "०"), "0")
        XCTAssertEqual(sut.formattedValue(for: "१"), "1")
        XCTAssertEqual(sut.formattedValue(for: "२"), "02 / ")
        XCTAssertEqual(sut.formattedValue(for: "११ / २३"), "11 / 23")
    }
    
    func testSanitizing() {
        XCTAssertEqual(sut.sanitizedValue(for: "1"), "1")
        XCTAssertEqual(sut.sanitizedValue(for: "01"), "01")
        XCTAssertEqual(sut.sanitizedValue(for: "01 / "), "01")
        XCTAssertEqual(sut.sanitizedValue(for: "09 / "), "09")
        XCTAssertEqual(sut.sanitizedValue(for: "10 / 1"), "101")
        XCTAssertEqual(sut.sanitizedValue(for: "09 / 21"), "0921")
    }
    
    func testNonDecimalDigitSanitizing() {
        XCTAssertEqual(sut.formattedValue(for: "🙈"), "")
        XCTAssertEqual(sut.formattedValue(for: "ā"), "")
        XCTAssertEqual(sut.formattedValue(for: "えふぇ"), "")
        XCTAssertEqual(sut.formattedValue(for: "ص"), "")
        XCTAssertEqual(sut.formattedValue(for: "אגכ"), "")
        XCTAssertEqual(sut.formattedValue(for: "אāכ🙈"), "")
    }
    
    func testNonLatinSanitizing() {
        
        // Hebrew numerals not supported
        XCTAssertEqual(sut.sanitizedValue(for: "י"), "")
        XCTAssertEqual(sut.sanitizedValue(for: "כ"), "")
        XCTAssertEqual(sut.sanitizedValue(for: "ל"), "")
        
        // Chinese numerals not supported
        XCTAssertEqual(sut.sanitizedValue(for: "〇"), "")
        XCTAssertEqual(sut.sanitizedValue(for: "一"), "")
        XCTAssertEqual(sut.sanitizedValue(for: "二"), "")
        
        // DOUBLE-STRUCK and MATHEMATICAL digits not supported
        XCTAssertEqual(sut.sanitizedValue(for: "₀"), "")
        XCTAssertEqual(sut.sanitizedValue(for: "𝟙"), "")
        XCTAssertEqual(sut.sanitizedValue(for: "𝟭"), "")
    }
}
