//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation
import PassKit

@_spi(AdyenInternal)
extension ApplePayComponent: PKPaymentAuthorizationViewControllerDelegate {

    // MARK: - Did Finish

    public func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            Task { @MainActor in
                let wasCancelled = !self.authorizationHandled

                // If the continuation is still pending, the user dismissed before authorization completed.
                // Cancel it so the async didAuthorizePayment can return a failure.
                self.cancelPendingAuthorization()

                // Reset state for potential component reuse
                self.paymentAuthorizationViewController = nil
                self.authorizationHandled = false

                if wasCancelled {
                    self.delegate?.didFail(with: ComponentError.cancelled, from: self)
                }
            }
        }
    }

    // MARK: - Did Authorize (async)

    public func paymentAuthorizationViewController(
        _ controller: PKPaymentAuthorizationViewController,
        didAuthorizePayment payment: PKPayment
    ) async -> PKPaymentAuthorizationResult {
        await handleDidAuthorize(payment: payment)
    }

    // MARK: - Shipping Contact (async)

    public func paymentAuthorizationViewController(
        _ controller: PKPaymentAuthorizationViewController,
        didSelectShippingContact contact: PKContact
    ) async -> PKPaymentRequestShippingContactUpdate {
        await handleShippingContactChange(contact)
    }

    // MARK: - Shipping Method (async)

    public func paymentAuthorizationViewController(
        _ controller: PKPaymentAuthorizationViewController,
        didSelect shippingMethod: PKShippingMethod
    ) async -> PKPaymentRequestShippingMethodUpdate {
        await handleShippingMethodChange(shippingMethod)
    }

    // MARK: - Coupon Code (async)

    public func paymentAuthorizationViewController(
        _ controller: PKPaymentAuthorizationViewController,
        didChangeCouponCode couponCode: String
    ) async -> PKPaymentRequestCouponCodeUpdate {
        await handleCouponCodeChange(couponCode)
    }
}

// MARK: - @MainActor Helpers

//
// The async PKPaymentAuthorizationViewControllerDelegate methods run on the cooperative
// thread pool, not the main thread. All property access on ApplePayComponent (paymentRequest,
// paymentResultContinuation, delegate, configuration, submit, etc.) touches UIKit objects or
// mutable state that must be accessed on the main thread. These helpers ensure that.

extension ApplePayComponent {

    @MainActor
    private func handleDidAuthorize(payment: PKPayment) async -> PKPaymentAuthorizationResult {
        guard !payment.token.paymentData.isEmpty else {
            authorizationHandled = true
            delegate?.didFail(with: Error.invalidToken, from: self)
            return PKPaymentAuthorizationResult(status: .failure, errors: nil)
        }

        // Optional merchant validation via configuration closure
        if let onAuthorize = configuration.onAuthorize {
            let result = await onAuthorize(payment)
            guard result.status == .success else {
                authorizationHandled = true
                return result
            }
        }

        // Build payment details and submit to delegate (fire-and-forget)
        let token = payment.token.paymentData.base64EncodedString()
        let network = payment.token.paymentMethod.network?.rawValue ?? ""
        let details = ApplePayDetails(
            paymentMethod: applePayPaymentMethod,
            token: token,
            network: network,
            billingContact: payment.billingContact,
            shippingContact: payment.shippingContact,
            shippingMethod: payment.shippingMethod
        )

        let amount = configuration.currentAmount
        let data = PaymentComponentData(paymentMethodDetails: details, amount: amount, order: order)

        // Store the continuation first, then submit. submit() is fire-and-forget — it triggers
        // the delegate's didSubmit which eventually leads to resolve(success:) being called.
        // The continuation must be stored before submit so resolve() has something to resume.
        let success = await withCheckedContinuation { continuation in
            self.paymentResultContinuation = continuation
            self.submit(data: data)
        }

        authorizationHandled = true
        return PKPaymentAuthorizationResult(status: success ? .success : .failure, errors: nil)
    }

    @MainActor
    private func handleShippingContactChange(_ contact: PKContact) async -> PKPaymentRequestShippingContactUpdate {
        guard let onShippingContactChange = configuration.onShippingContactChange else {
            return PKPaymentRequestShippingContactUpdate(paymentSummaryItems: paymentRequest.paymentSummaryItems)
        }

        var result = await onShippingContactChange(contact, paymentRequest.paymentSummaryItems)
        result.paymentSummaryItems = validatedPaymentSummaryItems(from: result)
        return result
    }

    @MainActor
    private func handleShippingMethodChange(_ shippingMethod: PKShippingMethod) async -> PKPaymentRequestShippingMethodUpdate {
        guard let onShippingMethodChange = configuration.onShippingMethodChange else {
            return PKPaymentRequestShippingMethodUpdate(paymentSummaryItems: paymentRequest.paymentSummaryItems)
        }

        var result = await onShippingMethodChange(shippingMethod, paymentRequest.paymentSummaryItems)
        result.paymentSummaryItems = validatedPaymentSummaryItems(from: result)
        return result
    }

    @MainActor
    private func handleCouponCodeChange(_ couponCode: String) async -> PKPaymentRequestCouponCodeUpdate {
        guard let onCouponCodeChange = configuration.onCouponCodeChange else {
            return PKPaymentRequestCouponCodeUpdate(paymentSummaryItems: paymentRequest.paymentSummaryItems)
        }

        var result = await onCouponCodeChange(couponCode, paymentRequest.paymentSummaryItems)
        result.paymentSummaryItems = validatedPaymentSummaryItems(from: result)
        return result
    }

    /// Validates the summary items from a merchant-returned update result.
    ///
    /// If the result indicates failure or has empty items, the current `paymentRequest.paymentSummaryItems`
    /// are returned unchanged.
    ///
    /// If validation fails, triggers an assertion failure and falls back to the
    /// previous valid summary items to keep the Apple Pay sheet in a consistent state.
    ///
    /// Otherwise the new items are accepted and stored on `paymentRequest`.
    @MainActor
    private func validatedPaymentSummaryItems(from result: some PKPaymentRequestUpdate) -> [PKPaymentSummaryItem] {
        guard result.status == .success, !result.paymentSummaryItems.isEmpty else {
            return paymentRequest.paymentSummaryItems
        }
        do {
            try Configuration.validate(summaryItems: result.paymentSummaryItems)
            paymentRequest.paymentSummaryItems = result.paymentSummaryItems
            return result.paymentSummaryItems
        } catch {
            AdyenAssertion.assertionFailure(
                message: "Invalid payment summary items returned by merchant callback — \(error.localizedDescription). Falling back to previous valid items."
            )
            return paymentRequest.paymentSummaryItems
        }
    }
}
