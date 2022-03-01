//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

// public enum AnalyticsConfiguration {
//    case enabled(telemetry: Bool, conversion: Bool)
//    case disabled
// }

// TODO: - Document
public struct AnalyticsConfiguration {

    // MARK: - Properties

    public var enabled = true
    public var telemetry = true
    public var conversion = false

    // MARK: - Initializers

    public init() { /* Empty Initializer */ }

    // MARK: - Internal

    internal var isConversionEnabled: Bool {
        enabled && conversion
    }

    internal var isTelemetryEnabled: Bool {
        enabled && telemetry
    }
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

    internal func fetchCheckoutAttemptId(completion: @escaping (String?) -> Void) {
        guard configuration.isConversionEnabled else {
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
