//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import PassKit
import UIKit

/// The members of `PKPaymentAuthorizationController` that `ApplePayAuthorizationHandler` uses.
@MainActor
internal protocol ApplePayAuthorizationControlling: AnyObject {
    var delegate: PKPaymentAuthorizationControllerDelegate? { get set }
    func present() async -> Bool
    func dismiss() async
}

extension PKPaymentAuthorizationController: ApplePayAuthorizationControlling {}

/// Handles one Apple Pay sheet, from presenting it until it's dismissed. A new handler is created for every sheet.
@MainActor
internal final class ApplePayAuthorizationHandler: NSObject {

    internal enum Outcome {
        case cancelled
        case submitted
        case failed(Swift.Error)
    }

    private let controller: ApplePayAuthorizationControlling
    private let configuration: ApplePayConfiguration
    private let presentationWindow: UIWindow?
    private let onPresent: () -> Void
    private let submitPayment: (PKPayment) -> Void
    private let onEnd: (Outcome) -> Void

    private var task: Task<Void, Never>?
    private var pendingOutcome = Outcome.cancelled

    /// PassKit can report that the sheet finished before `performAuthorization()` waits for it.
    private var isFinished = false
    private var finishContinuation: CheckedContinuation<Void, Never>?
    private var paymentResultContinuation: CheckedContinuation<Bool, Never>?

    private var paymentRequest: PKPaymentRequest {
        configuration.paymentRequest
    }

    internal init(
        controller: ApplePayAuthorizationControlling,
        configuration: ApplePayConfiguration,
        presentationWindow: UIWindow?,
        onPresent: @escaping () -> Void,
        submitPayment: @escaping (PKPayment) -> Void,
        onEnd: @escaping (Outcome) -> Void
    ) {
        self.controller = controller
        self.configuration = configuration
        self.presentationWindow = presentationWindow
        self.onPresent = onPresent
        self.submitPayment = submitPayment
        self.onEnd = onEnd
        super.init()
        controller.delegate = self
    }

    internal func start() {
        task = Task {
            await performAuthorization()
        }
    }

    /// Shows the payment result on the sheet, and returns once the sheet is dismissed.
    internal func finalize(success: Bool) async {
        completePayment(success: success)
        await task?.value
    }

    /// Presents the sheet and reports its outcome through `onEnd` once the sheet is dismissed.
    private func performAuthorization() async {
        let outcome: Outcome
        if await controller.present() {
            onPresent()
            outcome = await waitForOutcome()
            await controller.dismiss()
            // Ends PassKit's wait if the sheet finished before the payment result arrived.
            completePayment(success: false)
        } else {
            outcome = .failed(ApplePayComponent.Error.invalidPaymentRequest)
        }
        onEnd(outcome)
    }

    /// Returns once PassKit reports that the sheet finished.
    private func waitForOutcome() async -> Outcome {
        if !isFinished {
            await withCheckedContinuation { finishContinuation = $0 }
        }
        return pendingOutcome
    }

    private func finish() {
        isFinished = true
        let continuation = finishContinuation
        finishContinuation = nil
        continuation?.resume()
    }

    private func completePayment(success: Bool) {
        let continuation = paymentResultContinuation
        paymentResultContinuation = nil
        continuation?.resume(returning: success)
    }
}

// MARK: - PKPaymentAuthorizationControllerDelegate

extension ApplePayAuthorizationHandler: PKPaymentAuthorizationControllerDelegate {

