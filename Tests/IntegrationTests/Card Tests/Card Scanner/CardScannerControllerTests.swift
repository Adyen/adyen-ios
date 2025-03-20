//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenCard
@testable import AdyenCardScanner
import XCTest

class CardScannerControllerTests: XCTestCase {

    var sut: CardScannerController!
    var mockPresenter: UIViewController!
    private var mockCardScanner: CardScannerProviderSpy!

    override func setUpWithError() throws {
        mockPresenter = UIViewController()
        mockCardScanner = CardScannerProviderSpy()

        sut = CardScannerController(
            presenter: mockPresenter,
            availabilityProvider: CardScannerAvailalabilityMock(),
            cardScannerProvider: mockCardScanner
        )

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = mockPresenter
        window.makeKeyAndVisible()
    }

    override func tearDownWithError() throws {
        sut = nil
        mockPresenter = nil
        mockCardScanner = nil
    }

    // This test requires AdyenCardScanner framework to be imported for the test target
    func test_scannerIsAvailable() {
        XCTAssertTrue(sut.isScannerAvailable)
    }

    func test_openCardScanner_withTitle_presentsCorrectTitle() throws {
        let expectation = XCTestExpectation(description: "Card scanner should complete the flow")
        sut.onScanComplete = { result in
            expectation.fulfill()
        }

        let expectedTitle = "Scan your card"
        sut.title = expectedTitle
        sut.openCardScanner()

        let scannerNavigationController = mockPresenter.presentedViewController as? UINavigationController
        let scannerViewController = scannerNavigationController?.topViewController
        XCTAssertEqual(scannerViewController?.title, expectedTitle)

        sut.onScanComplete?(.success((nil, Date())))
        wait(for: [expectation], timeout: 3.0)
    }

    func testHandleCardScanningCancelation() throws {
        sut.openCardScanner()

        sut.handleCardScanningCancelation {
            XCTAssertNil(self.mockPresenter.presentedViewController)
        }
    }

    func test_controller_returnsScannedCardValue() {
        // Given
        let expectation = XCTestExpectation(description: "Card scanner should complete the flow")

        let cardNumber = "1111 2222 3333 4444"
        let expiryDate = Date(timeIntervalSince1970: 1742456818)

        let expectedResultTuple: (String?, Date?) = (cardNumber, expiryDate)
        let mockCard = AdyenCardScanner.CreditCard(number: cardNumber, expirationDate: expiryDate)

        sut.onScanComplete = { result in
            // Then
            self.expect(result, toMatch: .success(expectedResultTuple))
            expectation.fulfill()
        }

        // When
        sut.openCardScanner()
        mockCardScanner.onScanComplete(result: .success(mockCard))

        wait(for: [expectation], timeout: 1.0)
    }

    func test_controller_returnsSimplifiedScannerError() {
        // Given
        let expectation = XCTestExpectation(description: "Card scanner should complete the flow")
        let mockError = AdyenCardScanner.CardScannerError(kind: .authorizationDenied)
        let expectedError = CardScannerController.CardScannerError.scanningError

        sut.onScanComplete = { result in
            // Then
            self.expect(result, toMatch: .failure(expectedError))
            expectation.fulfill()
        }

        // When
        sut.openCardScanner()
        mockCardScanner.onScanComplete(result: .failure(mockError))

        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Helpers

    private func expect(_ result: Result<(String?, Date?), Error>, toMatch expectedResult: Result<(String?, Date?), Error>) {
        switch (result, expectedResult) {
        case (.success(let (receivedCard, receivedDate)), .success(let (expectedCard, expectedDate))):
            XCTAssertEqual(receivedCard, expectedCard)
            XCTAssertEqual(receivedDate, expectedDate)
        case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
            XCTAssertEqual(receivedError, expectedError)
        default:
            XCTFail()
        }
    }

    private struct CardScannerAvailalabilityMock: CardScannerAvailability {
        var isScannerAvailable: Bool { true }
    }

    private class CardScannerProviderSpy: CardScannerProviding {
        private var completion: ((Result<AdyenCardScanner.CreditCard, AdyenCardScanner.CardScannerError>) -> Void)? = nil

        func createCardScanner(
            completion: @escaping (Result<AdyenCardScanner.CreditCard, AdyenCardScanner.CardScannerError>) -> Void
        ) -> UIViewController? {
            self.completion = completion
            return UIViewController()
        }

        func onScanComplete(result: Result<AdyenCardScanner.CreditCard, AdyenCardScanner.CardScannerError>) {
            self.completion?(result)
        }
    }
}
