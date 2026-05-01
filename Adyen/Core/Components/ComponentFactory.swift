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
@MainActor
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
    ) throws -> Component
    
    /// Returns a default configuration for this factory's component.
    ///
    /// Most factories can construct a usable default. Some (e.g. Apple Pay) cannot, because
    /// their configuration requires merchant-specific values; those factories throw to make
    /// the missing-configuration case explicit at the call site.
    ///
    /// - Returns: A configured ``Configuration`` instance.
    /// - Throws: An error if no usable default exists for this factory.
    func defaultConfiguration() throws -> Configuration
}
