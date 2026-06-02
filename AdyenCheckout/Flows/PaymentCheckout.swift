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
    public func createPaymentComponent(for type: PaymentMethodType) throws -> CheckoutPaymentComponent {
        try core.createPaymentComponent(for: type)
    }

    /// Creates a payment component for a stored payment method identifier.
    public func createPaymentComponent(for identifier: String) throws -> CheckoutPaymentComponent {
        try core.createPaymentComponent(for: identifier)
    }

    /// Creates a Drop-in component with all available payment methods.
    public func createDropIn() -> (any AnyDropInComponent)? {
        core.createDropIn()
    }
}
