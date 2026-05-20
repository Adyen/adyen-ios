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
    /// Use this to inspect or modify payment data, patch the session on your server, or abort the submission.
    ///
    /// If you patch the session on your server during this callback, pass the returned `sessionData`
    /// in `.proceed(data:sessionData:)` so the SDK can refresh the session state before continuing.
    /// - Parameter handler: Callback invoked before the session performs the `/payments` call.
    ///   - data: The `BeforeSubmitData` containing shopper fields that can be validated, modified, or passed back unchanged.
    /// - Returns: A `BeforeSubmitResult`. Return `.proceed(data:sessionData:)` to continue or `.abort` to stop the flow and reset the component state.
    public func onBeforeSubmit(_ handler: @escaping BeforeSubmitHandler) -> Self {
        callbackStore.onBeforeSubmit = handler
        return self
    }
}
