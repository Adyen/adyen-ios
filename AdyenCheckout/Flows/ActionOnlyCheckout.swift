//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// Checkout flow for integrations that only need to handle actions.
@MainActor
public final class ActionOnlyCheckout: BaseCheckout {

    package let callbackStore: ActionOnlyCheckoutCallbackStore

    package init(core: CheckoutCoreProtocol, callbackStore: ActionOnlyCheckoutCallbackStore) {
        self.callbackStore = callbackStore
        super.init(core: core, resultCallbacks: callbackStore)
    }

    /// Sets the callback invoked when additional action details are submitted.
    /// - Parameter handler: Callback invoked when an action component provides data for `/payments/details`.
    ///   - data: The `ActionComponentData` containing the action `details` and optional `paymentData` returned by the previous `/payments` response.
    /// - Returns: An `AdditionalDetailsResult` describing how checkout should continue after the details are submitted.
    public func onAdditionalDetails(_ handler: @escaping AdditionalDetailsHandler) -> Self {
        callbackStore.onAdditionalDetails = handler
        return self
    }
}
