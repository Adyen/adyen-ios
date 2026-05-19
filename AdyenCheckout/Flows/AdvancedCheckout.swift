//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen

/// Checkout flow for integrations handling `/payments` and `/payments/details` themselves.
@MainActor
public final class AdvancedCheckout: PaymentCheckout {

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
