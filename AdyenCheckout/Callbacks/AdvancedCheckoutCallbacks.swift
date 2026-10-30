//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// The callbacks for the package-only advanced checkout flow.
package struct AdvancedCheckoutCallbacks: CheckoutResultCallbacks {

    package let onSubmit: CheckoutSubmitHandler
    package let onAdditionalDetails: CheckoutAdditionalDetailsHandler
    package let onComplete: AdvancedCheckoutCompletionHandler
    package let onFailure: CheckoutFailureHandler
    package private(set) var onAction: CheckoutActionHandler?
    package let additionalCallbacks: [any AdvancedCheckoutAdditionalCallbacks]

    package init(
        onSubmit: @escaping CheckoutSubmitHandler,
        onAdditionalDetails: @escaping CheckoutAdditionalDetailsHandler,
        onComplete: @escaping AdvancedCheckoutCompletionHandler,
        onFailure: @escaping CheckoutFailureHandler,
        @AdvancedAdditionalCallbacksBuilder additionalCallbacks: () -> [any AdvancedCheckoutAdditionalCallbacks] = { [] }
    ) {
        self.onSubmit = onSubmit
        self.onAdditionalDetails = onAdditionalDetails
        self.onComplete = onComplete
        self.onFailure = onFailure
        self.additionalCallbacks = additionalCallbacks()
    }

    package func onAction(_ handler: @escaping CheckoutActionHandler) -> Self {
        var callbacks = self
        callbacks.onAction = handler
        return callbacks
    }

    package func handleCompletion(resultCode: CheckoutResultCode, sessionId: String?, sessionResult: String?) {
        onComplete(AdvancedCheckoutResult(resultCode: resultCode))
    }
}
