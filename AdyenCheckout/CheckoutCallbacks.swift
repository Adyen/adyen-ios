//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen

package protocol CheckoutResultCallbacks: AnyObject {
    var onComplete: CheckoutSuccessHandler? { get set }

    var onError: CheckoutErrorHandler? { get set }
}

package final class SessionCheckoutCallbacks: CheckoutResultCallbacks {
    package var onComplete: CheckoutSuccessHandler?

    package var onError: CheckoutErrorHandler?
}

package final class AdvancedCheckoutCallbacks: CheckoutResultCallbacks {
    package var onSubmit: SubmitHandler?

    package var onAdditionalDetails: AdditionalDetailsHandler?

    package var onComplete: CheckoutSuccessHandler?

    package var onError: CheckoutErrorHandler?
}

package final class ActionOnlyCheckoutCallbacks: CheckoutResultCallbacks {
    package var onComplete: CheckoutSuccessHandler?

    package var onError: CheckoutErrorHandler?
}
