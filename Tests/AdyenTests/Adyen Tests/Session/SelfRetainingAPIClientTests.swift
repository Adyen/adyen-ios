//
//  SelfRetainingAPIClientTests.swift
//  AdyenUIKitTests
//
//  Created by Mohamed Eldoheiri on 3/4/22.
//  Copyright © 2022 Adyen. All rights reserved.
//

import XCTest
@testable import AdyenSession
import AdyenNetworking
import Adyen

extension SessionSetupResponse: Equatable {
    public static func == (lhs: SessionSetupResponse, rhs: SessionSetupResponse) -> Bool {
        lhs.sessionData == rhs.sessionData &&
        lhs.shopperLocale == rhs.shopperLocale &&
        lhs.countryCode == rhs.countryCode &&
        lhs.amount == rhs.amount
    }
}

class SelfRetainingAPIClientTests: XCTestCase {

    func testSelfRetentionAndDestruction() throws {
        let request = SessionSetupRequest(sessionId: "id", sessionData: "data")
        let successExpectation = expectation(description: "expect response to be received")
        let baseApiClient = APIClientMock()
        let expectedResponse = SessionSetupResponse(
            countryCode: "US",
            shopperLocale: "EG",
            paymentMethods: PaymentMethods(regular: [], stored: []),
            amount: .init(value: 2, currencyCode: "USD", localeIdentifier: nil),
            sessionData: "data"
        )
        baseApiClient.mockedResults = [
            .failure(Dummy.error),
            .failure(Dummy.error),
            .success(expectedResponse)
        ]
        let apiClient = baseApiClient.retryAPIClient(with: SimpleScheduler(maximumCount: 3)).retryOnErrorAPIClient()
        let deinitExpectation = expectation(description: "expect deinit to be called")
        performRequestWithLocalAPIClient(
            request: request,
            with: apiClient,
            onDeinit: {
                deinitExpectation.fulfill()
            }, completion: { result in
                switch result {
                case .failure:
                    XCTFail()
                case let .success(response):
                    XCTAssertEqual(response, expectedResponse)
                    successExpectation.fulfill()
                }
            }
        )
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func performRequestWithLocalAPIClient<R: Request>(request: R,
                                                      with apiClient: APIClientProtocol,
                                                      onDeinit: (() -> Void)?,
                                                      completion: @escaping (Result<R.ResponseType, Error>) -> Void) {
        let sut = SelfRetainingAPIClient(apiClient: apiClient)
        sut.perform(request, completionHandler: completion)
        sut.onDeinit = onDeinit
    }
    
}
