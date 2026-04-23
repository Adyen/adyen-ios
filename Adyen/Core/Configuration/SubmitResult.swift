//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Result returned by the merchant's `onSubmit` callback in the advanced flow.
///
/// Mirrors the generic advanced-flow branch view: `Finished | Action | Error | PartialPayment`.
public enum SubmitResult: Sendable {
    
    /// The `/payments` call finished and carries a final `resultCode`.
    case finished(resultCode: String)
    
    /// The `/payments` call returned an action that must be handled by the SDK.
    case action(Action)
    
    /// An error occurred while handling the submit callback.
    case error(Error)
    
    /// A partial-payment continuation is required. The SDK will loop back into `onSubmit`
    /// with the updated order and payment methods.
    case partialPayment(PartialPayment)
}

/// Payload carried on `SubmitResult.partialPayment`, describing the partial-payment continuation.
public struct PartialPayment: Sendable {
    
    /// The partial-payment order. `remainingAmount` is reachable via `order.remainingAmount`.
    public let order: PartialPaymentOrder
    
    /// Updated payment methods for the continuation flow. Optional because a session reload
    /// does not always produce a new list.
    public let paymentMethods: PaymentMethods?
    
    public init(order: PartialPaymentOrder, paymentMethods: PaymentMethods? = nil) {
        self.order = order
        self.paymentMethods = paymentMethods
    }
}
