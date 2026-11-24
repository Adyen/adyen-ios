//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenNetworking
import XCTest

@MainActor
class AnalyticsEventTests: XCTestCase {

    var apiClient: APIClientMock!
    var sut: AnyAnalyticsProvider!

    override func setUp() async throws {
        try await super.setUp()
        apiClient = APIClientMock()
        let emptyResponse = EmptyResponse()
        let emptyResult: Result<Response, Error> = .success(emptyResponse)
        apiClient.mockedResults = [emptyResult]
        sut = AnalyticsProvider(
            apiClient: apiClient,
            configuration: .init(),
            checkoutAttemptId: AnalyticsProviderMock.testCheckoutAttemptId,
            eventAnalyticsProvider: AnyEventAnalyticsProviderMock()
        )
    }

    override func tearDown() async throws {
        apiClient = nil
        sut = nil
        try await super.tearDown()
    }
    
    private func sendInitialAnalytics(flavor: AnalyticsFlavor = .components(type: .achDirectDebit)) {
        sut.sendInitialAnalytics(with: flavor, additionalFields: nil)
    }

    func testSendInitialEventGivenEnabledAndFlavorIsComponentsShouldSendInitialRequest() {
        // Given
        sut = AnalyticsProvider(
            apiClient: apiClient,
            configuration: .init(),
            checkoutAttemptId: AnalyticsProviderMock.testCheckoutAttemptId,
            eventAnalyticsProvider: AnyEventAnalyticsProviderMock()
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
    }

    func testSendInitialEventGivenEnabledAndFlavorIsDropInShouldSendInitialRequest() {
        // Given
        sut = AnalyticsProvider(
            apiClient: apiClient,
            configuration: .init(),
            checkoutAttemptId: AnalyticsProviderMock.testCheckoutAttemptId,
            eventAnalyticsProvider: AnyEventAnalyticsProviderMock()
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
