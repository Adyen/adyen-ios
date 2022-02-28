//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

// TODO: - Document
public enum AnalyticsConfiguration {
    case enabled(telemetry: Bool, conversion: Bool)
    case disabled
}

// TODO: - Document
public class AdyenContext {

    // MARK: - Properties

    private let apiContext: APIContext
    internal var analyticsProvider: AnalyticsProviderProtocol?

    // MARK: - Initializers

    public init(apiContext: APIContext, analyticsConfiguration: AnalyticsConfiguration) {
        self.apiContext = apiContext
        setupAnalyticsProvider(configuration: analyticsConfiguration)
    }

    // MARK: - Private

    private func setupAnalyticsProvider(configuration: AnalyticsConfiguration) {
        let apiClient = APIClient(apiContext: apiContext)
        analyticsProvider = AnalyticsProvider(apiClient: apiClient, configuration: configuration)
    }
}
