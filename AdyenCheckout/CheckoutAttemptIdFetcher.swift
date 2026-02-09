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
/// Does 2 tasks:
/// 1. Creates a analytics environment/APIClient to send analytical events using the CheckoutConfiguration.
/// 2. Sends a `RequestCheckoutAttemptIdRequest` to get the checkoutAttemptId.
/// Note: If there is any failure in fetching the checkoutAttemptId then we will return nil, as that would imply that there should not be any analytics events sent.
/// Improvement: This is an edge case and the current success rate of the api is pretty high 99 something so this would rarely ever fail. If this ever becomes a constraint we could add a retying logic to try twice if it failed once. But that is an improvement if needed alone.
internal class CheckoutAttemptIdFetcher: CheckoutAttemptIdFetching {

    private let apiClientProvider: (CheckoutConfiguration) -> APIClientProtocol?

    internal init() {
        self.apiClientProvider = CheckoutAttemptIdFetcher.defaultAPIClientProvider
    }

    internal init(apiClientProvider: @escaping (CheckoutConfiguration) -> APIClientProtocol?) {
        self.apiClientProvider = apiClientProvider
    }

    internal func fetchCheckoutAttemptId(
        with configuration: CheckoutConfiguration
    ) async -> String? {
        let request = RequestCheckoutAttemptIdRequest()
        guard let apiClient = apiClientProvider(configuration),
              let response = try? await withCheckedThrowingContinuation({ continuation in
                  apiClient.perform(request) { result in
                      continuation.resume(with: result)
                  }
              }) else {
            return nil
        }
        // TODO: Robert: This will need to be removed once we determine how we are going to create the AnalyticsProvider. For now we just need to inform the AnalyticProvider.
        configuration.context.analyticsProvider?.checkoutAttemptId = response.checkoutAttemptId

        return response.checkoutAttemptId
    }

    // MARK: - Private

    private static let defaultAPIClientProvider: (CheckoutConfiguration) -> APIClientProtocol? = { configuration in
        AdyenContext.createAnalyticsAPIClient(
            apiContext: configuration.context.apiContext
        )
    }
}
