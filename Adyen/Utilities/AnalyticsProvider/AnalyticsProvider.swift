//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

internal protocol AnalyticsProviderProtocol {}

internal class AnalyticsProvider: AnalyticsProviderProtocol {

    // MARK: - Properties

    internal var enabled = true
    internal var conversion = false
    internal var telemetry = true

    internal let apiClient: APIClientProtocol
    internal let apiContext: APIContext

    private var checkoutAttemptId: String?

    // MARK: - Initializers

    internal init(apiClient: APIClientProtocol,
                  apiContext: APIContext) {
        self.apiClient = apiClient
        self.apiContext = apiContext
    }

    internal func fetchCheckoutAttemptId(completion: @escaping (String?) -> Void) {
        guard enabled else { return }

        if !conversion { return completion(nil) }

        var checkoutAttemptIdRequest = CheckoutAttemptIdRequest()
        checkoutAttemptIdRequest.queryParameters = apiContext.queryParameters

        apiClient.perform(checkoutAttemptIdRequest) { [weak self] result in
            if case let .success(response) = result {
                self?.checkoutAttemptId = response.identifier
            }

            completion(self?.checkoutAttemptId)
        }
    }
}
