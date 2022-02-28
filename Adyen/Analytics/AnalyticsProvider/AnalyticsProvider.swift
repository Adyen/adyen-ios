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
    private let uniqueAssetAPIClient: UniqueAssetAPIClient<CheckoutAttemptIdResponse>

    // MARK: - Initializers

    internal init(apiClient: APIClientProtocol,
                  configuration: AnalyticsConfiguration) {
        self.apiClient = apiClient
        self.uniqueAssetAPIClient = UniqueAssetAPIClient<CheckoutAttemptIdResponse>(apiClient: apiClient)
        setupConfiguration(configuration)
    }

    internal func fetchCheckoutAttemptId(completion: @escaping (String?) -> Void) {
        guard enabled else { return }

        if !conversion { return completion(nil) }

        let checkoutAttemptIdRequest = CheckoutAttemptIdRequest()

        uniqueAssetAPIClient.perform(checkoutAttemptIdRequest) { result in
            switch result {
            case let .success(response):
                completion(response.identifier)
            case .failure:
                completion(nil)
            }
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
