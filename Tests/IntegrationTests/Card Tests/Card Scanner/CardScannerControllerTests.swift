//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

#if canImport(AdyenCardScanner)
    @testable import AdyenCard
    @testable import AdyenCardScanner
    import XCTest

    class CardScannerControllerTests: XCTestCase {

        // This test requires AdyenCardScanner framework to be imported for the test target
        func test_scannerIsAvailable() {
            let (sut, _, _) = makeSUT()
            XCTAssertTrue(sut.isScannerAvailable)
        }

        func test_openCardScanner_withTitle_presentsCorrectTitle() throws {
            let expectation = XCTestExpectation(description: "Card scanner should complete the flow")
            let (sut, presenter, _) = makeSUT()

            let window = UIWindow(frame: UIScreen.main.bounds)
            window.rootViewController = presenter
            window.makeKeyAndVisible()

            sut.onScanComplete = { result in
                expectation.fulfill()
            }

            let expectedTitle = "Scan your card"
            sut.title = expectedTitle
            sut.openCardScanner()

            let scannerNavigationController = presenter.presentedViewController as? UINavigationController
            let scannerViewController = scannerNavigationController?.topViewController
            XCTAssertEqual(scannerViewController?.title, expectedTitle)

            sut.onScanComplete?(.success((nil, Date())))
            wait(for: [expectation], timeout: 3.0)
        }

        func testHandleCardScanningCancelation() throws {
            let (sut, presenter, _) = makeSUT()

            sut.openCardScanner()

            sut.handleCardScanningCancelationWithCompletion {
                XCTAssertNil(presenter.presentedViewController)
            }
        }

        func test_controller_returnsScannedCardValue() {
            // Given
            let expectation = XCTestExpectation(description: "Card scanner should complete the flow")

            let cardNumber = "1111 2222 3333 4444"
            let expiryDate = Date(timeIntervalSince1970: 1742456818)

            let expectedResult: CardScanDetails = (cardNumber, expiryDate)
            let mockCard = CardScanDetails(cardNumber, expiryDate)

            let (sut, presenter, cardScanner) = makeSUT()
            sut.onScanComplete = { result in
                // Then
                self.expect(result, toMatch: .success(expectedResult))
                expectation.fulfill()
            }

            // When
            sut.openCardScanner()
            cardScanner.onScanComplete(result: .success(mockCard))

            wait(for: [expectation], timeout: 1.0)
        }

        func test_controller_returnsSimplifiedScannerError() {
            // Given
            let expectation = XCTestExpectation(description: "Card scanner should complete the flow")
            let mockError = AdyenCardScanner.CardScannerError(kind: .authorizationDenied)
            let expectedError = CardScannerController.CardScannerError.scanningError
            let (sut, presenter, cardScanner) = makeSUT()

            sut.onScanComplete = { result in
                // Then
                self.expect(result, toMatch: .failure(expectedError))
                expectation.fulfill()
            }

            // When
            sut.openCardScanner()
            cardScanner.onScanComplete(result: .failure(mockError))

            wait(for: [expectation], timeout: 1.0)
        }

        // MARK: - Helpers

        private func makeSUT() -> (CardScannerController, UIViewController, CardScannerProviderSpy) {
            let presenter = UIViewController()
            let cardScanner = CardScannerProviderSpy()

            let sut = CardScannerController(
                presenter: presenter,
                availabilityProvider: CardScannerAvailalabilityMock(),
                cardScannerProvider: cardScanner
            )
            return (sut, presenter, cardScanner)
        }

        private func expect(
            _ result: Result<CardScanDetails, Error>,
            toMatch expectedResult: Result<CardScanDetails, Error>,
            file: StaticString = #file,
            line: UInt = #line
        ) {
            switch (result, expectedResult) {
            case (.success(let (receivedCard, receivedDate)), .success(let (expectedCard, expectedDate))):
                XCTAssertEqual(receivedCard, expectedCard, file: file, line: line)
                XCTAssertEqual(receivedDate, expectedDate, file: file, line: line)
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail()
            }
        }

        private struct CardScannerAvailalabilityMock: CardScannerAvailability {
            var isScannerAvailable: Bool { true }
        }

        private class CardScannerProviderSpy: CardScannerProviding {
            private var completion: ((Result<AdyenCardScanner.CardScanDetails, Error>) -> Void)? = nil

            func createCardScanner(
                completion: @escaping (Result<CardScanDetails, Error>) -> Void
            ) -> UIViewController? {
                self.completion = completion
                return UIViewController()
            }

            func onScanComplete(result: Result<CardScanDetails, Error>) {
                self.completion?(result)
            }
        }
    }
#endif
