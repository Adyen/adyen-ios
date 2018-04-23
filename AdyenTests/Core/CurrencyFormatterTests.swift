//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest
@testable import Adyen

class AmountFormatterTests: XCTestCase {
    
    func testAmountFormatWithEUR() {
        let expected = "€103.47"
        let formatted = AmountFormatter.formatted(amount: 10347, currencyCode: "EUR")
        
        XCTAssertEqual(formatted, expected)
    }
    
    func testAmountFormatWithEURAndLargeAmount() {
        let expected = "€90,331.47"
        let formatted = AmountFormatter.formatted(amount: 9033147, currencyCode: "EUR")
        
        XCTAssertEqual(formatted, expected)
    }
    
    func testAmountFormatWithUSD() {
        let expected = "$103.47"
        let formatted = AmountFormatter.formatted(amount: 10347, currencyCode: "USD")
        
        XCTAssertEqual(formatted, expected)
    }
    
    func testAmountFormatWithUSDAndLargeAmount() {
        let expected = "$90,331.47"
        let formatted = AmountFormatter.formatted(amount: 9033147, currencyCode: "USD")
        
        XCTAssertEqual(formatted, expected)
    }
    
    func testAmountFormatWithBRLAndLargeAmount() {
        let expected = "R$90,331.47"
        let formatted = AmountFormatter.formatted(amount: 9033147, currencyCode: "BRL")
        
        XCTAssertEqual(formatted, expected)
    }
}
