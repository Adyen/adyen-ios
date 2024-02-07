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
    
    @_spi(AdyenInternal)
    public var context: TelemetryContext = .init()

    // MARK: - Initializers
    
    /// Initializes a new instance of `AnalyticsConfiguration`
    public init() { /* Empty implementation */ }
}

@_spi(AdyenInternal)
/// Additional fields to be provided with a ``TelemetryRequest``
public struct AdditionalAnalyticsFields {
    /// The amount of the payment
    public let amount: Amount?
    
    public let sessionId: String?
    
    public init(amount: Amount? = nil, sessionId: String? = nil) {
        self.amount = amount
        self.sessionId = sessionId
    }
}

@_spi(AdyenInternal)
public protocol AnalyticsProviderProtocol {
    
    /// Sends the initial data and retrieves the checkout attempt id as a response.
    func sendInitialAnalytics(with flavor: TelemetryFlavor, additionalFields: AdditionalAnalyticsFields?)
    
    var checkoutAttemptId: String? { get }
}

internal final class AnalyticsProvider: AnalyticsProviderProtocol {

    // MARK: - Properties

    internal let apiClient: APIClientProtocol
    internal let configuration: AnalyticsConfiguration
    internal private(set) var checkoutAttemptId: String?
    private let uniqueAssetAPIClient: UniqueAssetAPIClient<InitialAnalyticsResponse>

    // MARK: - Initializers

    internal init(
        apiClient: APIClientProtocol,
        configuration: AnalyticsConfiguration
    ) {
        self.apiClient = apiClient
        self.configuration = configuration
        self.uniqueAssetAPIClient = UniqueAssetAPIClient<InitialAnalyticsResponse>(apiClient: apiClient)
    }

    // MARK: - Internal

    internal func sendInitialAnalytics(with flavor: TelemetryFlavor, additionalFields: AdditionalAnalyticsFields?) {
        guard configuration.isEnabled, configuration.isTelemetryEnabled else {
            checkoutAttemptId = "do-not-track"
            return
        }
        if case .dropInComponent = flavor { return }
        
        let telemetryData = TelemetryData(flavor: flavor,
                                          additionalFields: additionalFields,
                                          context: configuration.context)

        let initialAnalyticsRequest = InitialAnalyticsRequest(data: telemetryData)

        uniqueAssetAPIClient.perform(initialAnalyticsRequest) { [weak self] result in
            switch result {
            case let .success(response):
                self?.checkoutAttemptId = response.checkoutAttemptId
            case .failure:
                self?.checkoutAttemptId = nil
            }
        }
    }
}
