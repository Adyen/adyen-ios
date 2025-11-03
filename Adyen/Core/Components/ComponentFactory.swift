//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A factory that creates payment components for specific payment methods.
///
/// Each factory is responsible for creating a single type of payment component
/// with its corresponding configuration.
///
package protocol PaymentComponentFactory {
    
    /// The configuration type required by this factory to create components.
    associatedtype Configuration
    
    /// The specific payment method this factory handles.
    associatedtype Method: PaymentMethod
    
    /// The type of payment component this factory creates.
    associatedtype Component: PaymentComponent
    
    /// Creates a payment component for the given payment method and configuration.
    ///
    /// - Parameters:
    ///   - paymentMethod: The payment method for which to create a component.
    ///   - context: The context object.
    ///   - configuration: The configuration to use for component creation.
    /// - Returns: A configured payment component.
    func create(
        with paymentMethod: Method,
        context: AdyenContext,
        configuration: Configuration
    ) -> Component
    
    /// Creates the default configuration for the component.
    /// - Returns: A new configuration instance for the component.
    func defaultConfiguration() -> Configuration
}
