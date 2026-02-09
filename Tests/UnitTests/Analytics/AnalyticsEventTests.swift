//
// Copyright (c) 2022 Adyen N.V.
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
        let emptyResponse = EmptyResponse()
        let emptyResult: Result<Response, Error> = .success(emptyResponse)
        apiClient.mockedResults = [emptyResult]
        sut = AnalyticsProvider(
            apiClient: apiClient,
            configuration: .init(),
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

    func testSendInitialEventGivenEnabledAndFlavorIsComponentsShouldSendInitialRequest() {
        // Given
        sut = AnalyticsProvider(
            apiClient: apiClient,
            configuration: .init(),
            eventAnalyticsProvider: nil
        )

        let flavor: AnalyticsFlavor = .components(type: .affirm)
        let expectedRequestCalls = 1

        let emptyResult: Result<Response, Error> = .success(EmptyResponse())
        apiClient.mockedResults = [emptyResult]

        // When
        sendInitialAnalytics(flavor: flavor)

        // Then
        wait(for: .milliseconds(1))
        XCTAssertEqual(expectedRequestCalls, apiClient.counter, "Invalid request number made.")
        XCTAssertNil(sut.checkoutAttemptId)
    }

    func testSendInitialEventGivenEnabledAndFlavorIsDropInShouldSendInitialRequest() {
        // Given
        sut = AnalyticsProvider(
            apiClient: apiClient,
            configuration: .init(),
            eventAnalyticsProvider: nil
        )

        let flavor: AnalyticsFlavor = .dropIn(paymentMethods: ["scheme", "paypal", "affirm"])
        let expectedRequestCalls = 1

        let emptyResult: Result<Response, Error> = .success(EmptyResponse())
        apiClient.mockedResults = [emptyResult]

        // When
        sendInitialAnalytics(flavor: flavor)

        // Then
        wait(for: .milliseconds(1))
        XCTAssertEqual(expectedRequestCalls, apiClient.counter, "Invalid request number made.")
    }

}
