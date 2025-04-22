//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

public struct CheckoutConfiguration {
    
    internal var amount: Amount
    
    @_spi(AdyenInternal)
    public var apiContext: APIContext
    
    // TODO: how we store configurations may change
    @_spi(AdyenInternal)
    public var configurations: [CheckoutComponentType: ConfigurationWrapper]
    
    internal var analyticsConfiguration: AnalyticsConfiguration
    
    internal var onSubmit: SubmitHandler?
    internal var onAdditionalDetails: AdditionalDetailsHandler?
    internal var onError: CheckoutErrorHandler?
    internal var onComplete: CheckoutSuccessHandler?
    
    /// Creates a CheckoutConfiguration instance.
    /// - Parameters:
    ///   - environment: The environment to retrieve internal resources from.
    ///   - amount: Payment amount.
    ///   - clientKey: The client key that corresponds to the web service user you will use for initiating the payment.
    ///   - content: Configuration builder to provide the desired configuration instances.
    ///   See https://docs.adyen.com/user-management/client-side-authentication for more information.
    /// - Throws: `ClientKeyError.invalidClientKey` if the client key is invalid.
    // swiftlint:disable vertical_parameter_alignment
    public init(
        environment: Environment,
        amount: Amount,
        clientKey: String,
        analyticsConfiguration: AnalyticsConfiguration = .init(),
        @CheckoutConfigurationBuilder content: () -> CheckoutConfigurable
    ) throws {
        self.apiContext = try APIContext(environment: environment, clientKey: clientKey)
        self.amount = amount
        self.analyticsConfiguration = analyticsConfiguration
        
        var configDictionary: [CheckoutComponentType: ConfigurationWrapper] = [:]
        let content = content()
        let configArray = (content as? CompositeCheckoutConfiguration)?.configurations ?? []
        
        for configuration in configArray {
            let wrappedConfiguration = ConfigurationWrapper(
                configuration: configuration,
                apiContext: apiContext,
                amount: amount
            )
            configDictionary[configuration.componentType] = wrappedConfiguration
        }
        self.configurations = configDictionary
    }
    
}
