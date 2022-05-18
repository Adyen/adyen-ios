//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

/// A class that defines a set of attributes to set the behaviour for all components for a payment.
/// An `AdyenContext` is instance should be created per payment session.
public final class AdyenContext {

    // MARK: - Properties

    /// The API context used to retrieve internal resources.
    public let apiContext: APIContext

    /// :nodoc:
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

    /// :nodoc:
    internal init(apiContext: APIContext,
                  analyticsProvider: AnalyticsProviderProtocol) {
        self.apiContext = apiContext
        self.analyticsProvider = analyticsProvider
    }
}
