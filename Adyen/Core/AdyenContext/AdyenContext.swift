//
// Copyright (c) Adyen N.V.
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
    
    package let analyticsProvider: AnyAnalyticsProvider?
    
    package let amount: Amount
    
    // MARK: - Initializers
    
    /// Creates an Adyen context with the provided API context and analytics configuration.
    /// - Parameters:
    ///   - apiContext: The API context used to retrieve internal resources.
    ///   - analyticsConfiguration: A configuration object that specifies the behavior for the analytics.
    ///   - payment: The payment information.
    public convenience init(
        apiContext: APIContext,
        payment: Payment?,
        amount: Amount,
        analyticsConfiguration: AnalyticsConfiguration = .init()
    ) {
        
        let analyticsProvider = Self.createAnalyticsProvider(
            apiContext: apiContext,
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
    
    private static func createAnalyticsProvider(apiContext: APIContext, analyticsConfiguration: AnalyticsConfiguration) -> AnyAnalyticsProvider? {
        guard
            let analyticsEnvironment = (apiContext.environment as? Environment)?.toAnalyticsEnvironment(),
            let analyticsApiContext = try? APIContext(
                environment: analyticsEnvironment,
                clientKey: apiContext.clientKey
            )
        else {
            AdyenAssertion.assertionFailure(
                message: "AnalyticsProvider couldn't be created. Ensure the used environment is of type `Environment`"
            )
            return nil
        }

        var eventAnalyticsProvider: AnyEventAnalyticsProvider?
        
        if analyticsConfiguration.isEnabled {
            let eventDataSource = AnalyticsEventDataSource()
            let syncEventDataSource = ThreadSafeAnalyticsEventDataSource(dataSource: eventDataSource)
            eventAnalyticsProvider = EventAnalyticsProvider(
                apiClient: APIClient(apiContext: analyticsApiContext),
                context: analyticsConfiguration.context,
                eventDataSource: syncEventDataSource
            )
        }
        
        return AnalyticsProvider(
            apiClient: APIClient(apiContext: analyticsApiContext),
            configuration: analyticsConfiguration,
            eventAnalyticsProvider: eventAnalyticsProvider
        )
    }
}
