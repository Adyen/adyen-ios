//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenCard
import XCTest

class CardBrandSecurityCodeTests: XCTestCase {

    func testExpectedSecurityCodeLengthGivenAmexShouldReturnFour() {
        assert(brand: .americanExpress, expectedLength: 4)
    }

    func testExpectedSecurityCodeLengthGivenNonAmexShouldReturnThree() {
        assert(brand: .masterCard, expectedLength: 3)
    }

    func testExpectedSecurityCodeLengthGivenNilShouldReturnThree() {
        assert(brand: nil, expectedLength: 3)
    }

    private func assert(
        brand: CardBrand?,
        expectedLength: Int,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(brand.expectedSecurityCodeLength, expectedLength, file: file, line: line)
    }
}
