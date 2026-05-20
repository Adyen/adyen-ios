//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// Checkout flow for integrations using the `/sessions` endpoint.
@MainActor
public final class SessionCheckout: PaymentCheckout {

    package let callbackStore: SessionCheckoutCallbackStore

    package init(core: CheckoutCoreProtocol, callbackStore: SessionCheckoutCallbackStore) {
        self.callbackStore = callbackStore
        super.init(core: core, resultCallbacks: callbackStore)
    }

    /// Sets the callback invoked before payment data is submitted to the session.
    /// Use this to inspect or modify payment data, or to abort the submission.
    public func onBeforeSubmit(_ handler: @escaping BeforeSubmitHandler) -> Self {
        callbackStore.onBeforeSubmit = handler
        return self
    }
}
