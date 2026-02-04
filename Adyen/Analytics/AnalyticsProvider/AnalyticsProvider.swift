//
// Copyright (c) 2022 Adyen N.V.
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

    /// This value is nil when analytics is disabled by configuration provided by the merchant.
    internal var eventAnalyticsProvider: AnyEventAnalyticsProvider?
    private let uniqueAssetAPIClient: UniqueAssetAPIClient<RequestCheckoutAttemptIdResponse>
    private let configuration: AnalyticsConfiguration

    // MARK: - Initializers

    internal init(
        apiClient: APIClientProtocol,
        configuration: AnalyticsConfiguration,
        eventAnalyticsProvider: AnyEventAnalyticsProvider?
    ) {
        self.configuration = configuration
        self.eventAnalyticsProvider = eventAnalyticsProvider
        self.uniqueAssetAPIClient = UniqueAssetAPIClient<RequestCheckoutAttemptIdResponse>(apiClient: apiClient)
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
        uniqueAssetAPIClient.perform(initialAnalyticsRequest) { [weak self] result in
            self?.handleInitialAnalyticsResponse(result)
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
    
    private func handleInitialAnalyticsResponse(_ result: Result<RequestCheckoutAttemptIdResponse, Error>) {
        // TODO: Robert: Ideally we ignore the response. And this method can be deleted,
        // but to validate the requirement that the attemptID will be the same one returned during development we assert.
        guard let fetchedCheckoutAttemptID = try? result.get().checkoutAttemptId else {
            return
        }

        if checkoutAttemptId != nil, fetchedCheckoutAttemptID != checkoutAttemptId {
            // This will fail on debug builds. If this fails then we need to discuss as the logic is a bit different.
            // As the precondition that the checkoutAttemptID should be the same as returned by the EmptyRequest and InitialRequest.
            AdyenAssertion.assertionFailure(message: "Analytics handleInitialAnalyticsResponse checkoutAttemptId mismatch: current:\(checkoutAttemptId), response: \(fetchedCheckoutAttemptID)")
        }
    }
}
