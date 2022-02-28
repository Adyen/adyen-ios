//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

// TODO: - Document
public protocol AnalyticsProviderProtocol {}

internal class AnalyticsProvider: AnalyticsProviderProtocol {

    // MARK: - Properties

    internal var enabled = true
    internal var telemetry = true
    internal var conversion = false

    internal let apiClient: APIClientProtocol
    private var checkoutAttemptId: String?

    // MARK: - Initializers

    internal init(apiClient: APIClientProtocol,
                  configuration: AnalyticsConfiguration) {
        self.apiClient = apiClient
        setupConfiguration(configuration)
    }

    internal func fetchCheckoutAttemptId(completion: @escaping (String?) -> Void) {
        guard enabled else { return }

        if !conversion { return completion(nil) }

        if let checkoutAttemptId = checkoutAttemptId {
            return completion(checkoutAttemptId)
        }

        let checkoutAttemptIdRequest = CheckoutAttemptIdRequest()

        let uniqueAssetAPIClient = UniqueAssetAPIClient<CheckoutAttemptIdResponse>(apiClient: apiClient)
        uniqueAssetAPIClient.perform(checkoutAttemptIdRequest) { [weak self] result in
            if case let .success(response) = result {
                self?.checkoutAttemptId = response.identifier
            }

            completion(self?.checkoutAttemptId)
        }
    }

    // MARK: - Private

    private func setupConfiguration(_ configuration: AnalyticsConfiguration) {
        switch configuration {
        case let .enabled(telemetry, conversion):
            self.enabled = true
            self.telemetry = telemetry
            self.conversion = conversion
        case .disabled:
            self.enabled = false
        }
    }
}
