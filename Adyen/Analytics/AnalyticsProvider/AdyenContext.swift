//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

// TODO: - Document
public final class AdyenContext {

    // MARK: - Properties

    private let apiContext: APIContext
    public let analyticsProvider: AnalyticsProviderProtocol

    // MARK: - Initializers

    public init(apiContext: APIContext, analyticsConfiguration: AnalyticsConfiguration = .init()) {
        self.apiContext = apiContext

        let apiClient = APIClient(apiContext: apiContext)
        self.analyticsProvider = AnalyticsProvider(apiClient: apiClient,
                                                   configuration: analyticsConfiguration)
    }

    // MARK: - Internal

    internal init(apiContext: APIContext, analyticsProvider: AnalyticsProviderProtocol) {
        self.apiContext = apiContext
        self.analyticsProvider = analyticsProvider
    }
}
