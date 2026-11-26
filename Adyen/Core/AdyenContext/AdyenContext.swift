//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

/// A class that defines the behavior of the components in a payment flow.
package final class AdyenContext {
    
    // MARK: - Properties
    
    /// The API context used to retrieve internal resources.
    package let apiContext: APIContext
    
    package var analyticsProvider: AnyAnalyticsProvider?

    package let publicKey: String

    package let browserInfo: BrowserInfo?

    /// The payment amount.
    package var amount: Amount?

    // MARK: - Initializers
    
    @MainActor
    package convenience init(
        apiContext: APIContext,
        amount: Amount?,
        publicKey: String,
        checkoutAttemptId: String?,
        browserInfo: BrowserInfo?,
        analyticsAPIContext: APIContext?,
        analyticsConfiguration: AnalyticsConfiguration = .init()
    ) {
        let analyticsProvider = Self.createAnalyticsProvider(
            analyticsApiContext: analyticsAPIContext,
            checkoutAttemptId: checkoutAttemptId,
            analyticsConfiguration: analyticsConfiguration
        )
        
        self.init(
            apiContext: apiContext,
            amount: amount,
            publicKey: publicKey,
            browserInfo: browserInfo,
            analyticsProvider: analyticsProvider
        )
    }
    
    /// Internal init for testing only
    internal init(
        apiContext: APIContext,
        amount: Amount?,
        publicKey: String,
        browserInfo: BrowserInfo?,
        analyticsProvider: AnyAnalyticsProvider?
    ) {
        self.publicKey = publicKey
        self.apiContext = apiContext
        self.amount = amount
        self.browserInfo = browserInfo
        self.analyticsProvider = analyticsProvider
    }

    @MainActor
    private static func createAnalyticsProvider(
        analyticsApiContext: APIContext?,
        checkoutAttemptId: String?,
        analyticsConfiguration: AnalyticsConfiguration
    ) -> AnyAnalyticsProvider? {
        guard let analyticsApiContext,
              let checkoutAttemptId else {
            return nil
        }

        let analyticsApiClient = APIClient(apiContext: analyticsApiContext)

        var eventAnalyticsProvider: AnyEventAnalyticsProvider?
        if analyticsConfiguration.isEnabled {
            let eventDataSource = AnalyticsEventDataSource()
            let syncEventDataSource = ThreadSafeAnalyticsEventDataSource(dataSource: eventDataSource)
            eventAnalyticsProvider = EventAnalyticsProvider(
                apiClient: analyticsApiClient,
                eventDataSource: syncEventDataSource,
                checkoutAttemptId: checkoutAttemptId
            )
        }

        return AnalyticsProvider(
            apiClient: analyticsApiClient,
            configuration: analyticsConfiguration,
            checkoutAttemptId: checkoutAttemptId,
            eventAnalyticsProvider: eventAnalyticsProvider
        )
    }
}
