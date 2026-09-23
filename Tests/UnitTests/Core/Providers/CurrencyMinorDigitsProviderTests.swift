//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import XCTest

class CurrencyMinorDigitsProviderTests: XCTestCase {

    private let sut: AnyCurrencyMinorDigitsProvider = CurrencyMinorDigitsProvider()

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

    func testAllListedCurrenciesAreCovered() {
        for (currencyCode, expectedDigits) in CurrencyMinorDigitsProvider.minorDigitsByCurrencyCode {
            XCTAssertEqual(sut.minorDigits(for: currencyCode), expectedDigits)
        }
    }

    /// Currencies that are not on Adyen's official currency list, but are still valid ISO 4217
    /// codes that this currency-agnostic provider may be called with. These are no longer
    /// hardcoded in ``CurrencyMinorDigitsProvider/minorDigitsByCurrencyCode`` - instead, they are
    /// resolved via the system's ICU/CLDR currency data, which already reports the correct values.
    func testICUFallbackForNonAdyenCurrencies() {
        XCTAssertEqual(sut.minorDigits(for: "CLF"), 4) // Chilean Unidad de Fomento
        XCTAssertEqual(sut.minorDigits(for: "UYW"), 4) // Uruguay Unidad Previsional
        XCTAssertEqual(sut.minorDigits(for: "UYI"), 0) // Uruguay Peso en Unidades Indexadas
        XCTAssertEqual(sut.minorDigits(for: "BIF"), 0) // Burundian Franc
    }
}
