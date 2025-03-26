//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

public struct CheckoutConfiguration {
    
    // TODO: Use AnyAPIEnvironment?
    internal var environment: Environment
    
    internal var amount: Amount
    
    internal var clientKey: String
    
    // TODO: how we store configurations may change
    internal var configurations: [String: CheckoutConfigurable]
    
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
    public init(
        environment: Environment,
        amount: Amount,
        clientKey: String, @ConfigurationBuilder content: () -> CheckoutConfigurable
    ) throws {
        guard ClientKeyValidator().isValid(clientKey) else {
            throw ClientKeyError.invalidClientKey
        }
        
        self.environment = environment
        self.amount = amount
        self.clientKey = clientKey
        
        let content = content()
        let configArray = (content as? CompositeCheckoutConfiguration)?.configurations ?? [content]
        var configDictionary: [String: CheckoutConfigurable] = [:]
        
        // Should dictionary hold ALL configs beforehand and update new ones?
        for configuration in configArray {
            configDictionary[String(describing: configuration.self)] = configuration
        }
        self.configurations = configDictionary
    }
}


