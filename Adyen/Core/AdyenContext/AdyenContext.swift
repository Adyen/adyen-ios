//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

/// A class that defines the behavior of the components in a payment session.
/// Create an `AdyenContext` instance for each payment session and use it for all the components.
public final class AdyenContext {

    // MARK: - Properties

    /// The API context used to retrieve internal resources.
    public let apiContext: APIContext

    @_spi(AdyenInternal)
    public let analyticsProvider: AnalyticsProviderProtocol

    // MARK: - Initializers

    /// Creates an Adyen context with the provided API context and analytics configuration.
    /// - Parameters:
    ///   - apiContext: The API context used to retrieve internal resources.
    ///   - analyticsConfiguration: A configuration object that specifies the behavior for the analytics.
    public init(apiContext: APIContext, analyticsConfiguration: AnalyticsConfiguration = .init()) {
        self.apiContext = apiContext

        let apiClient = APIClient(apiContext: apiContext)
        self.analyticsProvider = AnalyticsProvider(apiClient: apiClient,
                                                   configuration: analyticsConfiguration)
    }

    internal init(apiContext: APIContext,
                  analyticsProvider: AnalyticsProviderProtocol) {
        self.apiContext = apiContext
        self.analyticsProvider = analyticsProvider
    }
}
