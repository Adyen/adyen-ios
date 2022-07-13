//
// Copyright (c) 2022 Adyen N.V.
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
    public let analyticsProvider: AnalyticsProviderProtocol

    // MARK: - Initializers

    /// Creates an Adyen context with the provided API context and analytics configuration.
    /// - Parameters:
    ///   - apiContext: The API context used to retrieve internal resources.
    ///   - analyticsConfiguration: A configuration object that specifies the behavior for the analytics.
    ///   - payment: The payment information.
    public init(apiContext: APIContext, payment: Payment?, analyticsConfiguration: AnalyticsConfiguration = .init()) {
        self.apiContext = apiContext
        self.payment = payment

        let apiClient = APIClient(apiContext: apiContext)
        self.analyticsProvider = AnalyticsProvider(apiClient: apiClient,
                                                   configuration: analyticsConfiguration)
    }

    internal init(apiContext: APIContext,
                  payment: Payment?,
                  analyticsProvider: AnalyticsProviderProtocol) {
        self.apiContext = apiContext
        self.analyticsProvider = analyticsProvider
        self.payment = payment
    }

    @_spi(AdyenInternal)
    public func update(payment: Payment?) {
        self.payment = payment
    }
}
