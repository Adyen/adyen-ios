//
//  CardPublicKeyProviderTests.swift
//  AdyenTests
//
//  Created by Mohamed Eldoheiri on 8/17/20.
//  Copyright © 2020 Adyen. All rights reserved.
//

@testable import Adyen
@testable import AdyenCard
import XCTest

class CardPublicKeyProviderTests: XCTestCase {

    override func tearDown() {
        super.tearDown()
        AdyenAssertion.listener = nil
    }

    func testMissingClientKey() {
        let baseApiClient = APIClientMock()
        let apiClient = RetryAPIClient(apiClient: baseApiClient, scheduler: SimpleScheduler(maximumCount: 2))
        let sut = CardPublicKeyProvider(apiClient: apiClient)
        CardPublicKeyProvider.cachedCardPublicKey = nil

        let expectation = XCTestExpectation(description: "Except Assertion failure.")
        AdyenAssertion.listener = { message in
            XCTAssertEqual(message, "ClientKey is missing or invalid.")
            expectation.fulfill()
        }

        sut.fetch(completion: { _ in })
        wait(for: [expectation], timeout: 2, enforceOrder: true)
    }

    func testMultipleFetchCallsAndOneRequestDispatched() throws {
        var baseApiClient = APIClientMock()
        var apiClient = RetryAPIClient(apiClient: baseApiClient, scheduler: SimpleScheduler(maximumCount: 2))
        var sut = CardPublicKeyProvider(apiClient: apiClient)
        CardPublicKeyProvider.cachedCardPublicKey = nil
        sut.clientKey = Dummy.dummyClientKey

        baseApiClient.mockedResults = [.success(ClientKeyResponse(cardPublicKey: "test_public_key"))]

        let fetchExpectation = expectation(description: "CardPublicKeyProvider.fetch() completion handler must be called.")
        fetchExpectation.expectedFulfillmentCount = 10
        (0...9).forEach { _ in
            sut.fetch { result in
                switch result {
                case let .success(key):
                    XCTAssertEqual(key, "test_public_key")
                default:
                    XCTFail()
                }
                fetchExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 10, handler: nil)

        XCTAssertEqual(baseApiClient.counter, 1)

        // Subsequent fetch calls should get the cached key value without making any requests

        baseApiClient = APIClientMock()
        apiClient = RetryAPIClient(apiClient: baseApiClient, scheduler: SimpleScheduler(maximumCount: 2))
        sut = CardPublicKeyProvider(apiClient: apiClient)
        sut.clientKey = Dummy.dummyClientKey

        let secondFetchExpectation = expectation(description: "second CardPublicKeyProvider.fetch() completion handler must be called.")
        sut.fetch { result in
            switch result {
            case let .success(key):
                XCTAssertEqual(key, "test_public_key")
            default:
                XCTFail()
            }
            secondFetchExpectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)

        XCTAssertEqual(baseApiClient.counter, 0)
    }

}
