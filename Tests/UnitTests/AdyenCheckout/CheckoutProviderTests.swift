//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenCheckout
import AdyenNetworking
@_spi(AdyenInternal) @testable import AdyenSession
import XCTest

final class CheckoutProviderTests: XCTestCase {

    // MARK: - DefaultCheckoutAttemptIdFetcher Tests (testing the fetcher in isolation)

    func test_fetchCheckoutAttemptId_returnsCheckoutAttemptId_whenAPIClientSucceeds() async {
        // Given
        let expectedCheckoutAttemptId = "test_checkout_attempt_id_12345"
        let apiClientMock = APIClientMock()
        let response = RequestCheckoutAttemptIdResponse(checkoutAttemptId: expectedCheckoutAttemptId)
        apiClientMock.mockedResults = [.success(response)]

        let analyticsProviderMock = AnalyticsProviderMock()
        let context = AdyenContext(
            apiContext: Dummy.apiContext,
            payment: Dummy.payment,
            amount: Dummy.amount,
            analyticsProvider: analyticsProviderMock
        )
        let configuration = CheckoutConfiguration(
            context: context,
            analyticsConfiguration: AnalyticsConfiguration()
        )

        let sut = DefaultCheckoutAttemptIdFetcher(apiClientFactory: { _ in apiClientMock })

        // When
        let result = await sut.fetchCheckoutAttemptId(with: configuration)

        // Then
        XCTAssertEqual(result, expectedCheckoutAttemptId)
    }

    func test_fetchCheckoutAttemptId_setsAnalyticsProviderCheckoutAttemptId() async {
        // Given
        let expectedCheckoutAttemptId = "analytics_provider_test_id"
        let apiClientMock = APIClientMock()
        let response = RequestCheckoutAttemptIdResponse(checkoutAttemptId: expectedCheckoutAttemptId)
        apiClientMock.mockedResults = [.success(response)]

        let analyticsProviderMock = AnalyticsProviderMock()
        let context = AdyenContext(
            apiContext: Dummy.apiContext,
            payment: Dummy.payment,
            amount: Dummy.amount,
            analyticsProvider: analyticsProviderMock
        )
        let configuration = CheckoutConfiguration(
            context: context,
            analyticsConfiguration: AnalyticsConfiguration()
        )

        let sut = DefaultCheckoutAttemptIdFetcher(apiClientFactory: { _ in apiClientMock })

        // When
        _ = await sut.fetchCheckoutAttemptId(with: configuration)

        // Then
        XCTAssertEqual(analyticsProviderMock.checkoutAttemptId, expectedCheckoutAttemptId)
    }

    func test_fetchCheckoutAttemptId_returnsNil_whenAPIClientFails() async {
        // Given
        let apiClientMock = APIClientMock()
        let expectedError = NSError(domain: "TestError", code: 500, userInfo: nil)
        apiClientMock.mockedResults = [.failure(expectedError)]

        let analyticsProviderMock = AnalyticsProviderMock()
        let context = AdyenContext(
            apiContext: Dummy.apiContext,
            payment: Dummy.payment,
            amount: Dummy.amount,
            analyticsProvider: analyticsProviderMock
        )
        let configuration = CheckoutConfiguration(
            context: context,
            analyticsConfiguration: AnalyticsConfiguration()
        )

        let sut = DefaultCheckoutAttemptIdFetcher(apiClientFactory: { _ in apiClientMock })

        // When
        let result = await sut.fetchCheckoutAttemptId(with: configuration)

        // Then
        XCTAssertNil(result)
    }

    func test_fetchCheckoutAttemptId_doesNotSetAnalyticsProviderCheckoutAttemptId_whenAPIClientFails() async {
        // Given
        let apiClientMock = APIClientMock()
        let expectedError = NSError(domain: "TestError", code: 500, userInfo: nil)
        apiClientMock.mockedResults = [.failure(expectedError)]

        let analyticsProviderMock = AnalyticsProviderMock()
        let context = AdyenContext(
            apiContext: Dummy.apiContext,
            payment: Dummy.payment,
            amount: Dummy.amount,
            analyticsProvider: analyticsProviderMock
        )
        let configuration = CheckoutConfiguration(
            context: context,
            analyticsConfiguration: AnalyticsConfiguration()
        )

        let sut = DefaultCheckoutAttemptIdFetcher(apiClientFactory: { _ in apiClientMock })

        // When
        _ = await sut.fetchCheckoutAttemptId(with: configuration)

        // Then
        XCTAssertNil(analyticsProviderMock.checkoutAttemptId)
    }

    func test_fetchCheckoutAttemptId_returnsNil_whenAPIClientIsNil() async {
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let context = AdyenContext(
            apiContext: Dummy.apiContext,
            payment: Dummy.payment,
            amount: Dummy.amount,
            analyticsProvider: analyticsProviderMock
        )
        let configuration = CheckoutConfiguration(
            context: context,
            analyticsConfiguration: AnalyticsConfiguration()
        )

        let sut = DefaultCheckoutAttemptIdFetcher(apiClientFactory: { _ in nil })

        // When
        let result = await sut.fetchCheckoutAttemptId(with: configuration)

        // Then
        XCTAssertNil(result)
    }

    func test_fetchCheckoutAttemptId_doesNotSetAnalyticsProviderCheckoutAttemptId_whenAPIClientIsNil() async {
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let context = AdyenContext(
            apiContext: Dummy.apiContext,
            payment: Dummy.payment,
            amount: Dummy.amount,
            analyticsProvider: analyticsProviderMock
        )
        let configuration = CheckoutConfiguration(
            context: context,
            analyticsConfiguration: AnalyticsConfiguration()
        )

        let sut = DefaultCheckoutAttemptIdFetcher(apiClientFactory: { _ in nil })

        // When
        _ = await sut.fetchCheckoutAttemptId(with: configuration)

        // Then
        XCTAssertNil(analyticsProviderMock.checkoutAttemptId)
    }

}
