//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

package protocol CheckoutResultCallbackStore: AnyObject {
    var onComplete: CheckoutSuccessHandler? { get set }

    var onError: CheckoutErrorHandler? { get set }
}

package final class SessionCheckoutCallbackStore: CheckoutResultCallbackStore {
    package var onComplete: CheckoutSuccessHandler?

    package var onError: CheckoutErrorHandler?
}

package final class AdvancedCheckoutCallbackStore: CheckoutResultCallbackStore {
    package var onSubmit: SubmitHandler?

    package var onAdditionalDetails: AdditionalDetailsHandler?

    package var onComplete: CheckoutSuccessHandler?

    package var onError: CheckoutErrorHandler?
}

package final class ActionOnlyCheckoutCallbackStore: CheckoutResultCallbackStore {
    package var onAdditionalDetails: AdditionalDetailsHandler?

    package var onComplete: CheckoutSuccessHandler?

    package var onError: CheckoutErrorHandler?
}
