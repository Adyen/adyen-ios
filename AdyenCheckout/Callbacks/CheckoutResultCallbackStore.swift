//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

package protocol CheckoutResultCallbackStore: AnyObject {
    @MainActor
    func handleCompletion(resultCode: CheckoutResultCode, sessionId: String?, sessionResult: String?)

    var onFailure: CheckoutFailureHandler? { get set }
}

package final class SessionCheckoutCallbackStore: CheckoutResultCallbackStore {
    package var onBeforeSubmit: BeforeSubmitHandler?

    package var onComplete: SessionCheckoutCompletionHandler?

    package var onFailure: CheckoutFailureHandler?

    package func handleCompletion(resultCode: CheckoutResultCode, sessionId: String?, sessionResult: String?) {
        guard let sessionId, let sessionResult else { return }
        onComplete?(SessionCheckoutResult(resultCode: resultCode, sessionId: sessionId, sessionResult: sessionResult))
    }
}

package final class AdvancedCheckoutCallbackStore: CheckoutResultCallbackStore {
    package var onSubmit: SubmitHandler?

    package var onAdditionalDetails: AdditionalDetailsHandler?

    package var onComplete: AdvancedCheckoutCompletionHandler?

    package var onFailure: CheckoutFailureHandler?

    package func handleCompletion(resultCode: CheckoutResultCode, sessionId: String?, sessionResult: String?) {
        onComplete?(AdvancedCheckoutResult(resultCode: resultCode))
    }
}

package final class ActionOnlyCheckoutCallbackStore: CheckoutResultCallbackStore {
    package var onAdditionalDetails: AdditionalDetailsHandler?

    package var onComplete: AdvancedCheckoutCompletionHandler?

    package var onFailure: CheckoutFailureHandler?

    package func handleCompletion(resultCode: CheckoutResultCode, sessionId: String?, sessionResult: String?) {
        onComplete?(AdvancedCheckoutResult(resultCode: resultCode))
    }
}
