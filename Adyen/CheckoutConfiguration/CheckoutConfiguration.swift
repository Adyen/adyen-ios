//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

public struct CheckoutConfiguration {

    package var amount: Amount
    
    package var analyticsConfiguration: AnalyticsConfiguration
    
    package var apiContext: APIContext
    
    package var showsSubmitButton: Bool = true
    
    // TODO: how we store configurations may change
    package var configurations: [CheckoutComponentType: CheckoutComponentConfiguration]
    
    package var onSubmit: SubmitHandler?
    
    package var onAdditionalDetails: AdditionalDetailsHandler?
    
    package var onError: CheckoutErrorHandler?
    
    package var onComplete: CheckoutSuccessHandler?
    
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
        
        var configDictionary: [CheckoutComponentType: CheckoutComponentConfiguration] = [:]
        let content = content()
        let configArray = (content as? CompositeCheckoutConfiguration)?.configurations ?? []
        
        for configuration in configArray {
            if let configuration = configuration as? CheckoutComponentConfiguration {
                configDictionary[configuration.componentType] = configuration
            }
        }
        self.configurations = configDictionary
    }
    
    public func showsSubmitButton(_ showsSubmitButton: Bool) -> Self {
        var copy = self
        copy.showsSubmitButton = showsSubmitButton
        return copy
    }
    
}
