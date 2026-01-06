//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

#if canImport(AdyenCardScanner)
    import XCTest
    @testable @_spi(AdyenInternal) import AdyenCard

    final class CardScannerProviderDispatchOnceTests: XCTestCase {

        func testCardScannerCompletesOnlyOnce() {
            let expectation = XCTestExpectation(description: "Card scanner completion should be called once")
            expectation.expectedFulfillmentCount = 1
            expectation.assertForOverFulfill = true

            let cardScanner = CardScannerProviderSpy()
            let sut = CardScannerProviderDispatchOnce(scannerProvider: cardScanner)
            _ = sut.createCardScanner { result in
                expectation.fulfill()
            }

            cardScanner.onScanComplete(result: .success((nil, Date())))
            cardScanner.onScanComplete(result: .success((nil, Date())))
            cardScanner.onScanComplete(result: .failure(NSError(domain: "domain", code: 123)))

            wait(for: [expectation], timeout: 0.3)
        }
    }
#endif
