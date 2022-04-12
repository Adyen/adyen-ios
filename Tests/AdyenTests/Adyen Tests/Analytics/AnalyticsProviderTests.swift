//
//  AnalyticsProviderTests.swift
//  Adyen
//
//  Created by Naufal Aros on 4/11/22.
//  Copyright © 2022 Adyen. All rights reserved.
//

import XCTest
@testable import Adyen
@testable import AdyenNetworking

class AnalyticsProviderTests: XCTestCase {

    var apiClient: APIClientMock!
    var analyticsConfiguration: AnalyticsConfiguration!
    var sut: AnalyticsProvider!

    override func setUpWithError() throws {
        try super.setUpWithError()
        apiClient = APIClientMock()
        analyticsConfiguration = .init()
        sut = AnalyticsProvider(apiClient: apiClient, configuration: analyticsConfiguration)
    }

    override func tearDownWithError() throws {
        apiClient = nil
        analyticsConfiguration = nil
        sut = nil
        try super.tearDownWithError()
    }

    func testFetchCheckoutAttemptIdWhenCheckoutAttemptIdIsDisabledShouldCallCompletionWithNilValue() throws {
        // Given
        analyticsConfiguration.isCheckoutAttemptIdEnabled = false

        // When
        sut.fetchCheckoutAttemptId { receivedCheckoutAttemptId in

            // Then
            XCTAssertNil(receivedCheckoutAttemptId, "The checkoutAttemptId is not nil.")
        }
    }

    func testFetchCheckoutAttemptIdWhenCheckoutAttemptIdIsEnabledGivenSuccessShouldCallCompletionWithNonNilValue() throws {
        // Given
        let expectedCheckoutAttemptId = checkoutAttemptIdMockValue
        analyticsConfiguration.isCheckoutAttemptIdEnabled = true

        let checkoutAttemptIdResponse = CheckoutAttemptIdResponse(identifier: expectedCheckoutAttemptId)
        let checkoutAttemptIdResult: Result<Response, Error> = .success(checkoutAttemptIdResponse)
        apiClient.mockedResults = [checkoutAttemptIdResult]

        // When
        sut.fetchCheckoutAttemptId { receivedCheckoutAttemptId in

            // Then
            XCTAssertNotNil(receivedCheckoutAttemptId, "The checkoutAttemptId is nil.")
            XCTAssertEqual(expectedCheckoutAttemptId, receivedCheckoutAttemptId, "The received checkoutAttemptId is not the expected one.")
        }
    }

    func testFetchCheckoutAttemptIdWhenCheckoutAttemptIdIsEnabledGivenFailureShouldCallCompletionWithNilValue() throws {
        // Given
        analyticsConfiguration.isCheckoutAttemptIdEnabled = true

        let error = NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Internal Server Error"])
        let checkoutAttemptIdResult: Result<Response, Error> = .failure(error)
        apiClient.mockedResults = [checkoutAttemptIdResult]

        // When
        sut.fetchCheckoutAttemptId { receivedCheckoutAttemptId in

            // Then
            XCTAssertNil(receivedCheckoutAttemptId, "The checkoutAttemptId is not nil.")
        }
    }

    // MARK - Private

    private var checkoutAttemptIdMockValue: String {
        "cb3eef98-978e-4f6f-b299-937a4450be1f1648546838056be73d8f38ee8bcc3a65ec14e41b037a59f255dcd9e83afe8c06bd3e7abcad993"
    }
}
