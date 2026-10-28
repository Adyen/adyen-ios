//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

/// A callbacks container for handling checkout events.
///
/// `CheckoutCallbacks` defines how your integration responds to checkout events.
/// It allows you to:
/// - Handle payment completion and failures.
/// - Inspect or modify shopper data before submission.
/// - Customize how action view controllers are presented.
///
/// Provide the required completion and failure callbacks in the initializer, then add optional callbacks using modifiers.
/// Pass the callbacks to `Checkout.setup` when setting up checkout.
///
/// For example:
/// ```swift
/// let callbacks = CheckoutCallbacks(
///     onComplete: { result in
///         print(result.resultCode)
///     },
///     onFailure: { error in
///         print(error.localizedDescription)
///     }
/// )
/// .onBeforeSubmit { data in
///     .proceed(data: data, sessionData: nil)
/// }
/// ```
///
public struct CheckoutCallbacks: CheckoutResultCallbacks {

    package let onComplete: CheckoutCompletionHandler
    package let onFailure: CheckoutFailureHandler
    package private(set) var onBeforeSubmit: CheckoutBeforeSubmitHandler?
    package private(set) var onAction: CheckoutActionHandler?

    /// Creates a CheckoutCallbacks instance.
    /// - Parameters:
    ///   - onComplete: Called after the payment component finalizes.
    ///     - result: The ``CheckoutResult`` containing the ``CheckoutResult/resultCode``, ``CheckoutResult/sessionId``,
    ///       and ``CheckoutResult/sessionResult`` used to retrieve the payment outcome on your server.
    ///   - onFailure: Called after the payment component finalizes, when checkout fails or the shopper cancels.
    ///     - error: The `CheckoutError` describing the failure or cancellation.
    public init(
        onComplete: @escaping @MainActor (_ result: CheckoutResult) -> Void,
        onFailure: @escaping @MainActor (_ error: CheckoutError) -> Void
    ) {
        self.onComplete = onComplete
        self.onFailure = onFailure
    }

    /// Sets a callback to inspect or modify shopper data before submission.
    ///
    /// If you patch the session on your server, pass the updated `sessionData` in `.proceed(data:sessionData:)`.
    ///
    /// - Parameter handler: The callback invoked before the `/payments` call.
    ///   - data: The `BeforeSubmitData` containing shopper fields to validate, modify, or pass back unchanged.
    ///     Setting a field to `nil` preserves the value collected by the component.
    ///   - Returns: A `BeforeSubmitResult`: `.proceed(data:sessionData:)` to continue, or `.abort` to reset
    ///     the component without a failure callback.
    /// - Returns: A modified copy of the callbacks.
    public func onBeforeSubmit(
        _ handler: @escaping @MainActor @Sendable (_ data: BeforeSubmitData) async -> BeforeSubmitResult
    ) -> Self {
        var callbacks = self
        callbacks.onBeforeSubmit = handler
        return callbacks
    }

    /// Sets a callback to present an action's view controller.
    ///
    /// When unset, checkout presents on the initiating payment component.
    /// Drop-in presents its own actions without invoking this callback.
    ///
    /// - Parameter handler: The callback invoked before action presentation.
    ///   - actionData: The ``ActionData`` describing the action, including its ``ActionData/type``.
    ///   - actionViewController: The `UIViewController` the SDK built for the action.
    /// - Returns: A modified copy of the callbacks.
    public func onAction(
        _ handler: @escaping @MainActor @Sendable (_ actionData: ActionData, _ actionViewController: UIViewController) -> Void
    ) -> Self {
        var callbacks = self
        callbacks.onAction = handler
        return callbacks
    }

    package func handleCompletion(resultCode: CheckoutResultCode, sessionId: String?, sessionResult: String?) {
        guard let sessionId, let sessionResult else {
            AdyenAssertion.assertionFailure(message: "Session completion called without sessionId or sessionResult.")
            return
        }
        onComplete(CheckoutResult(resultCode: resultCode, sessionId: sessionId, sessionResult: sessionResult))
    }
}
