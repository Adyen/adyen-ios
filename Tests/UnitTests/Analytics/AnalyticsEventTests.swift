//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest
@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenNetworking

class AnalyticsEventTests: XCTestCase {

    var apiClient: APIClientMock!
    var sut: AnyAnalyticsProvider!

    override func setUpWithError() throws {
        try super.setUpWithError()
        apiClient = APIClientMock()
        let checkoutAttemptIdResponse = InitialAnalyticsResponse(checkoutAttemptId: "checkoutAttempId1")
        let checkoutAttemptIdResult: Result<Response, Error> = .success(checkoutAttemptIdResponse)
        apiClient.mockedResults = [checkoutAttemptIdResult]
        sut = AnalyticsProvider(
            apiClient: apiClient,
            context: .init(),
            eventAnalyticsProvider: nil
        )
    }

    override func tearDownWithError() throws {
        apiClient = nil
        sut = nil
        try super.tearDownWithError()
    }
    
    private func sendInitialAnalytics(flavor: AnalyticsFlavor = .components(type: .achDirectDebit)) {
        sut.sendInitialAnalytics(with: flavor, additionalFields: nil)
    }

    func testSendInitialEventGivenEnabledAndFlavorIsComponentsShouldSendInitialRequest() throws {
        // Given
        sut = AnalyticsProvider(
            apiClient: apiClient,
            context: .init(),
            eventAnalyticsProvider: nil
        )

        let flavor: AnalyticsFlavor = .components(type: .affirm)
        let expectedRequestCalls = 1

        let checkoutAttemptIdResult: Result<Response, Error> = .success(checkoutAttemptIdResponse)
        apiClient.mockedResults = [checkoutAttemptIdResult]

        // When
        sendInitialAnalytics(flavor: flavor)

        // Then
        wait(for: .milliseconds(1))
        XCTAssertEqual(expectedRequestCalls, apiClient.counter, "Invalid request number made.")
        XCTAssertEqual(sut.checkoutAttemptId, "cb3eef98-978e-4f6f-b299-937a4450be1f1648546838056be73d8f38ee8bcc3a65ec14e41b037a59f255dcd9e83afe8c06bd3e7abcad993")
    }

    func testSendInitialEventGivenEnabledAndFlavorIsDropInShouldSendInitialRequest() throws {
        // Given
        let analyticsConfiguration = AnalyticsConfiguration()
        sut = AnalyticsProvider(
            apiClient: apiClient,
            context: .init(),
            eventAnalyticsProvider: nil
        )

        let flavor: AnalyticsFlavor = .dropIn(paymentMethods: ["scheme", "paypal", "affirm"])
        let expectedRequestCalls = 1

        let checkoutAttemptIdResult: Result<Response, Error> = .success(checkoutAttemptIdResponse)
        apiClient.mockedResults = [checkoutAttemptIdResult]

        // When
        sendInitialAnalytics(flavor: flavor)

        // Then
        wait(for: .milliseconds(1))
        XCTAssertEqual(expectedRequestCalls, apiClient.counter, "Invalid request number made.")
    }

    // MARK: - Private

    private var checkoutAttemptIdResponse: InitialAnalyticsResponse {
        .init(checkoutAttemptId: "cb3eef98-978e-4f6f-b299-937a4450be1f1648546838056be73d8f38ee8bcc3a65ec14e41b037a59f255dcd9e83afe8c06bd3e7abcad993")
    }
}
