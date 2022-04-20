//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

// TODO: - Document (consult with docs team)
public final class AdyenContext {

    // MARK: - Properties

    private let apiContext: APIContext
    private let analyticsConfiguration: AnalyticsConfiguration

    /// :nodoc:
    public let analyticsProvider: AnalyticsProviderProtocol

    // MARK: - Initializers

    /// Creates and returns an Adyen context with the provided API context and analytics configuration.
    /// - Parameters:
    ///   - apiContext: The API context used to retrieve internal resources.
    ///   - analyticsConfiguration: A configuration object that specifies the behavior for the analytics.
    public init(apiContext: APIContext, analyticsConfiguration: AnalyticsConfiguration = .init()) {
        self.apiContext = apiContext
        self.analyticsConfiguration = analyticsConfiguration

        let apiClient = APIClient(apiContext: apiContext)
        self.analyticsProvider = AnalyticsProvider(apiClient: apiClient,
                                                   configuration: analyticsConfiguration)
    }

    /// :nodoc:
    internal init(apiContext: APIContext,
                  analyticsProvider: AnalyticsProviderProtocol,
                  analyticsConfiguration: AnalyticsConfiguration = .init()) {
        self.apiContext = apiContext
        self.analyticsProvider = analyticsProvider
        self.analyticsConfiguration = analyticsConfiguration
    }
}
