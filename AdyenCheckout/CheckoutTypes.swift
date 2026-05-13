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

/// Base checkout flow that supports action handling and final result callbacks.
@MainActor
public class CheckoutFlow {

    package let core: CheckoutCoreProtocol
    package let resultCallbacks: any CheckoutResultCallbackStore

    package var session: SessionProtocol? {
        core.session
    }

    package init(core: CheckoutCoreProtocol, resultCallbacks: any CheckoutResultCallbackStore) {
        self.core = core
        self.resultCallbacks = resultCallbacks
    }

    /// Sets the callback invoked when checkout completes successfully.
    public func onComplete(_ handler: @escaping CheckoutSuccessHandler) -> Self {
        resultCallbacks.onComplete = handler
        return self
    }

    /// Sets the callback invoked when checkout fails.
    public func onError(_ handler: @escaping CheckoutErrorHandler) -> Self {
        resultCallbacks.onError = handler
        return self
    }

    /// Handles an action received from a payment or payment details response.
    public func handle(action: Action) {
        core.handle(action: action)
    }
}

/// Base checkout flow that can create payment method components.
@MainActor
public class PaymentCheckoutFlow: CheckoutFlow {

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
    public func createDropIn() -> DropInComponent? {
        core.createDropIn()
    }
}

/// Checkout flow for integrations using the `/sessions` endpoint.
@MainActor
public final class SessionCheckout: PaymentCheckoutFlow {

    package let callbackStore: SessionCheckoutCallbackStore

    package init(core: CheckoutCoreProtocol, callbackStore: SessionCheckoutCallbackStore) {
        self.callbackStore = callbackStore
        super.init(core: core, resultCallbacks: callbackStore)
    }
}

/// Checkout flow for integrations handling `/payments` and `/payments/details` themselves.
@MainActor
public final class AdvancedCheckout: PaymentCheckoutFlow {

    package let callbackStore: AdvancedCheckoutCallbackStore

    package init(core: CheckoutCoreProtocol, callbackStore: AdvancedCheckoutCallbackStore) {
        self.callbackStore = callbackStore
        super.init(core: core, resultCallbacks: callbackStore)
    }

    /// Sets the callback invoked when payment data is submitted.
    public func onSubmit(_ handler: @escaping SubmitHandler) -> Self {
        callbackStore.onSubmit = handler
        return self
    }

    /// Sets the callback invoked when additional action details are submitted.
    public func onAdditionalDetails(_ handler: @escaping AdditionalDetailsHandler) -> Self {
        callbackStore.onAdditionalDetails = handler
        return self
    }
}

/// Checkout flow for integrations that only need to handle actions.
@MainActor
public final class ActionOnlyCheckout: CheckoutFlow {

    package let callbackStore: ActionOnlyCheckoutCallbackStore

    package init(core: CheckoutCoreProtocol, callbackStore: ActionOnlyCheckoutCallbackStore) {
        self.callbackStore = callbackStore
        super.init(core: core, resultCallbacks: callbackStore)
    }

    /// Sets the callback invoked when additional action details are submitted.
    public func onAdditionalDetails(_ handler: @escaping AdditionalDetailsHandler) -> Self {
        callbackStore.onAdditionalDetails = handler
        return self
    }
}
