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

    /// Sets the callback invoked when checkout fails.
    /// - Parameter handler: Callback invoked with the checkout failure.
    ///   - error: The `CheckoutError` describing why the checkout flow failed.
    public func onFailure(_ handler: @escaping @MainActor (_ error: CheckoutError) -> Void) -> Self {
        resultCallbacks.onFailure = handler
        return self
    }

    /// Handles an action received from a payment or payment details response.
    public func handle(action: Action) {
        core.handle(action: action)
    }
}
