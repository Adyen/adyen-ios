//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenCheckout

extension CheckoutCallbacks {

    static func test(
        onComplete: @escaping CheckoutCompletionHandler = { _ in },
        onFailure: @escaping CheckoutFailureHandler = { _ in }
    ) -> Self {
        .init(onComplete: onComplete, onFailure: onFailure)
    }
}

extension AdvancedCheckoutCallbacks {

    static func test(
        onSubmit: @escaping CheckoutSubmitHandler = { _ in .retry() },
        onAdditionalDetails: @escaping CheckoutAdditionalDetailsHandler = { _ in .completion(resultCode: "") },
        onComplete: @escaping AdvancedCheckoutCompletionHandler = { _ in },
        onFailure: @escaping CheckoutFailureHandler = { _ in }
    ) -> Self {
        .init(
            onSubmit: onSubmit,
            onAdditionalDetails: onAdditionalDetails,
            onComplete: onComplete,
            onFailure: onFailure
        )
    }
}

extension ActionOnlyCheckoutCallbacks {

    static func test(
        onAdditionalDetails: @escaping CheckoutAdditionalDetailsHandler = { _ in .completion(resultCode: "") },
        onFailure: @escaping CheckoutFailureHandler = { _ in }
    ) -> Self {
        .init(onAdditionalDetails: onAdditionalDetails, onFailure: onFailure)
    }
}
