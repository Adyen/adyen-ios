//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

// TODO: - Document
public struct AnalyticsOptions: OptionSet {
    public let rawValue: Int

    public static let telemetry = AnalyticsOptions(rawValue: 1 << 0)
    public static let checkoutAttemptId = AnalyticsOptions(rawValue: 1 << 1)

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

// TODO: - Document
public struct AnalyticsConfiguration {

    private let options: AnalyticsOptions

    // MARK: - Initializers

    public init(options: AnalyticsOptions = [.telemetry, .checkoutAttemptId]) {
        self.options = options
    }

    // MARK: - Internal

    internal var isCheckoutAttemptIdEnabled: Bool {
        options.contains(.checkoutAttemptId)
    }

    internal var isTelemetryEnabled: Bool {
        options.contains(.checkoutAttemptId)
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
