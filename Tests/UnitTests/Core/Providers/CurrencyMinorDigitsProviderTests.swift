//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import XCTest

class CurrencyMinorDigitsProviderTests: XCTestCase {

    private var sut: AnyCurrencyMinorDigitsProvider!

    override func setUp() {
        super.setUp()
        sut = CurrencyMinorDigitsProvider()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testTwoDecimalCurrencies() {
        XCTAssertEqual(sut.minorDigits(for: "EUR"), 2)
        XCTAssertEqual(sut.minorDigits(for: "USD"), 2)
        XCTAssertEqual(sut.minorDigits(for: "GBP"), 2)
    }

    func testZeroDecimalCurrencies() {
        XCTAssertEqual(sut.minorDigits(for: "JPY"), 0)
        XCTAssertEqual(sut.minorDigits(for: "KRW"), 0)
        XCTAssertEqual(sut.minorDigits(for: "VND"), 0)
    }

    func testThreeDecimalCurrencies() {
        XCTAssertEqual(sut.minorDigits(for: "BHD"), 3)
        XCTAssertEqual(sut.minorDigits(for: "KWD"), 3)
        XCTAssertEqual(sut.minorDigits(for: "OMR"), 3)
    }

    func testCaseInsensitivity() {
        XCTAssertEqual(sut.minorDigits(for: "eur"), 2)
        XCTAssertEqual(sut.minorDigits(for: "jpy"), 0)
    }

    func testUnknownCurrencyFallsBackToDefault() {
        XCTAssertEqual(sut.minorDigits(for: "XXX"), CurrencyMinorDigitsProvider.defaultMinorDigits)
        XCTAssertEqual(sut.minorDigits(for: ""), CurrencyMinorDigitsProvider.defaultMinorDigits)
    }

    func testAllListedCurrenciesAreCovered() {
        for (currencyCode, expectedDigits) in CurrencyMinorDigitsProvider.minorDigitsByCurrencyCode {
            XCTAssertEqual(sut.minorDigits(for: currencyCode), expectedDigits)
        }
    }
}
