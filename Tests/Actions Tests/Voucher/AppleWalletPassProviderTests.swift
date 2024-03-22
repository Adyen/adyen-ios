//
//  AppleWalletPassProviderTests.swift
//  AdyenUIKitTests
//
//  Created by Mohamed Eldoheiri on 6/3/21.
//  Copyright © 2021 Adyen. All rights reserved.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenActions
@testable import AdyenNetworking
import XCTest

class AppleWalletPassProviderTests: XCTestCase {

    var context: AdyenContext!

    override func setUpWithError() throws {
        try super.setUpWithError()
        context = Dummy.context
    }

    override func tearDownWithError() throws {
        context = nil
        AdyenAssertion.listener = nil
        try super.tearDownWithError()
    }

    func testMultipleFetchCallsAndOneRequestDispatched() throws {
        let baseApiClient = APIClientMock()
        let apiClient = RetryAPIClient(apiClient: baseApiClient, scheduler: SimpleScheduler(maximumCount: 2))
        let sut = AppleWalletPassProvider(context: context,
                                          apiClient: apiClient)

        baseApiClient.mockedResults = [.success(try! AppleWalletPassResponse(passBase64String: "123".data(using: .utf8)!.base64EncodedString()))]

        let fetchExpectation = expectation(description: "PublicKeyProvider.fetch() completion handler must be called.")
        fetchExpectation.expectedFulfillmentCount = 10
        (0...9).forEach { _ in
            sut.provide(with: "token") { result in
                switch result {
                case let .success(data):
                    XCTAssertEqual(data, "123".data(using: .utf8))
                default:
                    XCTFail()
                }
                fetchExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 10, handler: nil)

        XCTAssertEqual(baseApiClient.counter, 1)

        // Subsequent fetch calls should get the cached key value without making any requests

        let secondFetchExpectation = expectation(description: "second PublicKeyProvider.fetch() completion handler must be called.")
        sut.provide(with: "token") { result in
            switch result {
            case let .success(key):
                XCTAssertEqual(key, "123".data(using: .utf8))
            default:
                XCTFail()
            }
            secondFetchExpectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)

        XCTAssertEqual(baseApiClient.counter, 1)
    }

}
