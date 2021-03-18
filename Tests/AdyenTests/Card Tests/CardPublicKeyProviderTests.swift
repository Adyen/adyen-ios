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

    func testMissingClientKey() {
        let baseApiClient = APIClientMock()
        let apiClient = RetryAPIClient(apiClient: baseApiClient, scheduler: SimpleScheduler(maximumCount: 2))
        let sut = CardPublicKeyProvider(apiClient: apiClient)
        CardPublicKeyProvider.cachedCardPublicKey = nil

        XCTAssertThrowsError(try sut.fetch(completion: { _ in }), "CardPublicKeyProvider must throw an error if client key is missing") {
            XCTAssertEqual($0 as! CardComponent.Error, CardComponent.Error.missingClientKey)
        }
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
        try (0...9).forEach { _ in
            try sut.fetch { result in
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
        try sut.fetch { result in
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
