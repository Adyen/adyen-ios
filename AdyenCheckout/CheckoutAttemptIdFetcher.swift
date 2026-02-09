//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import AdyenNetworking
import Foundation

/// Protocol for fetching the checkout attempt ID.
internal protocol CheckoutAttemptIdFetching {
    func fetchCheckoutAttemptId(
        with configuration: CheckoutConfiguration
    ) async throws -> String?
}

/// Default implementation that performs the actual API call to fetch the checkout attempt ID.
internal class DefaultCheckoutAttemptIdFetcher: CheckoutAttemptIdFetching {

    internal init() {}

    internal func fetchCheckoutAttemptId(
        with configuration: CheckoutConfiguration
    ) async throws -> String? {

        guard let apiClient = AdyenContext.createAnalyticsAPIClient(
            apiContext: configuration.context.apiContext,
            analyticsConfiguration: configuration.analyticsConfiguration
        ) else {
            return nil
        }

        let request = RequestCheckoutAttemptIdRequest()

        let response = try await withCheckedThrowingContinuation { continuation in
            apiClient.perform(request) { result in
                continuation.resume(with: result)
            }
        }

        // TODO: Robert: This will need to be removed once we determine how we are going to create the AnalyticsProvider. For now we just need to inform the AnalyticProvider.
        configuration.context.analyticsProvider?.checkoutAttemptId = response.checkoutAttemptId

        return response.checkoutAttemptId
    }
}
