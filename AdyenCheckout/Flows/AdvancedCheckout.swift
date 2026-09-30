//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// Checkout flow for integrations handling `/payments` and `/payments/details` themselves.
@MainActor
public final class AdvancedCheckout: PaymentCheckout {

    package let callbackStore: AdvancedCheckoutCallbackStore

    package init(core: CheckoutCoreProtocol, callbackStore: AdvancedCheckoutCallbackStore) {
        self.callbackStore = callbackStore
        super.init(core: core, resultCallbacks: callbackStore)
    }

    /// Sets the callback invoked when checkout completes successfully.
    /// - Parameter handler: Callback invoked with the final checkout result.
    ///   - result: The ``AdvancedCheckoutResult`` containing the payment ``AdvancedCheckoutResult/resultCode``
    ///     indicating the outcome of the payment.
    public func onComplete(_ handler: @escaping @MainActor (_ result: AdvancedCheckoutResult) -> Void) -> Self {
        callbackStore.onComplete = handler
        return self
    }

    /// Sets the callback invoked when payment data is submitted.
    /// - Parameter handler: Callback invoked when a payment component submits payment data.
    ///   - data: The `PaymentComponentData` containing the selected payment method details and
    ///   any shopper or browser information collected by the component.
    /// - Returns: A `SubmitResult` describing how checkout should continue, such as completion,
    /// presenting an action, retry, or partial payment handling.
    public func onSubmit(_ handler: @escaping SubmitHandler) -> Self {
        callbackStore.onSubmit = handler
        return self
    }

    /// Sets the callback invoked when additional action details are submitted.
    /// - Parameter handler: Callback invoked when an action component provides data for `/payments/details`.
    ///   - data: The `ActionComponentData` containing the action `details` and
    ///   optional `paymentData` returned by the previous `/payments` response.
    /// - Returns: An `AdditionalDetailsResult` describing how checkout should continue after the details are submitted.
    public func onAdditionalDetails(_ handler: @escaping AdditionalDetailsHandler) -> Self {
        callbackStore.onAdditionalDetails = handler
        return self
    }
}
