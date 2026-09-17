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

    /// Currencies that are not on Adyen's official currency list, but are still valid ISO 4217
    /// codes that this currency-agnostic provider may be called with.
    func testNonAdyenCurrencies() {
        XCTAssertEqual(sut.minorDigits(for: "CLF"), 4) // Chilean Unidad de Fomento
        XCTAssertEqual(sut.minorDigits(for: "UYW"), 4) // Uruguay Unidad Previsional
        XCTAssertEqual(sut.minorDigits(for: "UYI"), 0) // Uruguay Peso en Unidades Indexadas
        XCTAssertEqual(sut.minorDigits(for: "BIF"), 0) // Burundian Franc
        XCTAssertEqual(sut.minorDigits(for: "ADP"), 0) // Andorran Peseta (historical)
        XCTAssertEqual(sut.minorDigits(for: "BYR"), 0) // Belarusian Ruble (historical)
        XCTAssertEqual(sut.minorDigits(for: "ESP"), 0) // Spanish Peseta (historical)
        XCTAssertEqual(sut.minorDigits(for: "ITL"), 0) // Italian Lira (historical)
        XCTAssertEqual(sut.minorDigits(for: "MGF"), 0) // Malagasy Franc (historical)
        XCTAssertEqual(sut.minorDigits(for: "TRL"), 0) // Turkish Lira (historical)
    }
}
