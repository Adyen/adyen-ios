//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import PassKit

@_spi(AdyenInternal)
extension ApplePayComponent: PKPaymentAuthorizationViewControllerDelegate {

    // MARK: - Did Finish

    public func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true) { [weak self] in
            MainActor.assumeIsolated {
                guard let self, !self.authorizationHandled else { return }

                // Either user cancelled, or dismissed mid-authorization. Cancel current.
                self.cancelPendingAuthorization()
                self.delegate?.didFail(with: ComponentError.cancelled, from: self)
            }
        }
    }

    // MARK: - Did Authorize (async)

    public func paymentAuthorizationViewController(
        _ controller: PKPaymentAuthorizationViewController,
        didAuthorizePayment payment: PKPayment
    ) async -> PKPaymentAuthorizationResult {
        await handleAuthorize(payment: payment)
    }

    // MARK: - Payment Method (async)

    public func paymentAuthorizationViewController(
        _ controller: PKPaymentAuthorizationViewController,
        didSelect paymentMethod: PKPaymentMethod
    ) async -> PKPaymentRequestPaymentMethodUpdate {
        await handleSelectPaymentMethod(paymentMethod)
    }

    // MARK: - Shipping Contact (async)

    public func paymentAuthorizationViewController(
        _ controller: PKPaymentAuthorizationViewController,
        didSelectShippingContact contact: PKContact
    ) async -> PKPaymentRequestShippingContactUpdate {
        await handleSelectShippingContact(contact)
    }

    // MARK: - Shipping Method (async)

    public func paymentAuthorizationViewController(
        _ controller: PKPaymentAuthorizationViewController,
        didSelect shippingMethod: PKShippingMethod
    ) async -> PKPaymentRequestShippingMethodUpdate {
        await handleSelectShippingMethod(shippingMethod)
    }

    // MARK: - Coupon Code (async)

    public func paymentAuthorizationViewController(
        _ controller: PKPaymentAuthorizationViewController,
        didChangeCouponCode couponCode: String
    ) async -> PKPaymentRequestCouponCodeUpdate {
        await handleChangeCouponCode(couponCode)
    }
}

// MARK: - Private Helpers

extension ApplePayComponent {

    private func handleAuthorize(payment: PKPayment) async -> PKPaymentAuthorizationResult {
        authorizationHandled = true

        guard !payment.token.paymentData.isEmpty else {
            delegate?.didFail(with: Error.invalidToken, from: self)
            return PKPaymentAuthorizationResult(status: .failure, errors: nil)
        }

        // Optional merchant validation via configuration closure
        if let onAuthorize = configuration.onAuthorize {
            let result = await onAuthorize(payment)
            if result.status == .failure {
                // Sheet stays open for the shopper to retry.
                // Cancelling after this before a new authorize should trigger didFail
                authorizationHandled = false
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

        let data = PaymentComponentData(paymentMethodDetails: details, order: order)

        // Store the continuation first, then submit. submit() is fire-and-forget — it triggers
        // the delegate's didSubmit which eventually leads to resolve(success:) being called.
        // The continuation must be stored before submit so resolve() has something to resume.
        let success = await withCheckedContinuation { continuation in
            self.paymentResultContinuation = continuation
            self.submit(data: data)
        }

        return PKPaymentAuthorizationResult(status: success ? .success : .failure, errors: nil)
    }

    private func handleSelectShippingContact(_ contact: PKContact) async -> PKPaymentRequestShippingContactUpdate {
        guard let onSelectShippingContact = configuration.onSelectShippingContact else {
            return PKPaymentRequestShippingContactUpdate(paymentSummaryItems: paymentRequest.paymentSummaryItems)
        }

        let result = await onSelectShippingContact(contact, paymentRequest.paymentSummaryItems)
        result.paymentSummaryItems = validSummaryItems(from: result)
        return result
    }

    private func handleSelectShippingMethod(_ shippingMethod: PKShippingMethod) async -> PKPaymentRequestShippingMethodUpdate {
        guard let onSelectShippingMethod = configuration.onSelectShippingMethod else {
            return PKPaymentRequestShippingMethodUpdate(paymentSummaryItems: paymentRequest.paymentSummaryItems)
        }

        let result = await onSelectShippingMethod(shippingMethod, paymentRequest.paymentSummaryItems)
        result.paymentSummaryItems = validSummaryItems(from: result)
        return result
    }

    private func handleChangeCouponCode(_ couponCode: String) async -> PKPaymentRequestCouponCodeUpdate {
        guard let onChangeCouponCode = configuration.onChangeCouponCode else {
            return PKPaymentRequestCouponCodeUpdate(paymentSummaryItems: paymentRequest.paymentSummaryItems)
        }

        let result = await onChangeCouponCode(couponCode, paymentRequest.paymentSummaryItems)
        result.paymentSummaryItems = validSummaryItems(from: result)
        return result
    }

    private func handleSelectPaymentMethod(_ paymentMethod: PKPaymentMethod) async -> PKPaymentRequestPaymentMethodUpdate {
        guard let onPaymentMethodChange = configuration.onPaymentMethodChange else {
            return PKPaymentRequestPaymentMethodUpdate(paymentSummaryItems: paymentRequest.paymentSummaryItems)
        }

        let result = await onPaymentMethodChange(paymentMethod, paymentRequest.paymentSummaryItems)
        result.paymentSummaryItems = validSummaryItems(from: result)
        return result
    }

    /// Returns valid summary items from a merchant-returned update result.
    ///
    /// If the result indicates failure or has empty items, the current `paymentRequest.paymentSummaryItems`
    /// are returned unchanged.
    ///
    /// If validation fails, notifies the delegate via `didFail` and falls back to the
    /// previous valid summary items to keep the Apple Pay sheet in a consistent state.
    ///
    /// Otherwise the new items are accepted and stored on `paymentRequest`.
    private func validSummaryItems(from result: some PKPaymentRequestUpdate) -> [PKPaymentSummaryItem] {
        guard result.status == .success, !result.paymentSummaryItems.isEmpty else {
            return paymentRequest.paymentSummaryItems
        }
        do {
            try ApplePayConfiguration.validate(summaryItems: result.paymentSummaryItems)
            paymentRequest.paymentSummaryItems = result.paymentSummaryItems
            return result.paymentSummaryItems
        } catch {
            delegate?.didFail(with: error, from: self)
            return paymentRequest.paymentSummaryItems
        }
    }
}
