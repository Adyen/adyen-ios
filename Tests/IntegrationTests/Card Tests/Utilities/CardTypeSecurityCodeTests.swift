//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenCard
import XCTest

class CardTypeSecurityCodeTests: XCTestCase {

    func test_expectedSecurityCodeLength_givenAmex_shouldReturnFour() {
        assert(cardType: .americanExpress, expectedLength: 4)
    }

    func test_expectedSecurityCodeLength_givenNonAmex_shouldReturnThree() {
        assert(cardType: .masterCard, expectedLength: 3)
    }

    func test_expectedSecurityCodeLength_givenNil_shouldReturnThree() {
        assert(cardType: nil, expectedLength: 3)
    }

    func test_expectedSecurityCodeLength_givenConcreteAmexCardType_shouldReturnFour() {
        assert(concreteCardType: .americanExpress, expectedLength: 4)
    }

    func test_expectedSecurityCodeLength_givenConcreteNonAmexCardType_shouldReturnThree() {
        assert(concreteCardType: .masterCard, expectedLength: 3)
    }

    private func assert(
        cardType: CardType?,
        expectedLength: Int,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(cardType.expectedSecurityCodeLength, expectedLength, file: file, line: line)
    }

    private func assert(
        concreteCardType: CardType,
        expectedLength: Int,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(concreteCardType.expectedSecurityCodeLength, expectedLength, file: file, line: line)
    }
}
