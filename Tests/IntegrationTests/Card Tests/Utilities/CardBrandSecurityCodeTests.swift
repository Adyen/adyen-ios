//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenCard
import XCTest

class CardBrandSecurityCodeTests: XCTestCase {

    func test_expectedSecurityCodeLength_givenAmex_shouldReturnFour() {
        assert(brand: .americanExpress, expectedLength: 4)
    }

    func test_expectedSecurityCodeLength_givenNonAmex_shouldReturnThree() {
        assert(brand: .masterCard, expectedLength: 3)
    }

    func test_expectedSecurityCodeLength_givenNil_shouldReturnThree() {
        assert(brand: nil, expectedLength: 3)
    }

    func test_expectedSecurityCodeLength_givenConcreteAmexBrand_shouldReturnFour() {
        assert(concreteBrand: .americanExpress, expectedLength: 4)
    }

    func test_expectedSecurityCodeLength_givenConcreteNonAmexBrand_shouldReturnThree() {
        assert(concreteBrand: .masterCard, expectedLength: 3)
    }

    private func assert(
        brand: CardBrand?,
        expectedLength: Int,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(brand.expectedSecurityCodeLength, expectedLength, file: file, line: line)
    }

    private func assert(
        concreteBrand: CardBrand,
        expectedLength: Int,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(concreteBrand.expectedSecurityCodeLength, expectedLength, file: file, line: line)
    }
}
