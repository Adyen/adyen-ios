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
    public var paymentMethods: [PaymentMethod] {
        core.paymentMethods?.regular ?? []
    }

    /// The stored payment methods available for this checkout flow.
    public var storedPaymentMethods: [StoredPaymentMethod] {
        core.paymentMethods?.stored ?? []
    }

    /// Creates a payment component for the specified payment method type.
    ///
    /// - Parameter type: The type of payment method to create a component for.
    /// - Returns: A configured ``CheckoutPaymentComponent``.
    /// - Throws: ``CheckoutError`` with code ``CheckoutError/Code/paymentMethodFailure`` if the payment method
    ///   is not available in the current payment methods, is not supported, or cannot be
    ///   initialized on this device (e.g. Apple Pay hardware check failed).
    public func createPaymentComponent(for type: PaymentMethodType) throws -> CheckoutPaymentComponent {
        do {
            return try core.createPaymentComponent(for: type)
        } catch {
            throw CheckoutError(error: error)
        }
    }

    /// Creates a payment component for a stored payment method identifier.
    ///
    /// - Parameter identifier: The unique identifier of the stored payment method.
    /// - Returns: A configured ``CheckoutPaymentComponent``.
    /// - Throws: ``CheckoutError`` with code ``CheckoutError/Code/paymentMethodFailure`` if no stored
    ///   payment method matching `identifier` exists.
    public func createPaymentComponent(for identifier: String) throws -> CheckoutPaymentComponent {
        do {
            return try core.createPaymentComponent(for: identifier)
        } catch {
            throw CheckoutError(error: error)
        }
    }

    /// Creates a Drop-in component with all available supported payment methods.
    ///
    /// Each call returns a new Drop-in component.
    ///
    /// - Returns: A configured ``CheckoutDropInComponent``.
    /// - Throws: ``CheckoutError`` with code ``CheckoutError/Code/paymentMethodFailure`` if no supported
    ///   payment method can be assembled.
    public func createDropIn() throws -> CheckoutDropInComponent {
        do {
            return try core.createDropIn()
        } catch {
            throw CheckoutError(error: error, fallback: .paymentMethodFailure)
        }
    }
}
