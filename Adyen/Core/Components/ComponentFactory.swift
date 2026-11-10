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

    /// The callbacks type the component receives. `Never` when the component has no callbacks.
    associatedtype Callbacks = Never
    
    /// Returns whether a component can currently be created for the payment method.
    ///
    /// Every factory implements this explicitly, so adding a factory requires a deliberate availability decision.
    ///
    /// Implementations must be synchronous and free of side effects. A factory that can return `false`
    /// must enforce the same prerequisites in ``create(with:context:configuration:callbacks:)``,
    /// because callers may create a component without checking availability first.
    ///
    /// - Parameters:
    ///   - paymentMethod: The payment method to check.
    ///   - configuration: The resolved configuration that component creation would use.
    /// - Returns: `true` if a component can currently be created; otherwise, `false`.
    func isAvailable(
        for paymentMethod: Method,
        configuration: Configuration
    ) -> Bool
    
    /// Creates a payment component for the given payment method and configuration.
    ///
    /// - Parameters:
    ///   - paymentMethod: The payment method for which to create a component.
    ///   - context: The context object.
    ///   - configuration: The configuration to use for component creation.
    ///   - callbacks: The merchant callbacks for the component, if supplied.
    /// - Returns: A configured payment component.
    func create(
        with paymentMethod: Method,
        context: AdyenContext,
        configuration: Configuration,
        callbacks: Callbacks?
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

    /// Resolves the component's callbacks from the merchant's additional callbacks.
    ///
    /// The default implementation returns the last entry of type ``Callbacks``.
    /// Implement it only when the component combines several merchant callbacks types.
    ///
    /// - Parameter store: The additional callbacks supplied by the merchant.
    /// - Returns: The callbacks to pass to ``create(with:context:configuration:callbacks:)``.
    func callbacks(from store: AdditionalCallbacksStore) -> Callbacks?
}

package extension PaymentComponentFactory {

    /// Returns the last entry of type ``PaymentComponentFactory/Callbacks``.
    ///
    /// `callbacks(from:)` must stay a protocol requirement. As an extension-only method,
    /// generic callers would always use this default and skip a factory's own implementation.
    func callbacks(from store: AdditionalCallbacksStore) -> Callbacks? {
        store.callbacks(of: Callbacks.self)
    }
}