    internal func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        finish()
    }

    internal nonisolated func presentationWindow(for controller: PKPaymentAuthorizationController) -> UIWindow? {
        // PassKit asks on the main thread.
        MainActor.assumeIsolated {
            presentationWindow
        }
    }

    internal func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController,
        didAuthorizePayment payment: PKPayment
    ) async -> PKPaymentAuthorizationResult {
        await authorize(payment)
    }

    internal func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController,
        didSelectPaymentMethod paymentMethod: PKPaymentMethod
    ) async -> PKPaymentRequestPaymentMethodUpdate {
        guard let onSelectPaymentMethod = configuration.onSelectPaymentMethod else {
            return PKPaymentRequestPaymentMethodUpdate(paymentSummaryItems: paymentRequest.paymentSummaryItems)
        }

        let result = await onSelectPaymentMethod(paymentMethod, paymentRequest.paymentSummaryItems)
        result.paymentSummaryItems = validSummaryItems(from: result)
        return result
    }

    internal func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController,
        didSelectShippingContact contact: PKContact
    ) async -> PKPaymentRequestShippingContactUpdate {
        guard let onSelectShippingContact = configuration.onSelectShippingContact else {
            return PKPaymentRequestShippingContactUpdate(paymentSummaryItems: paymentRequest.paymentSummaryItems)
        }

        let result = await onSelectShippingContact(contact, paymentRequest.paymentSummaryItems)
        result.paymentSummaryItems = validSummaryItems(from: result)
        return result
    }

    internal func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController,
        didSelectShippingMethod shippingMethod: PKShippingMethod
    ) async -> PKPaymentRequestShippingMethodUpdate {
        guard let onSelectShippingMethod = configuration.onSelectShippingMethod else {
            return PKPaymentRequestShippingMethodUpdate(paymentSummaryItems: paymentRequest.paymentSummaryItems)
        }

        let result = await onSelectShippingMethod(shippingMethod, paymentRequest.paymentSummaryItems)
        result.paymentSummaryItems = validSummaryItems(from: result)
        return result
    }

    internal func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController,
        didChangeCouponCode couponCode: String
    ) async -> PKPaymentRequestCouponCodeUpdate {
        guard let onChangeCouponCode = configuration.onChangeCouponCode else {
            return PKPaymentRequestCouponCodeUpdate(paymentSummaryItems: paymentRequest.paymentSummaryItems)
        }

        let result = await onChangeCouponCode(couponCode, paymentRequest.paymentSummaryItems)
        result.paymentSummaryItems = validSummaryItems(from: result)
        return result
    }
}

// MARK: - Private

extension ApplePayAuthorizationHandler {

    private func authorize(_ payment: PKPayment) async -> PKPaymentAuthorizationResult {
        guard !payment.token.paymentData.isEmpty else {
            // PassKit closes the sheet after a failure without errors.
            pendingOutcome = .failed(ApplePayComponent.Error.invalidToken)
            return PKPaymentAuthorizationResult(status: .failure, errors: nil)
        }

        if let onAuthorize = configuration.onAuthorize {
            let result = await onAuthorize(payment)
            if result.status == .failure {
                // With errors the sheet stays open to retry. Without them, PassKit closes it.
                return result
            }
        }

        // `onAuthorize` can outlast PassKit's timeout. Don't submit a payment the shopper saw fail.
        guard !isFinished else {
            return PKPaymentAuthorizationResult(status: .failure, errors: nil)
        }

        pendingOutcome = .submitted
        let success = await withCheckedContinuation { continuation in
            // Stored first, in case the result arrives right away.
            paymentResultContinuation = continuation
            submitPayment(payment)
        }
        return PKPaymentAuthorizationResult(status: success ? .success : .failure, errors: nil)
    }

    /// Keeps the current items if the result failed or has none.
    /// Invalid items end the sheet with an error; PassKit still gets the current items as its answer.
    private func validSummaryItems(from result: some PKPaymentRequestUpdate) -> [PKPaymentSummaryItem] {
        guard result.status == .success, !result.paymentSummaryItems.isEmpty else {
            return paymentRequest.paymentSummaryItems
        }
        do {
            try ApplePayConfiguration.validate(summaryItems: result.paymentSummaryItems)
            paymentRequest.paymentSummaryItems = result.paymentSummaryItems
            return result.paymentSummaryItems
        } catch {
            pendingOutcome = .failed(error)
            finish()
            return paymentRequest.paymentSummaryItems
        }
    }
}
