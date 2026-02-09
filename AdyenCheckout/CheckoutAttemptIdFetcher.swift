//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import AdyenNetworking
import Foundation

// sourcery:AutoMockable
internal protocol CheckoutAttemptIdFetching {
    func fetchCheckoutAttemptId(
        with configuration: CheckoutConfiguration
    ) async -> String?
}

/// Default implementation that performs the actual API call to fetch the checkout attempt ID.
/// If there is any failure in fetching the checkoutAttemptId then we should return nil, as that would imply that there will not be any analytics send for this session.
/// Improvement: This is an edge case and the current success rate of the api is pretty high 99 something so this would rarely ever fail. If this ever becomes a constraint we could add a retying logic to try twice if it failed once. But that is an improvement if needed alone.
internal class DefaultCheckoutAttemptIdFetcher: CheckoutAttemptIdFetching {

    internal typealias APIClientFactory = (CheckoutConfiguration) -> APIClientProtocol?

    private let apiClientFactory: APIClientFactory

    internal init() {
        self.apiClientFactory = DefaultCheckoutAttemptIdFetcher.defaultAPIClientFactory
    }

    internal init(apiClientFactory: @escaping APIClientFactory) {
        self.apiClientFactory = apiClientFactory
    }

    internal func fetchCheckoutAttemptId(
        with configuration: CheckoutConfiguration
    ) async -> String? {

        guard let apiClient = apiClientFactory(configuration) else {
            return nil
        }

        let request = RequestCheckoutAttemptIdRequest()

        do {
            let response = try await withCheckedThrowingContinuation { continuation in
                apiClient.perform(request) { result in
                    continuation.resume(with: result)
                }
            }

            // TODO: Robert: This will need to be removed once we determine how we are going to create the AnalyticsProvider. For now we just need to inform the AnalyticProvider.
            configuration.context.analyticsProvider?.checkoutAttemptId = response.checkoutAttemptId

            return response.checkoutAttemptId
        } catch {
            return nil
        }
    }

    // MARK: - Private

    private static let defaultAPIClientFactory: APIClientFactory = { configuration in
        AdyenContext.createAnalyticsAPIClient(
            apiContext: configuration.context.apiContext,
            analyticsConfiguration: configuration.analyticsConfiguration
        )
    }
}
