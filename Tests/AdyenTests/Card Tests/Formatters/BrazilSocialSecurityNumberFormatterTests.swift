//
//  BrazilSocialSecurityNumberFormatterTests.swift
//  AdyenUIKitTests
//
//  Created by Eren Besel on 7/19/21.
//  Copyright © 2021 Adyen. All rights reserved.
//

@testable @_spi(AdyenInternal) import AdyenCard
import XCTest

class BrazilSocialSecurityNumberFormatterTests: XCTestCase {

    func testCPF() {
        let formatter = BrazilSocialSecurityNumberFormatter()
        
        XCTAssertEqual(formatter.formattedValue(for: "12345"), "123.45")
        XCTAssertEqual(formatter.formattedValue(for: "123456789"), "123.456.789")
        XCTAssertEqual(formatter.formattedValue(for: "1234567890"), "123.456.789-0")
        XCTAssertEqual(formatter.formattedValue(for: "12345678901"), "123.456.789-01")
    }
    
    func testCNPJ() {
        let formatter = BrazilSocialSecurityNumberFormatter()
        
        XCTAssertEqual(formatter.formattedValue(for: "12345"), "123.45")
        XCTAssertEqual(formatter.formattedValue(for: "123456789"), "123.456.789")
        XCTAssertEqual(formatter.formattedValue(for: "1234567890123"), "12.345.678/9012-3")
        XCTAssertEqual(formatter.formattedValue(for: "12345678901234"), "12.345.678/9012-34")
        XCTAssertEqual(formatter.formattedValue(for: "12345678901234567"), "12.345.678/9012-34")
        XCTAssertEqual(formatter.formattedValue(for: "123//4567//89-01234567"), "12.345.678/9012-34")
    }
    
    func testSanitizing() {
        let formatter = BrazilSocialSecurityNumberFormatter()
        
        XCTAssertEqual(formatter.sanitizedValue(for: "1234567890"), "1234567890")
        XCTAssertEqual(formatter.sanitizedValue(for: "3700 000000 00002"), "370000000000002")
        XCTAssertEqual(formatter.sanitizedValue(for: "12345678901234567"), "12345678901234567")
        XCTAssertEqual(formatter.sanitizedValue(for: "1a2b3c4!"), "1234")
    }

}
