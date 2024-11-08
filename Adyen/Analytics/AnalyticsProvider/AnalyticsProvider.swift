//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

internal final class AnalyticsProvider: AnyAnalyticsProvider {

    // MARK: - Properties

    internal var checkoutAttemptId: String? {
        didSet {
            eventAnalyticsProvider?.checkoutAttemptId = checkoutAttemptId
        }
    }

    internal var eventAnalyticsProvider: AnyEventAnalyticsProvider?
    
    private let uniqueAssetAPIClient: UniqueAssetAPIClient<InitialAnalyticsResponse>
    private let context: AnalyticsContext

    // MARK: - Initializers

    internal init(
        apiClient: APIClientProtocol,
        context: AnalyticsContext,
        eventAnalyticsProvider: AnyEventAnalyticsProvider?
    ) {
        self.context = context
        self.eventAnalyticsProvider = eventAnalyticsProvider
        self.uniqueAssetAPIClient = UniqueAssetAPIClient<InitialAnalyticsResponse>(apiClient: apiClient)
    }

    // MARK: - AnyAnalyticsProvider

    internal func sendInitialAnalytics(with flavor: AnalyticsFlavor, additionalFields: AdditionalAnalyticsFields?) {
        let analyticsData = AnalyticsData(
            flavor: flavor,
            additionalFields: additionalFields,
            context: context
        )

        let initialAnalyticsRequest = InitialAnalyticsRequest(data: analyticsData)

        uniqueAssetAPIClient.perform(initialAnalyticsRequest) { [weak self] result in
            self?.saveCheckoutAttemptId(from: result)
        }
    }
    
    internal func add(info: AnalyticsEventInfo) {
        eventAnalyticsProvider?.add(info: info)
    }
    
    internal func add(log: AnalyticsEventLog) {
        eventAnalyticsProvider?.add(log: log)
    }
    
    internal func add(error: AnalyticsEventError) {
        eventAnalyticsProvider?.add(error: error)
    }
    
    // MARK: - Private
    
    private func saveCheckoutAttemptId(from result: Result<InitialAnalyticsResponse, Error>) {
        switch result {
        case let .success(response):
            checkoutAttemptId = response.checkoutAttemptId
        case .failure:
            checkoutAttemptId = nil
        }
    }
}
