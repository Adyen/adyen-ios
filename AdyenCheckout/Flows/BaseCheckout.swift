//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenActions)
    import AdyenActions
#endif
#if canImport(AdyenSession)
    import AdyenSession
#endif
import Foundation

/// Base checkout that supports action handling and final result callbacks.
@MainActor
public class BaseCheckout {

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
    /// - Parameter handler: Callback invoked with the final checkout result.
    ///   - result: The `CheckoutResult` containing the payment `resultCode` and, for session flows, an optional `sessionResult` that can be used on your server to retrieve the payment outcome.
    public func onComplete(_ handler: @escaping CheckoutSuccessHandler) -> Self {
        resultCallbacks.onComplete = handler
        return self
    }

    /// Sets the callback invoked when checkout fails.
    /// - Parameter handler: Callback invoked with the checkout failure.
    ///   - error: The `Error` describing why the checkout flow failed.
    public func onError(_ handler: @escaping CheckoutErrorHandler) -> Self {
        resultCallbacks.onError = handler
        return self
    }

    /// Handles an action received from a payment or payment details response.
    public func handle(action: Action) {
        core.handle(action: action)
    }
}
