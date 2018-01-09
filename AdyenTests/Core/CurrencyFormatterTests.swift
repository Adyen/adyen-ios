//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest
@testable import Adyen

class CurrencyFormatterTests: XCTestCase {
    
    func testCurrencyFormatWithEUR() {
        let expected = "€103.47"
        let formatted = CurrencyFormatter.format(10347, currencyCode: "EUR")
        
        XCTAssertEqual(formatted, expected)
    }
    
    func testCurrencyFormatWithEURAndLargeAmount() {
        let expected = "€90,331.47"
        let formatted = CurrencyFormatter.format(9033147, currencyCode: "EUR")
        
        XCTAssertEqual(formatted, expected)
    }
    
    func testCurrencyFormatWithUSD() {
        let expected = "$103.47"
        let formatted = CurrencyFormatter.format(10347, currencyCode: "USD")
        
        XCTAssertEqual(formatted, expected)
    }
    
    func testCurrencyFormatWithUSDAndLargeAmount() {
        let expected = "$90,331.47"
        let formatted = CurrencyFormatter.format(9033147, currencyCode: "USD")
        
        XCTAssertEqual(formatted, expected)
    }
    
    func testCurrencyFormatWithBRLAndLargeAmount() {
        let expected = "R$90,331.47"
        let formatted = CurrencyFormatter.format(9033147, currencyCode: "BRL")
        
        XCTAssertEqual(formatted, expected)
    }
}
