//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

internal enum Flavor: String {
    case components
    case dropin
}

internal protocol AnalyticsProviderProtocol {}

internal class AnalyticsProvider: AnalyticsProviderProtocol {

    // MARK: - Properties

    internal var enabled = true
    internal var conversion = false
    internal var telemetry = true

    internal let apiClient: APIClientProtocol
    internal let apiContext: APIContext

    internal var checkoutAttemptId: String?

    // MARK: - Initializers

    internal init(apiClient: APIClientProtocol,
                  apiContext: APIContext) {
        self.apiClient = apiClient
        self.apiContext = apiContext
    }

    // MARK: - Private

    private func fetchCheckoutAttemptId() {
        var checkoutAttemptIdRequest = CheckoutAttemptIdRequest(experiments: [])
        checkoutAttemptIdRequest.queryParameters = apiContext.queryParameters

        apiClient.perform(checkoutAttemptIdRequest) { result in
            if case let .success(response) = result {
                self.checkoutAttemptId = response.identifier
            }
        }
    }

    // MARK: - AnalyticsProviderProtocol
}
