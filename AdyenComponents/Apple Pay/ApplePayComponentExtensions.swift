//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import PassKit
import UIKit

/// The members of `PKPaymentAuthorizationController` that `ApplePayComponent` uses.
@MainActor
internal protocol ApplePayAuthorizationControlling: AnyObject {
    var delegate: PKPaymentAuthorizationControllerDelegate? { get set }
    func present() async -> Bool
    func dismiss() async
}

extension PKPaymentAuthorizationController: ApplePayAuthorizationControlling {}

extension ApplePayComponent: PKPaymentAuthorizationControllerDelegate {

    // MARK: - Did Finish

    public func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        requestSheetClose()
    }

    // MARK: - Presentation Window

    public nonisolated func presentationWindow(for controller: PKPaymentAuthorizationController) -> UIWindow? {
        // PassKit asks for the window on the main thread.
        MainActor.assumeIsolated {
            // Prefer the scene that shows the Apple Pay button. The merchant can also call `submit()`
            // without showing it, so fall back to the key window.
            viewController.viewIfLoaded?.window ?? UIApplication.shared.adyen.mainKeyWindow
        }
    }

    // MARK: - Did Authorize (async)

    public func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController,
        didAuthorizePayment payment: PKPayment
    ) async -> PKPaymentAuthorizationResult {
        await handleAuthorize(payment: payment)
    }

    // MARK: - Payment Method (async)

    public func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController,
        didSelectPaymentMethod paymentMethod: PKPaymentMethod
    ) async -> PKPaymentRequestPaymentMethodUpdate {
        await handleSelectPaymentMethod(paymentMethod)
    }

    // MARK: - Shipping Contact (async)

    public func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController,
        didSelectShippingContact contact: PKContact
    ) async -> PKPaymentRequestShippingContactUpdate {
        await handleSelectShippingContact(contact)
    }

    // MARK: - Shipping Method (async)

    public func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController,
        didSelectShippingMethod shippingMethod: PKShippingMethod
    ) async -> PKPaymentRequestShippingMethodUpdate {
        await handleSelectShippingMethod(shippingMethod)
    }

    // MARK: - Coupon Code (async)

    public func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController,
        didChangeCouponCode couponCode: String
    ) async -> PKPaymentRequestCouponCodeUpdate {
        await handleChangeCouponCode(couponCode)
    }
}

// MARK: - Private Helpers

extension ApplePayComponent {

    private func handleAuthorize(payment: PKPayment) async -> PKPaymentAuthorizationResult {
        guard !payment.token.paymentData.isEmpty else {
            // PassKit closes the sheet after a failure without errors.
            sheetOutcome = .failed(Error.invalidToken)
            return PKPaymentAuthorizationResult(status: .failure, errors: nil)
        }
        sheetOutcome = .authorized

        // Optional merchant validation via configuration closure
        if let onAuthorize = configuration.onAuthorize {
            let result = await onAuthorize(payment)
            if result.status == .failure {
                // With errors the shopper can fix, the sheet stays open to retry.
                // Without them, PassKit closes the sheet, which is reported as a cancel.
                sheetOutcome = .cancelled
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

        // Stored before submitting, so `finalize(success:)` always finds it.
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
        guard let onSelectPaymentMethod = configuration.onSelectPaymentMethod else {
            return PKPaymentRequestPaymentMethodUpdate(paymentSummaryItems: paymentRequest.paymentSummaryItems)
        }

        let result = await onSelectPaymentMethod(paymentMethod, paymentRequest.paymentSummaryItems)
        result.paymentSummaryItems = validSummaryItems(from: result)
        return result
    }

    /// Returns valid summary items from a merchant-returned update result.
    ///
    /// If the result indicates failure or has empty items, the current `paymentRequest.paymentSummaryItems`
    /// are returned unchanged.
    ///
    /// If validation fails, returns the previous valid summary items, because PassKit still needs an answer,
    /// and closes the sheet. The error is reported through `didFail` once the sheet is dismissed.
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
            sheetOutcome = .failed(error)
            // PassKit gets this update before the sheet task resumes and dismisses the sheet.
            requestSheetClose()
            return paymentRequest.paymentSummaryItems
        }
    }
}
