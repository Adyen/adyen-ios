//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

internal final class AnalyticsProvider: AnyAnalyticsProvider {

    // MARK: - Properties

    // TODO: Robert: This should become required(non optional) and it need not be passed to the eventAnalyticsProvider, and should be available during init. 
    internal var checkoutAttemptId: String? {
        didSet {
            eventAnalyticsProvider?.checkoutAttemptId = checkoutAttemptId
        }
    }

    /// This value is nil when analytics is disabled by configuration provided by the merchant.
    internal var eventAnalyticsProvider: AnyEventAnalyticsProvider?
    private let uniqueAssetAPIClient: UniqueAssetAPIClient<EmptyResponse>
    private let configuration: AnalyticsConfiguration

    // MARK: - Initializers

    internal init(
        apiClient: APIClientProtocol,
        configuration: AnalyticsConfiguration,
        eventAnalyticsProvider: AnyEventAnalyticsProvider?
    ) {
        self.configuration = configuration
        self.eventAnalyticsProvider = eventAnalyticsProvider
        self.uniqueAssetAPIClient = UniqueAssetAPIClient<EmptyResponse>(apiClient: apiClient)
    }

    // MARK: - AnyAnalyticsProvider

    internal func sendInitialAnalytics(with flavor: AnalyticsFlavor, additionalFields: AdditionalAnalyticsFields?) {
        let analyticsData = AnalyticsData(
            flavor: flavor,
            additionalFields: additionalFields,
            configuration: configuration,
            checkoutAttemptId: checkoutAttemptId
        )

        let initialAnalyticsRequest = InitialAnalyticsRequest(data: analyticsData)
        uniqueAssetAPIClient.perform(initialAnalyticsRequest) { _ in }
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
}
