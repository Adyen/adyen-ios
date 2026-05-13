//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenActions)
    import AdyenActions
#endif
#if canImport(AdyenDropIn)
    import AdyenDropIn
#endif
#if canImport(AdyenSession)
    import AdyenSession
#endif

/// A checkout flow that can handle payment actions returned by the Adyen API.
@MainActor
public protocol CheckoutActionHandling: AnyObject {
    /// Handles an action received from a payment or payment details response.
    func handle(action: Action)
}

/// A checkout flow that can create payment method components.
@MainActor
public protocol CheckoutPaymentMethodHandling: CheckoutActionHandling {
    /// The payment methods available for this checkout flow.
    var paymentMethods: PaymentMethods? { get }

    /// Creates a payment component for the specified payment method type.
    func createPaymentComponent(for type: PaymentMethodType) throws -> CheckoutPaymentComponent

    /// Creates a payment component for a stored payment method identifier.
    func createPaymentComponent(for identifier: String) throws -> CheckoutPaymentComponent

    /// Creates a Drop-in component with all available payment methods.
    func createDropIn() -> DropInComponent?
}

/// Base checkout flow that supports action handling and final result callbacks.
@MainActor
public class ActionCheckout: CheckoutActionHandling {

    package let core: CheckoutCoreProtocol
    package let resultCallbacks: any CheckoutResultCallbacks

    package var session: SessionProtocol? {
        core.session
    }

    package init(core: CheckoutCoreProtocol, resultCallbacks: any CheckoutResultCallbacks) {
        self.core = core
        self.resultCallbacks = resultCallbacks
    }

    /// Sets the callback invoked when checkout completes successfully.
    @discardableResult
    public func onComplete(_ handler: @escaping CheckoutSuccessHandler) -> Self {
        resultCallbacks.onComplete = handler
        return self
    }

    /// Sets the callback invoked when checkout fails.
    @discardableResult
    public func onError(_ handler: @escaping CheckoutErrorHandler) -> Self {
        resultCallbacks.onError = handler
        return self
    }

    public func handle(action: Action) {
        core.handle(action: action)
    }
}

/// Base checkout flow that supports payment method component creation.
@MainActor
public class PaymentCheckout: ActionCheckout, CheckoutPaymentMethodHandling {

    public var paymentMethods: PaymentMethods? {
        core.paymentMethods
    }

    public func createPaymentComponent(for type: PaymentMethodType) throws -> CheckoutPaymentComponent {
        try core.createPaymentComponent(for: type)
    }

    public func createPaymentComponent(for identifier: String) throws -> CheckoutPaymentComponent {
        try core.createPaymentComponent(for: identifier)
    }

    public func createDropIn() -> DropInComponent? {
        core.createDropIn()
    }
}

/// Checkout flow for integrations using the `/sessions` endpoint.
@MainActor
public final class SessionCheckout: PaymentCheckout {

    package let callbacks: SessionCheckoutCallbacks

    package init(core: CheckoutCoreProtocol, callbacks: SessionCheckoutCallbacks) {
        self.callbacks = callbacks
        super.init(core: core, resultCallbacks: callbacks)
    }
}

/// Checkout flow for integrations handling `/payments` and `/payments/details` themselves.
@MainActor
public final class AdvancedCheckout: PaymentCheckout {

    package let callbacks: AdvancedCheckoutCallbacks

    package init(core: CheckoutCoreProtocol, callbacks: AdvancedCheckoutCallbacks) {
        self.callbacks = callbacks
        super.init(core: core, resultCallbacks: callbacks)
    }

    /// Sets the callback invoked when payment data is submitted.
    @discardableResult
    public func onSubmit(_ handler: @escaping SubmitHandler) -> Self {
        callbacks.onSubmit = handler
        return self
    }

    /// Sets the callback invoked when additional action details are submitted.
    @discardableResult
    public func onAdditionalDetails(_ handler: @escaping AdditionalDetailsHandler) -> Self {
        callbacks.onAdditionalDetails = handler
        return self
    }
}

/// Checkout flow for integrations that only need to handle actions.
@MainActor
public final class ActionOnlyCheckout: ActionCheckout {

    package let callbacks: ActionOnlyCheckoutCallbacks

    package init(core: CheckoutCoreProtocol, callbacks: ActionOnlyCheckoutCallbacks) {
        self.callbacks = callbacks
        super.init(core: core, resultCallbacks: callbacks)
    }
}
