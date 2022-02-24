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

    internal var checkoutAttemptId: String? {
        get {
            conversion ? self.checkoutAttemptId : nil
        }
        set {
            self.checkoutAttemptId = newValue
        }
    }

    // MARK: - Initializers

    internal init(apiClient: APIClientProtocol,
                  apiContext: APIContext) {
        self.apiClient = apiClient
        self.apiContext = apiContext
    }

    // MARK: - Private

    private func fetchCheckoutAttemptId(completion: @escaping () -> Void) {
        guard enabled else { return }

        if !conversion {
            completion()
            return
        }

        var checkoutAttemptIdRequest = CheckoutAttemptIdRequest(experiments: [])
        checkoutAttemptIdRequest.queryParameters = apiContext.queryParameters

        apiClient.perform(checkoutAttemptIdRequest) { [weak self] result in
            if case let .success(response) = result {
                self?.checkoutAttemptId = response.identifier
            }

            completion()
        }
    }
}
