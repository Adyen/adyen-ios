//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

package enum CheckoutCompletion {
    case session(resultCode: CheckoutResultCode, sessionId: String, sessionResult: String)
    case advanced(resultCode: CheckoutResultCode)
}

package protocol CheckoutResultCallbackStore: AnyObject {
    @MainActor
    func handleCompletion(_ completion: CheckoutCompletion)

    var onFailure: CheckoutFailureHandler? { get set }
}

package final class SessionCheckoutCallbackStore: CheckoutResultCallbackStore {
    package var onBeforeSubmit: BeforeSubmitHandler?

    package var onComplete: SessionCheckoutCompletionHandler?

    package var onFailure: CheckoutFailureHandler?

    package func handleCompletion(_ completion: CheckoutCompletion) {
        guard case let .session(resultCode, sessionId, sessionResult) = completion else {
            AdyenAssertion.assertionFailure(message: "Session completion called without sessionId or sessionResult.")
            return
        }
        onComplete?(SessionCheckoutResult(resultCode: resultCode, sessionId: sessionId, sessionResult: sessionResult))
    }
}

package final class AdvancedCheckoutCallbackStore: CheckoutResultCallbackStore {
    package var onSubmit: SubmitHandler?

    package var onAdditionalDetails: AdditionalDetailsHandler?

    package var onComplete: AdvancedCheckoutCompletionHandler?

    package var onFailure: CheckoutFailureHandler?

    package func handleCompletion(_ completion: CheckoutCompletion) {
        guard case let .advanced(resultCode) = completion else {
            AdyenAssertion.assertionFailure(message: "Advanced completion called with session result.")
            return
        }
        onComplete?(AdvancedCheckoutResult(resultCode: resultCode))
    }
}

package final class ActionOnlyCheckoutCallbackStore: CheckoutResultCallbackStore {
    package var onAdditionalDetails: AdditionalDetailsHandler?

    package var onComplete: AdvancedCheckoutCompletionHandler?

    package var onFailure: CheckoutFailureHandler?

    package func handleCompletion(_ completion: CheckoutCompletion) {
        guard case let .advanced(resultCode) = completion else {
            AdyenAssertion.assertionFailure(message: "Action-only completion called with session result.")
            return
        }
        onComplete?(AdvancedCheckoutResult(resultCode: resultCode))
    }
}
