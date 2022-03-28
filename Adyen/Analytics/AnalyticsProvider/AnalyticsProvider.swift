//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

/// A configuration object that defines the behavior for the analytics.
public struct AnalyticsConfiguration {

    // MARK: - Properties

    /// A Boolean value that determines whether telemetry tracking is enabled.
    public let isTelemetryEnabled = true

    /// A Boolean value that determines whether the checkoutAttemt id fetch is enabled.
    public let isCheckoutAttemptIdEnabled = true

    // MARK: - Initializers

    public init() { /* Empty implementation */ }
}

/// : nodoc:
public protocol AnalyticsProviderProtocol: TelemetryTrackerProtocol {}

/// : nodoc:
internal final class AnalyticsProvider: AnalyticsProviderProtocol {

    // MARK: - Properties

    internal let apiClient: APIClientProtocol
    internal let configuration: AnalyticsConfiguration
    private let uniqueAssetAPIClient: UniqueAssetAPIClient<CheckoutAttemptIdResponse>

    // MARK: - Initializers

    internal init(apiClient: APIClientProtocol,
                  configuration: AnalyticsConfiguration) {
        self.apiClient = apiClient
        self.configuration = configuration
        self.uniqueAssetAPIClient = UniqueAssetAPIClient<CheckoutAttemptIdResponse>(apiClient: apiClient)
    }

    // MARK: - Internal

    internal func fetchCheckoutAttemptId(completion: @escaping (String?) -> Void) {
        guard configuration.isCheckoutAttemptIdEnabled else {
            return completion(nil)
        }

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
}
