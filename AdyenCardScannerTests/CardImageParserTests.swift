//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenCardScanner
import XCTest


final class CardImageParserTests: XCTestCase {

    var sut: CardImageParser!

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testParseImageWithCreditCardOne() throws {
        // Given
        let expirationDateFormatter = ExpirationDateFormatter()
        sut = CardImageParser(expirationDateFormatter: expirationDateFormatter)

        let testCreditCard = try XCTUnwrap(testCreditCardOne)
        let expectation = expectation(description: "Image should be parsed")

        // When
        sut.parse(image: testCreditCard.image) { receivedCreditCard in
            expectation.fulfill()

            let expectedCreditCard = testCreditCard.creditCard
            XCTAssertEqual(expectedCreditCard.number, receivedCreditCard.number)
            XCTAssertEqual(expectedCreditCard.expirationDate, receivedCreditCard.expirationDate)
        }

        // Then
        waitForExpectations(timeout: 10.0)
    }

    // MARK: - Private

    private struct TestCreditCard {
        let image: CIImage
        let creditCard: CreditCard
    }

    private var testCreditCardOne: TestCreditCard? {
        let image = UIImage(
            named: "test-card-number-1",
            in: Bundle(for: type(of: self)),
            compatibleWith: nil
        )
        guard let cgImage = image?.cgImage else { return nil }
        let originalImage = CIImage(cgImage: cgImage)

        let creditCard = CreditCard(
            number: "4111110003920001",
            expirationDate: dateFrom("03/30")
        )
        return TestCreditCard(
            image: originalImage,
            creditCard: creditCard
        )
    }

    private func dateFrom(_ string: String) -> Date? {
        let dateFormatter = ExpirationDateFormatter()
        return dateFormatter.date(from: string)
    }
}
