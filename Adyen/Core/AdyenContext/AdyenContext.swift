//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

/// A class that defines the behavior of the components in a payment flow.
public final class AdyenContext: PaymentAware {
    
    // MARK: - Properties
    
    /// The API context used to retrieve internal resources.
    public let apiContext: APIContext
    
    /// The payment information.
    public private(set) var payment: Payment?
    
    @_spi(AdyenInternal)
    public let analyticsProvider: AnalyticsProviderProtocol?
    
    // MARK: - Initializers
    
    /// Creates an Adyen context with the provided API context and analytics configuration.
    /// - Parameters:
    ///   - apiContext: The API context used to retrieve internal resources.
    ///   - analyticsConfiguration: A configuration object that specifies the behavior for the analytics.
    ///   - payment: The payment information.
    public convenience init(apiContext: APIContext, payment: Payment?, analyticsConfiguration: AnalyticsConfiguration = .init()) {
        
        let analyticsProvider = Self.createAnalyticsProvider(
            apiContext: apiContext,
            analyticsConfiguration: analyticsConfiguration
        )
        
        self.init(
            apiContext: apiContext,
            payment: payment,
            analyticsProvider: analyticsProvider
        )
    }
    
    /// Internal init for testing only
    internal init(
        apiContext: APIContext,
        payment: Payment?,
        analyticsProvider: AnalyticsProviderProtocol?
    ) {
        self.apiContext = apiContext
        self.analyticsProvider = analyticsProvider
        self.payment = payment
    }
    
    @_spi(AdyenInternal)
    public func update(payment: Payment?) {
        self.payment = payment
    }
    
    private static func createAnalyticsProvider(apiContext: APIContext, analyticsConfiguration: AnalyticsConfiguration) -> AnalyticsProviderProtocol? {
        guard
            let analyticsEnvironment = (apiContext.environment as? Environment)?.toAnalyticsEnvironment(),
            let analyticsApiContext = try? APIContext(
                environment: analyticsEnvironment,
                clientKey: apiContext.clientKey
            )
        else { return nil }
        
        let eventDataSource: AnyAnalyticsEventDataSource
        
        if analyticsConfiguration.isEnabled {
            eventDataSource = ThreadSafeAnalyticsEventDataSource(
                dataSource: AnalyticsEventDataSource()
            )
        } else {
            eventDataSource = DummyAnalyticsEventDataSource()
        }
        
        return AnalyticsProvider(
            apiClient: APIClient(apiContext: analyticsApiContext),
            configuration: analyticsConfiguration,
            eventDataSource: eventDataSource
        )
    }
}
