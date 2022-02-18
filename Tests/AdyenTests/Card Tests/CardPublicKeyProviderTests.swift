//
//  PublicKeyProviderTests.swift
//  AdyenTests
//
//  Created by Mohamed Eldoheiri on 8/17/20.
//  Copyright © 2020 Adyen. All rights reserved.
//

@testable import Adyen
@testable import AdyenCard
import AdyenNetworking
import XCTest

class PublicKeyProviderTests: XCTestCase {

    override func tearDown() {
        super.tearDown()
        AdyenAssertion.listener = nil
    }

    func testMultipleFetchCallsAndOneRequestDispatched() throws {
        var baseApiClient = APIClientMock()
        var apiClient = RetryAPIClient(apiClient: baseApiClient, scheduler: SimpleScheduler(maximumCount: 2))
        var sut = PublicKeyProvider(apiClient: apiClient, request: ClientKeyRequest(clientKey: Dummy.context.clientKey))
        PublicKeyProvider.publicKeysCache[Dummy.context.clientKey] = nil

        baseApiClient.mockedResults = [.success(ClientKeyResponse(cardPublicKey: "test_public_key"))]

        let fetchExpectation = expectation(description: "PublicKeyProvider.fetch() completion handler must be called.")
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
        sut = PublicKeyProvider(apiClient: apiClient, request: ClientKeyRequest(clientKey: Dummy.context.clientKey))

        let secondFetchExpectation = expectation(description: "second PublicKeyProvider.fetch() completion handler must be called.")
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
        
        // Subsequent fetch calls with different
        // clientKey should fetch a new public key and cache it

        baseApiClient = APIClientMock()
        apiClient = RetryAPIClient(apiClient: baseApiClient, scheduler: SimpleScheduler(maximumCount: 2))
        sut = PublicKeyProvider(apiClient: apiClient, request: ClientKeyRequest(clientKey: "different_client_key"))
        
        baseApiClient.mockedResults = [.success(ClientKeyResponse(cardPublicKey: "another_test_public_key"))]

        let thirdFetchExpectation = expectation(description: "second PublicKeyProvider.fetch() completion handler must be called.")
        sut.fetch { result in
            switch result {
            case let .success(key):
                XCTAssertEqual(key, "another_test_public_key")
            default:
                XCTFail()
            }
            thirdFetchExpectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)

        XCTAssertEqual(baseApiClient.counter, 1)
        XCTAssertEqual(PublicKeyProvider.publicKeysCache[Dummy.context.clientKey], "test_public_key")
        XCTAssertEqual(PublicKeyProvider.publicKeysCache["different_client_key"], "another_test_public_key")
    }

}
