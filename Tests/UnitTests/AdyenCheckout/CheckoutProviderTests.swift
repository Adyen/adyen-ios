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

    // MARK: - CheckoutAttemptIdFetching Tests (testing the fetcher in isolation)

    func test_fetchCheckoutAttemptId_returnsCheckoutAttemptId_whenAPIClientSucceeds() async throws {
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

        let sut = TestableCheckoutAttemptIdFetcher(apiClient: apiClientMock)

        // When
        let result = try await sut.fetchCheckoutAttemptId(with: configuration)

        // Then
        XCTAssertEqual(result, expectedCheckoutAttemptId)
    }

    func test_fetchCheckoutAttemptId_setsAnalyticsProviderCheckoutAttemptId() async throws {
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

        let sut = TestableCheckoutAttemptIdFetcher(apiClient: apiClientMock)

        // When
        _ = try await sut.fetchCheckoutAttemptId(with: configuration)

        // Then
        XCTAssertEqual(analyticsProviderMock.checkoutAttemptId, expectedCheckoutAttemptId)
    }

    func test_fetchCheckoutAttemptId_throwsError_whenAPIClientFails() async {
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

        let sut = TestableCheckoutAttemptIdFetcher(apiClient: apiClientMock)

        // When/Then
        do {
            _ = try await sut.fetchCheckoutAttemptId(with: configuration)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual((error as NSError).code, 500)
        }
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

        let sut = TestableCheckoutAttemptIdFetcher(apiClient: apiClientMock)

        // When
        _ = try? await sut.fetchCheckoutAttemptId(with: configuration)

        // Then
        XCTAssertNil(analyticsProviderMock.checkoutAttemptId)
    }

    func test_fetchCheckoutAttemptId_returnsNil_whenAPIClientIsNil() async throws {
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

        let sut = TestableCheckoutAttemptIdFetcher(apiClient: nil)

        // When
        let result = try await sut.fetchCheckoutAttemptId(with: configuration)

        // Then
        XCTAssertNil(result)
    }

    func test_fetchCheckoutAttemptId_doesNotSetAnalyticsProviderCheckoutAttemptId_whenAPIClientIsNil() async throws {
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

        let sut = TestableCheckoutAttemptIdFetcher(apiClient: nil)

        // When
        _ = try await sut.fetchCheckoutAttemptId(with: configuration)

        // Then
        XCTAssertNil(analyticsProviderMock.checkoutAttemptId)
    }

    // MARK: - CheckoutProvider delegation tests

    func test_checkoutProvider_delegatesToFetcher() async throws {
        // Given
        let expectedId = "delegated_checkout_attempt_id"
        let mockFetcher = MockCheckoutAttemptIdFetcher(result: expectedId)
        let sut = CheckoutProvider(checkoutAttemptIdFetcher: mockFetcher)

        let configuration = CheckoutConfiguration(
            context: Dummy.context,
            analyticsConfiguration: AnalyticsConfiguration()
        )

        // When
        let result = try await sut.fetchCheckoutAttemptId(with: configuration)

        // Then
        XCTAssertEqual(result, expectedId)
        XCTAssertTrue(mockFetcher.fetchCalled)
    }

    func test_checkoutProvider_delegatesToFetcher_whenFetcherThrows() async {
        // Given
        let expectedError = NSError(domain: "TestError", code: 42, userInfo: nil)
        let mockFetcher = MockCheckoutAttemptIdFetcher(error: expectedError)
        let sut = CheckoutProvider(checkoutAttemptIdFetcher: mockFetcher)

        let configuration = CheckoutConfiguration(
            context: Dummy.context,
            analyticsConfiguration: AnalyticsConfiguration()
        )

        // When/Then
        do {
            _ = try await sut.fetchCheckoutAttemptId(with: configuration)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual((error as NSError).code, 42)
        }
        XCTAssertTrue(mockFetcher.fetchCalled)
    }

    func test_checkoutProvider_delegatesToFetcher_returnsNil() async throws {
        // Given
        let mockFetcher = MockCheckoutAttemptIdFetcher(result: nil)
        let sut = CheckoutProvider(checkoutAttemptIdFetcher: mockFetcher)

        let configuration = CheckoutConfiguration(
            context: Dummy.context,
            analyticsConfiguration: AnalyticsConfiguration()
        )

        // When
        let result = try await sut.fetchCheckoutAttemptId(with: configuration)

        // Then
        XCTAssertNil(result)
        XCTAssertTrue(mockFetcher.fetchCalled)
    }
}

// MARK: - MockCheckoutAttemptIdFetcher

private class MockCheckoutAttemptIdFetcher: CheckoutAttemptIdFetching {

    private let stubbedResult: String?
    private let stubbedError: Error?
    private(set) var fetchCalled = false

    init(result: String?) {
        self.stubbedResult = result
        self.stubbedError = nil
    }

    init(error: Error) {
        self.stubbedResult = nil
        self.stubbedError = error
    }

    func fetchCheckoutAttemptId(
        with configuration: CheckoutConfiguration
    ) async throws -> String? {
        fetchCalled = true
        if let stubbedError {
            throw stubbedError
        }
        return stubbedResult
    }
}

// MARK: - TestableCheckoutAttemptIdFetcher

private class TestableCheckoutAttemptIdFetcher: CheckoutAttemptIdFetching {

    private let apiClient: APIClientProtocol?

    init(apiClient: APIClientProtocol?) {
        self.apiClient = apiClient
    }

    func fetchCheckoutAttemptId(
        with configuration: CheckoutConfiguration
    ) async throws -> String? {
        guard let apiClient else {
            return nil
        }

        let request = RequestCheckoutAttemptIdRequest()

        let response = try await withCheckedThrowingContinuation { continuation in
            apiClient.perform(request) { result in
                continuation.resume(with: result)
            }
        }

        configuration.context.analyticsProvider?.checkoutAttemptId = response.checkoutAttemptId

        return response.checkoutAttemptId
    }
}
