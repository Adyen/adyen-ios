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

    /// A Boolean value that determines whether analytics is enabled.
    public var isEnabled = true

    @_spi(AdyenInternal)
    public var isTelemetryEnabled = true

    // MARK: - Initializers
    
    /// Initializes a new instance of `AnalyticsConfiguration`
    public init() { /* Empty implementation */ }
}

@_spi(AdyenInternal)
public protocol AnalyticsProviderProtocol: TelemetryTrackerProtocol {}

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
        guard configuration.isEnabled else { return }

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
