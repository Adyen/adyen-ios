//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

// TODO: make non public

/// A class that defines the behavior of the components in a payment flow.
public final class AdyenContext: PaymentAware {
    
    // MARK: - Properties
    
    /// The API context used to retrieve internal resources.
    public let apiContext: APIContext
    
    // TODO: get rid of payment
    /// The payment information.
    public private(set) var payment: Payment?
    
    package var analyticsProvider: AnyAnalyticsProvider?

    package let amount: Amount

    // MARK: - Initializers
    
    /// Creates an Adyen context with the provided API context and analytics configuration.
    /// - Parameters:
    ///   - apiContext: The API context used to retrieve internal resources.
    ///   - analyticsConfiguration: A configuration object that specifies the behavior for the analytics.
    ///   - payment: The payment information.
    package convenience init(
        apiContext: APIContext,
        payment: Payment?,
        amount: Amount,
        checkoutAttemptId: String?,
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
            payment: payment,
            amount: amount,
            analyticsProvider: analyticsProvider
        )
    }
    
    /// Internal init for testing only
    internal init(
        apiContext: APIContext,
        payment: Payment?,
        amount: Amount,
        analyticsProvider: AnyAnalyticsProvider?
    ) {
        self.apiContext = apiContext
        self.amount = amount
        self.analyticsProvider = analyticsProvider
        self.payment = payment
    }
    
    @_spi(AdyenInternal)
    public func update(payment: Payment?) {
        self.payment = payment
    }

    // TODO: Robert: this stays here even in the init of the AnalyticalProvider.
    private static func createAnalyticsProvider(
        analyticsApiContext: APIContext?,
        checkoutAttemptId: String?,
        analyticsConfiguration: AnalyticsConfiguration
    ) -> AnyAnalyticsProvider? {
        guard let analyticsApiContext else {
//            AdyenAssertion.assertionFailure(
//                message: "AnalyticsProvider couldn't be created as AnalyticsAPIContext is not available."
//            )
            return nil
        }
        let analyticsApiClient = APIClient(apiContext: analyticsApiContext)

        var eventAnalyticsProvider: AnyEventAnalyticsProvider?

        if let checkoutAttemptId,
           analyticsConfiguration.isEnabled {
            let eventDataSource = AnalyticsEventDataSource()
            let syncEventDataSource = ThreadSafeAnalyticsEventDataSource(dataSource: eventDataSource)
            eventAnalyticsProvider = EventAnalyticsProvider(
                apiClient: analyticsApiClient,
                context: analyticsConfiguration.context,
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
