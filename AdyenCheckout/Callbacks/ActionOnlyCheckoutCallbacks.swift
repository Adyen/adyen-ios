//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

/// A callbacks container for handling checkout actions without a session.
///
/// `ActionOnlyCheckoutCallbacks` defines how your integration responds to actions received from your server.
/// It allows you to:
/// - Send additional action details to your server.
/// - Handle action completion and failures.
/// - Customize how action view controllers are presented.
///
/// Provide the required additional-details and failure callbacks in the initializer, then add optional callbacks using modifiers.
/// Pass the callbacks to `Checkout.setup` to start the action-only flow.
///
/// For example:
/// ```swift
/// let callbacks = ActionOnlyCheckoutCallbacks(
///     onAdditionalDetails: { [weak self] data in
///         try await self?.callDetails(with: data)
///     },
///     onFailure: { error in
///         print(error.localizedDescription)
///     }
/// )
/// .onComplete { result in
///     print(result.resultCode)
/// }
/// ```
///
public struct ActionOnlyCheckoutCallbacks: CheckoutResultCallbacks {

    package let onAdditionalDetails: CheckoutAdditionalDetailsHandler
    package let onFailure: CheckoutFailureHandler
    package private(set) var onComplete: AdvancedCheckoutCompletionHandler?
    package private(set) var onAction: CheckoutActionHandler?

    /// Creates an ActionOnlyCheckoutCallbacks instance.
    /// - Parameters:
    ///   - onAdditionalDetails: Called when an action component provides data for `/payments/details`.
    ///     - data: The `ActionComponentData` containing the action `details` and optional `paymentData` from the previous response.
    ///     - Returns: An `AdditionalDetailsResult` describing how checkout should continue after submitting the details.
    ///   - onFailure: Called when action handling fails or the shopper cancels.
    ///     - error: The `CheckoutError` describing the failure or cancellation.
    public init(
        onAdditionalDetails: @escaping @MainActor @Sendable (_ data: ActionComponentData) async -> AdditionalDetailsResult,
        onFailure: @escaping @MainActor (_ error: CheckoutError) -> Void
    ) {
        self.onAdditionalDetails = onAdditionalDetails
        self.onFailure = onFailure
    }

    /// Sets a callback for the result code returned from your additional-details handler.
    ///
    /// - Parameter handler: The callback receiving the action-only checkout result.
    ///   - result: The ``AdvancedCheckoutResult`` containing the ``AdvancedCheckoutResult/resultCode`` returned by `onAdditionalDetails`.
    /// - Returns: A modified copy of the callbacks.
    public func onComplete(_ handler: @escaping @MainActor (_ result: AdvancedCheckoutResult) -> Void) -> Self {
        var callbacks = self
        callbacks.onComplete = handler
        return callbacks
    }

    /// Sets a callback to present an action's view controller.
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
        onComplete?(AdvancedCheckoutResult(resultCode: resultCode))
    }
}
