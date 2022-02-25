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
    internal var telemetry = true
    internal var conversion = false

    internal let apiClient: APIClientProtocol

    private var checkoutAttemptId: String?

    // MARK: - Initializers

    internal init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    internal func fetchCheckoutAttemptId(completion: @escaping (String?) -> Void) {
        guard enabled else { return }

        if !conversion { return completion(nil) }

        let checkoutAttemptIdRequest = CheckoutAttemptIdRequest()

        apiClient.perform(checkoutAttemptIdRequest) { [weak self] result in
            if case let .success(response) = result {
                self?.checkoutAttemptId = response.identifier
            }

            completion(self?.checkoutAttemptId)
        }
    }
}
