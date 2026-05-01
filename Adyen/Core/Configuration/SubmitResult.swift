//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Result returned by `onSubmit` callback in the advanced flow.
///
/// Mirrors the generic advanced-flow branch view: `Completion | Action | Retry | PartialPayment`.
/// Infrastructure failures are signaled by throwing from the callback (the SDK routes thrown
/// errors to `onError`).
public enum SubmitResult: Sendable {
    
    /// The `/payments` call completed and carries a final `resultCode`.
    case completion(resultCode: String)
    
    /// The `/payments` call returned an action that must be handled by the SDK.
    case action(Action)
    
    /// The SDK should re-prompt the shopper. Loops back into the next `onSubmit`.
    ///
    /// - Parameter errorMessage: Optional shopper-facing message the SDK can surface before
    ///   re-prompting.
    case retry(errorMessage: String? = nil)
    
    /// A partial-payment continuation is required. The SDK will loop back into `onSubmit`
    /// with the updated order and payment methods.
    case partialPayment(PartialPayment)
}

/// Payload carried on `SubmitResult.partialPayment`, describing the partial-payment continuation.
/// TODO: Revisit whether this should be nested in `SubmitResult` when adding Drop-in support.
public struct PartialPayment: Sendable {
    
    /// The partial-payment order. `remainingAmount` is reachable via `order.remainingAmount`.
    public let order: PartialPaymentOrder
    
    /// Updated payment methods for the continuation flow. Callers must always provide an updated
    /// list when returning a partial-payment continuation.
    public let paymentMethods: PaymentMethods
    
    public init(order: PartialPaymentOrder, paymentMethods: PaymentMethods) {
        self.order = order
        self.paymentMethods = paymentMethods
    }
}
