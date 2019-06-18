//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
import XCTest

class IBANFormatterTests: XCTestCase {
    
    func testFormatting() {
        let formatter = IBANFormatter()
        XCTAssertEqual(formatter.formattedValue(for: "NL13TEST0123456789"), "NL13 TEST 0123 4567 89")
        XCTAssertEqual(formatter.formattedValue(for: "DE87123456781234567890"), "DE87 1234 5678 1234 5678 90")
        XCTAssertEqual(formatter.formattedValue(for: "IT60X0542811101000000123456"), "IT60 X054 2811 1010 0000 0123 456")
        XCTAssertEqual(formatter.formattedValue(for: "FR1420041010050500013M02606"), "FR14 2004 1010 0505 0001 3M02 606")
        XCTAssertEqual(formatter.formattedValue(for: "ES9121000418450200051332"), "ES91 2100 0418 4502 0005 1332")
        XCTAssertEqual(formatter.formattedValue(for: "AT151234512345678901"), "AT15 1234 5123 4567 8901")
        XCTAssertEqual(formatter.formattedValue(for: "CH4912345123456789012"), "CH49 1234 5123 4567 8901 2")
        XCTAssertEqual(formatter.formattedValue(for: "DK8612341234567890"), "DK86 1234 1234 5678 90")
        XCTAssertEqual(formatter.formattedValue(for: "NO6012341234561"), "NO60 1234 1234 561")
        XCTAssertEqual(formatter.formattedValue(for: "PL20123123411234567890123456"), "PL20 1231 2341 1234 5678 9012 3456")
        XCTAssertEqual(formatter.formattedValue(for: "SE9412312345678901234561"), "SE94 1231 2345 6789 0123 4561")
        
        XCTAssertEqual(formatter.formattedValue(for: "nl36test 0236169114"), "NL36 TEST 0236 1691 14")
        XCTAssertEqual(formatter.formattedValue(for: "NL 82 test 0836169255"), "NL82 TEST 0836 1692 55")
        XCTAssertEqual(formatter.formattedValue(for: " DE94 8888 8888 9876 5432 10"), "DE94 8888 8888 9876 5432 10")
        XCTAssertEqual(formatter.formattedValue(for: "it60 x054 2811 1010 0000 0123 456"), "IT60 X054 2811 1010 0000 0123 456")
        XCTAssertEqual(formatter.formattedValue(for: "%FR1420041010050500013M02606%"), "FR14 2004 1010 0505 0001 3M02 606")
        XCTAssertEqual(formatter.formattedValue(for: "ES9121000418450200051332"), "ES91 2100 0418 4502 0005 1332")
        XCTAssertEqual(formatter.formattedValue(for: "D K 8 6 1 2 3 4 1 2 3 4 5 6 7 8 9 0 "), "DK86 1234 1234 5678 90")
    }
    
    func testSanitizing() {
        let formatter = IBANFormatter()
        XCTAssertEqual(formatter.sanitizedValue(for: "NL13 TEST 0123 4567 89"), "NL13TEST0123456789")
        XCTAssertEqual(formatter.sanitizedValue(for: "DE87 1234 5678 1234 5678 90"), "DE87123456781234567890")
        XCTAssertEqual(formatter.sanitizedValue(for: "IT60 X054 2811 1010 0000 0123 456"), "IT60X0542811101000000123456")
        XCTAssertEqual(formatter.sanitizedValue(for: "FR14 2004 1010 0505 0001 3M02 606"), "FR1420041010050500013M02606")
        XCTAssertEqual(formatter.sanitizedValue(for: "ES91 2100 0418 4502 0005 1332"), "ES9121000418450200051332")
        XCTAssertEqual(formatter.sanitizedValue(for: "AT15 1234 5123 4567 8901"), "AT151234512345678901")
        XCTAssertEqual(formatter.sanitizedValue(for: "CH49 1234 5123 4567 8901 2"), "CH4912345123456789012")
        XCTAssertEqual(formatter.sanitizedValue(for: "DK86 1234 1234 5678 90"), "DK8612341234567890")
        XCTAssertEqual(formatter.sanitizedValue(for: "NO60 1234 1234 561"), "NO6012341234561")
        XCTAssertEqual(formatter.sanitizedValue(for: "PL20 1231 2341 1234 5678 9012 3456"), "PL20123123411234567890123456")
        XCTAssertEqual(formatter.sanitizedValue(for: "SE94 1231 2345 6789 0123 4561"), "SE9412312345678901234561")
        
        XCTAssertEqual(formatter.sanitizedValue(for: "nl36test 0236169114"), "NL36TEST0236169114")
        XCTAssertEqual(formatter.sanitizedValue(for: "NL 82 test 0836169255"), "NL82TEST0836169255")
        XCTAssertEqual(formatter.sanitizedValue(for: " DE94 8888 8888 9876 5432 10"), "DE94888888889876543210")
        XCTAssertEqual(formatter.sanitizedValue(for: "it60 x054 2811 1010 0000 0123 456"), "IT60X0542811101000000123456")
        XCTAssertEqual(formatter.sanitizedValue(for: "%FR1420041010050500013M02606%"), "FR1420041010050500013M02606")
        XCTAssertEqual(formatter.sanitizedValue(for: "ES9121000418450200051332"), "ES9121000418450200051332")
        XCTAssertEqual(formatter.sanitizedValue(for: "D K 8 6 1 2 3 4 1 2 3 4 5 6 7 8 9 0 "), "DK8612341234567890")
    }
    
}
