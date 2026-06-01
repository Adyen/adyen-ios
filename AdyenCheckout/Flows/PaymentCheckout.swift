//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenDropIn)
    import AdyenDropIn
#endif
import Foundation

/// Base checkout that can create payment method components.
@MainActor
public class PaymentCheckout: BaseCheckout {

    /// The payment methods available for this checkout flow.
    public var paymentMethods: PaymentMethods? {
        core.paymentMethods
    }

    /// Creates a payment component for the specified payment method type.
    ///
    /// - Parameter type: The type of payment method to create a component for.
    /// - Returns: A configured ``CheckoutPaymentComponent``.
    /// - Throws: ``CheckoutError`` with code ``CheckoutError/Code/unknown`` if the payment method
    ///   is not available in the current payment methods, is not supported, or cannot be
    ///   initialized on this device (e.g. Apple Pay hardware check failed).
    public func createPaymentComponent(for type: PaymentMethodType) throws -> CheckoutPaymentComponent {
        do {
            return try core.createPaymentComponent(for: type)
        } catch {
            throw CheckoutError.map(error)
        }
    }

    /// Creates a payment component for a stored payment method identifier.
    ///
    /// - Parameter identifier: The unique identifier of the stored payment method.
    /// - Returns: A configured ``CheckoutPaymentComponent``.
    /// - Throws: ``CheckoutError`` with code ``CheckoutError/Code/unknown`` if no stored
    ///   payment method matching `identifier` exists.
    public func createPaymentComponent(for identifier: String) throws -> CheckoutPaymentComponent {
        do {
            return try core.createPaymentComponent(for: identifier)
        } catch {
            throw CheckoutError.map(error)
        }
    }

    /// Creates a Drop-in component with all available payment methods.
    public func createDropIn() -> (any AnyDropInComponent)? {
        core.createDropIn()
    }
}
