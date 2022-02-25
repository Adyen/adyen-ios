//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

// TODO: - Document
public class AdyenContext {

    // MARK: - Properties

    private let apiContext: APIContext
    private var analyticsProvider: AnalyticsProvider?

    // MARK: - Initializers

    public init(apiContext: APIContext) {
        self.apiContext = apiContext
    }

    // MARK: - Private

    private func setupAnalyticsProvider() {
        let apiClient = APIClient(apiContext: apiContext)
        analyticsProvider = AnalyticsProvider(apiClient: apiClient)
    }
}
