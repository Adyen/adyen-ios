//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import PassKit

/// A callbacks container for handling Apple Pay sheet events.
///
/// Include `ApplePayCallbacks` in the additional callbacks block of `CheckoutCallbacks` to:
/// - Validate the shopper's payment information before the payment is submitted.
/// - Update the summary items when the shopper changes the shipping contact, shipping method,
///   coupon code or payment method on the Apple Pay sheet.
///
/// For example:
/// ```swift
/// ApplePayCallbacks()
///     .onAuthorize { payment in
///         PKPaymentAuthorizationResult(status: .success, errors: nil)
///     }
///     .onSelectShippingMethod { shippingMethod, summaryItems in
///         PKPaymentRequestShippingMethodUpdate(paymentSummaryItems: summaryItems)
///     }
/// ```
public struct ApplePayCallbacks: CheckoutAdditionalCallbacks, AdvancedCheckoutAdditionalCallbacks {

    package private(set) var onAuthorize: (@MainActor @Sendable (PKPayment) async -> PKPaymentAuthorizationResult)?

    package private(set) var onSelectShippingContact: (
        @MainActor @Sendable (
            PKContact,
            [PKPaymentSummaryItem]
        ) async -> PKPaymentRequestShippingContactUpdate
    )?

    package private(set) var onSelectShippingMethod: (
        @MainActor @Sendable (
            PKShippingMethod,
            [PKPaymentSummaryItem]
        ) async -> PKPaymentRequestShippingMethodUpdate
    )?

    package private(set) var onChangeCouponCode: (
        @MainActor @Sendable (
            String,
            [PKPaymentSummaryItem]
        ) async -> PKPaymentRequestCouponCodeUpdate
    )?

    package private(set) var onSelectPaymentMethod: (
        @MainActor @Sendable (
            PKPaymentMethod,
            [PKPaymentSummaryItem]
        ) async -> PKPaymentRequestPaymentMethodUpdate
    )?

    /// Creates an ApplePayCallbacks instance without optional handlers.
    public init() {}

    /// Sets the handler called when the shopper authorizes the payment, before the payment is submitted.
    ///
    /// Use this closure to validate the shopper's payment information (e.g., billing/shipping address)
    /// before the payment is submitted. You can perform synchronous or asynchronous validation,
    /// including backend calls if needed.
    ///
    /// Return `.success` to proceed with submission, or `.failure` with errors to let the shopper retry.
    ///
    /// - Note: Return `.failure` with non-empty `errors` to keep the sheet open for correction.
    ///   Use `PKPaymentRequest.paymentBillingAddressInvalidError(withKey:localizedDescription:)` or similar
    ///   factory methods to create field-specific errors. If `errors` parameter is empty, the system will dismiss
    ///   the sheet.
    /// - Parameter handler: The closure to call when the payment is authorized.
    ///   - payment: The `PKPayment` object containing the payment token, billing/shipping contact, and shipping method.
    ///   - Returns: A `PKPaymentAuthorizationResult` indicating success or failure with optional field-specific errors.
    /// - Returns: A modified copy of the callbacks.
    public func onAuthorize(
        _ handler: @escaping @MainActor @Sendable (_ payment: PKPayment) async -> PKPaymentAuthorizationResult
    ) -> Self {
        var callbacks = self
        callbacks.onAuthorize = handler
        return callbacks
    }

    /// Sets the handler called when the shopper selects a shipping contact.
    ///
    /// Return an updated `PKPaymentRequestShippingContactUpdate` with revised summary items
    /// and optionally updated shipping methods or errors.
    /// - Parameter handler: The closure to call when the shopper selects a shipping contact.
    ///   - contact: The selected `PKContact` containing the shipping address and contact information.
    ///   - summaryItems: The current array of `PKPaymentSummaryItem` objects representing line items and total.
    ///   - Returns: A `PKPaymentRequestShippingContactUpdate` with updated summary items, shipping methods, and/or errors.
    /// - Returns: A modified copy of the callbacks.
    public func onSelectShippingContact(
        _ handler: @escaping @MainActor @Sendable (
            _ contact: PKContact,
            _ summaryItems: [PKPaymentSummaryItem]
        ) async -> PKPaymentRequestShippingContactUpdate
    ) -> Self {
        var callbacks = self
        callbacks.onSelectShippingContact = handler
        return callbacks
    }

    /// Sets the handler called when the shopper selects a shipping method.
    ///
    /// Return an updated `PKPaymentRequestShippingMethodUpdate` with revised summary items.
    /// - Parameter handler: The closure to call when the shopper selects a shipping method.
    ///   - shippingMethod: The selected `PKShippingMethod` containing the shipping option details.
    ///   - summaryItems: The current array of `PKPaymentSummaryItem` objects representing line items and total.
    ///   - Returns: A `PKPaymentRequestShippingMethodUpdate` with updated summary items reflecting the new shipping cost.
    /// - Returns: A modified copy of the callbacks.
    public func onSelectShippingMethod(
        _ handler: @escaping @MainActor @Sendable (
            _ shippingMethod: PKShippingMethod,
            _ summaryItems: [PKPaymentSummaryItem]
        ) async -> PKPaymentRequestShippingMethodUpdate
    ) -> Self {
        var callbacks = self
        callbacks.onSelectShippingMethod = handler
        return callbacks
    }

    /// Sets the handler called when the shopper enters or updates a coupon code.
    ///
    /// Return an updated `PKPaymentRequestCouponCodeUpdate` with revised summary items.
    /// - Parameter handler: The closure to call when the shopper enters or updates a coupon code.
    ///   - couponCode: The entered or updated coupon code string.
    ///   - summaryItems: The current array of `PKPaymentSummaryItem` objects representing line items and total.
    ///   - Returns: A `PKPaymentRequestCouponCodeUpdate` with updated summary items reflecting the applied discount
    ///    or errors if the code is invalid.
    /// - Returns: A modified copy of the callbacks.
    public func onChangeCouponCode(
        _ handler: @escaping @MainActor @Sendable (
            _ couponCode: String,
            _ summaryItems: [PKPaymentSummaryItem]
        ) async -> PKPaymentRequestCouponCodeUpdate
    ) -> Self {
        var callbacks = self
        callbacks.onChangeCouponCode = handler
        return callbacks
    }

    /// Sets the handler called when the shopper selects a payment method.
    ///
    /// Return an updated `PKPaymentRequestPaymentMethodUpdate` with revised summary items.
    /// - Parameter handler: The closure to call when the payment method changes.
    ///   - paymentMethod: The selected `PKPaymentMethod` containing the payment card details.
    ///   - summaryItems: The current array of `PKPaymentSummaryItem` objects representing line items and total.
    ///   - Returns: A `PKPaymentRequestPaymentMethodUpdate` with updated summary items reflecting any changes based on the payment method.
    /// - Returns: A modified copy of the callbacks.
    public func onSelectPaymentMethod(
        _ handler: @escaping @MainActor @Sendable (
            _ paymentMethod: PKPaymentMethod,
            _ summaryItems: [PKPaymentSummaryItem]
        ) async -> PKPaymentRequestPaymentMethodUpdate
    ) -> Self {
        var callbacks = self
        callbacks.onSelectPaymentMethod = handler
        return callbacks
    }
}
