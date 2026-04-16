//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

public typealias SubmitHandler = @MainActor @Sendable (_ data: PaymentComponentData) async -> CheckoutPaymentsResponse
public typealias AdditionalDetailsHandler = @MainActor @Sendable (_ data: ActionComponentData) async -> CheckoutPaymentsResponse
public typealias CheckoutErrorHandler = (_ error: Error) -> Void
public typealias CheckoutSuccessHandler = (_ result: CheckoutResult) -> Void

/// Basic callbacks for all components.
package protocol CheckoutBaseCallbacks {
    
    var onSubmit: SubmitHandler? { get set }
    
    var onAdditionalDetails: AdditionalDetailsHandler? { get set }
    
    var onError: CheckoutErrorHandler? { get set }
    
    var onComplete: CheckoutSuccessHandler? { get set }
}
