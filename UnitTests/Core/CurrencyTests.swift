//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest
@testable import Adyen

class CurrencyTests: XCTestCase {
    
    func testCurrencyFormatWithEUR() {
        let expected = "€103.47"
        let formatted = Currency.formatted(amount: 10347, currency: "EUR")
        
        XCTAssertEqual(formatted, expected)
    }
    
    func testCurrencyFormatWithEURAndLargeAmount() {
        let expected = "€90,331.47"
        let formatted = Currency.formatted(amount: 9033147, currency: "EUR")
        
        XCTAssertEqual(formatted, expected)
    }
    
    func testCurrencyFormatWithUSD() {
        let expected = "$103.47"
        let formatted = Currency.formatted(amount: 10347, currency: "USD")
        
        XCTAssertEqual(formatted, expected)
    }
    
    func testCurrencyFormatWithUSDAndLargeAmount() {
        let expected = "$90,331.47"
        let formatted = Currency.formatted(amount: 9033147, currency: "USD")
        
        XCTAssertEqual(formatted, expected)
    }
    
    func testCurrencyFormatWithBRLAndLargeAmount() {
        let expected = "R$90,331.47"
        let formatted = Currency.formatted(amount: 9033147, currency: "BRL")
        
        XCTAssertEqual(formatted, expected)
    }
}
