//
// Copyright (c) 2023 Adyen N.V.
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
/// Additional fields to be provided with a ``TelemetryRequest``
public struct AdditionalAnalyticsFields {
    /// The amount of the payment
    public let amount: Amount?
}

@_spi(AdyenInternal)
public protocol AnalyticsProviderProtocol: TelemetryTrackerProtocol {
    
    var checkoutAttemptId: String? { get }
    func fetchAndCacheCheckoutAttemptIdIfNeeded()
    
    var additionalFields: (() -> AdditionalAnalyticsFields)? { get }
}

internal final class AnalyticsProvider: AnalyticsProviderProtocol {

    // MARK: - Properties

    internal let apiClient: APIClientProtocol
    internal let configuration: AnalyticsConfiguration
    internal private(set) var checkoutAttemptId: String?
    internal var additionalFields: (() -> AdditionalAnalyticsFields)?
    private let uniqueAssetAPIClient: UniqueAssetAPIClient<CheckoutAttemptIdResponse>

    // MARK: - Initializers

    internal init(
        apiClient: APIClientProtocol,
        configuration: AnalyticsConfiguration
    ) {
        self.apiClient = apiClient
        self.configuration = configuration
        self.uniqueAssetAPIClient = UniqueAssetAPIClient<CheckoutAttemptIdResponse>(apiClient: apiClient)
    }

    // MARK: - Internal
    
    internal func fetchAndCacheCheckoutAttemptIdIfNeeded() {
        fetchCheckoutAttemptId { _ in /* Do nothing, the point is to trigger the fetching and cache the value  */ }
    }

    internal func fetchCheckoutAttemptId(completion: @escaping (String?) -> Void) {
        guard configuration.isEnabled else {
            completion(nil)
            return
        }

        let checkoutAttemptIdRequest = CheckoutAttemptIdRequest()

        uniqueAssetAPIClient.perform(checkoutAttemptIdRequest) { [weak self] result in
            switch result {
            case let .success(response):
                self?.checkoutAttemptId = response.identifier
                completion(response.identifier)
            case .failure:
                completion(nil)
            }
        }
    }
}
