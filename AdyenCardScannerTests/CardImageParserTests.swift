//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenCardScanner
import XCTest

final class CardImageParserTests: XCTestCase {

    var sut: CardImageParser!
    var expirationDateFormatter: ExpirationDateFormatter!

    override func setUpWithError() throws {
        try super.setUpWithError()
        expirationDateFormatter = ExpirationDateFormatter()
    }

    override func tearDownWithError() throws {
        sut = nil
        expirationDateFormatter = nil
        try super.tearDownWithError()
    }

    func testParseImageWithHighContrastCardImage() throws {
        // Given
        let expirationDateFormatter = ExpirationDateFormatter()
        sut = CardImageParser(expirationDateFormatter: expirationDateFormatter)

        let testCreditCard = try XCTUnwrap(testCreditCardHighContrast)
        let expectation = expectation(description: "Image should be parsed")

        // When
        sut.parse(image: testCreditCard.image) { receivedCreditCard in
            expectation.fulfill()

            let expectedCreditCard = testCreditCard.creditCard
            XCTAssertEqual(expectedCreditCard.number, receivedCreditCard.number)
            XCTAssertEqual(expectedCreditCard.expirationDate, receivedCreditCard.expirationDate)
        }

        // Then
        wait(for: [expectation], timeout: 0.1)
    }

    func testParseImageWithLowContrastCardImage() throws {
        // Given
        let expirationDateFormatter = ExpirationDateFormatter()
        sut = CardImageParser(expirationDateFormatter: expirationDateFormatter)

        let testCreditCard = try XCTUnwrap(testCreditCardLowContrast)
        let expectation = expectation(description: "Image should be parsed")

        // When
        sut.parse(image: testCreditCard.image) { receivedCreditCard in
            expectation.fulfill()

            let expectedCreditCard = testCreditCard.creditCard
            XCTAssertEqual(expectedCreditCard.number, receivedCreditCard.number)
            XCTAssertEqual(expectedCreditCard.expirationDate, receivedCreditCard.expirationDate)
        }

        // Then
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testParseImageWithDashSeparatedExpirationDate() throws {
        // Given
        let expirationDateFormatter = ExpirationDateFormatter()
        sut = CardImageParser(expirationDateFormatter: expirationDateFormatter)

        let testCreditCard = try XCTUnwrap(testCreditCardWithDashSeparatedExpirationDate)
        let expectation = expectation(description: "Image should be parsed")

        // When
        sut.parse(image: testCreditCard.image) { receivedCreditCard in
            expectation.fulfill()

            let expectedCreditCard = testCreditCard.creditCard
            XCTAssertEqual(expectedCreditCard.number, receivedCreditCard.number)
            XCTAssertEqual(expectedCreditCard.expirationDate, receivedCreditCard.expirationDate)
        }

        // Then
        wait(for: [expectation], timeout: 0.1)
    }

    func testParseImageWithInvalidLuhnCheck() throws {
        // Given
        let expirationDateFormatter = ExpirationDateFormatter()
        sut = CardImageParser(expirationDateFormatter: expirationDateFormatter)

        let testCreditCard = try XCTUnwrap(testCreditCardInvalidLuhn)
        let expectation = expectation(description: "Image should be parsed")
        expectation.isInverted = true

        // When
        sut.parse(image: testCreditCard.image) { receivedCreditCard in
            expectation.fulfill()

            let expectedCreditCard = testCreditCard.creditCard
            XCTAssertEqual(expectedCreditCard.number, receivedCreditCard.number)
            XCTAssertEqual(expectedCreditCard.expirationDate, receivedCreditCard.expirationDate)
        }

        // Then
        wait(for: [expectation], timeout: 0.1)
    }
    
    // MARK: - Private

    private struct TestCreditCard {
        let image: CIImage
        let creditCard: CreditCard
    }

    private var testCreditCardHighContrast: TestCreditCard? {
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

    private var testCreditCardLowContrast: TestCreditCard? {
        let image = UIImage(
            named: "test-card-number-2",
            in: Bundle(for: type(of: self)),
            compatibleWith: nil
        )
        guard let cgImage = image?.cgImage else { return nil }
        let originalImage = CIImage(cgImage: cgImage)

        let creditCard = CreditCard(
            number: "5413330089099999",
            expirationDate: dateFrom("02/28")
        )
        return TestCreditCard(
            image: originalImage,
            creditCard: creditCard
        )
    }

    private var testCreditCardInvalidLuhn: TestCreditCard? {
        let image = UIImage(
            named: "test-card-number-3",
            in: Bundle(for: type(of: self)),
            compatibleWith: nil
        )
        guard let cgImage = image?.cgImage else { return nil }
        let originalImage = CIImage(cgImage: cgImage)

        let creditCard = CreditCard(
            number: "5412751234123456",
            expirationDate: dateFrom("12/23")
        )
        return TestCreditCard(
            image: originalImage,
            creditCard: creditCard
        )
    }
    
    private var testCreditCardWithDashSeparatedExpirationDate: TestCreditCard? {
        let image = UIImage(
            named: "test-card-number-4",
            in: Bundle(for: type(of: self)),
            compatibleWith: nil
        )
        guard let cgImage = image?.cgImage else { return nil }
        let originalImage = CIImage(cgImage: cgImage)

        let creditCard = CreditCard(
            number: "4111111111111111",
            expirationDate: dateFrom("03/30")
        )
        return TestCreditCard(
            image: originalImage,
            creditCard: creditCard
        )
    }

    private func dateFrom(_ string: String) -> Date? {
        expirationDateFormatter.date(from: string)
    }
}
