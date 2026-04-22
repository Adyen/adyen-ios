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

/// Result returned by the merchant's `onAdditionalDetails` callback in the advanced flow.
///
/// Mirrors the generic advanced-flow branch view for the details stage: `Finished | Error`.
public enum AdditionalDetailsResult: Sendable {
    
    /// The `/payments/details` call finished and carries a final `resultCode`.
    ///
    /// `resultCode` is always a `String`. When the underlying SDK delegate path does not carry a
    /// resultCode (e.g. `Checkout.didComplete(from:)` in the advanced, non-session flow), the SDK
    /// emits an empty string to keep the type uniform with `SubmitResult.finished` and with the
    /// Android callback surface.
    case finished(resultCode: String)
    
    /// An error occurred while handling the additional-details callback.
    case error(Error)
}

/// Payload carried on `SubmitResult.partialPayment`, describing the partial-payment continuation.
public struct PartialPayment: Sendable {
    
    /// The partial-payment order. `remainingAmount` is reachable via `order.remainingAmount`.
    public let order: PartialPaymentOrder
    
    /// Updated payment methods for the continuation flow. Optional because a session reload
    /// does not always produce a new list.
    public let paymentMethodsUpdate: PaymentMethods?
    
    public init(order: PartialPaymentOrder, paymentMethodsUpdate: PaymentMethods? = nil) {
        self.order = order
        self.paymentMethodsUpdate = paymentMethodsUpdate
    }
}
