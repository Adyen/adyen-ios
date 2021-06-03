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

    func testMultipleFetchCallsAndOneRequestDispatched() throws {
        var baseApiClient = APIClientMock()
        var apiClient = RetryAPIClient(apiClient: baseApiClient, scheduler: SimpleScheduler(maximumCount: 2))
        var sut = CardPublicKeyProvider(apiContext: Dummy.context, apiClient: apiClient)
        CardPublicKeyProvider.cachedCardPublicKey = nil

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
        sut = CardPublicKeyProvider(apiContext: Dummy.context, apiClient: apiClient)

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
