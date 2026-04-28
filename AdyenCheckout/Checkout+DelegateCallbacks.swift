//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
#if canImport(AdyenSession)
    @_spi(AdyenInternal) import AdyenSession
#endif

// MARK: - PaymentComponentDelegate

extension Checkout: PaymentComponentDelegate {

    public func didSubmit(_ data: PaymentComponentData, from component: any PaymentComponent) {
        AdyenAssertion.assert(
            message: "A new payment component submitted while another flow is still pending.",
            condition: pendingPaymentComponent == nil
        )
        pendingPaymentComponent = component

        if let onSubmit = configuration.onSubmit {
            submitTask?.cancel()
            submitTask = Task { [weak self] in
                do {
                    let submitResult = try await onSubmit(data)
                    guard !Task.isCancelled else { return }
                    self?.handle(submitResult: submitResult, from: component)
                } catch {
                    // Ignore if this was a cancellation (task superseded or Checkout torn down).
                    guard !(error is CancellationError), !Task.isCancelled else { return }
                    self?.handle(error, from: component)
                }
            }
        } else if let session {
            session.didSubmit(
                data,
                from: component,
                dropInComponent: nil
            )
        } else {
            // TODO: throw/assert to inform missing callbacks
        }
    }

    public func didFail(with error: any Error, from component: any PaymentComponent) {
        handle(error, from: component)
    }

    @MainActor
    private func handle(submitResult: SubmitResult, from component: (any PaymentComponent)?) {
        switch submitResult {
        case let .action(action):
            actionHandlingComponent.handle(action)
        case let .completion(resultCode):
            finish(with: CheckoutResult(resultCode: CheckoutResultCode(rawValue: resultCode)), from: component)
        case .retry:
            // TODO: Re-prompt the shopper at payment-method selection. Optionally surface
            // `errorMessage` in the UI before re-prompting.
            break
        case .partialPayment:
            // Components (advanced flow): the SDK intentionally performs no work here.
            // The merchant owns the continuation — they decide whether to instantiate a new
            // payment component for the remaining amount based on the PartialPayment payload
            // they returned from `onSubmit`.
            // TODO: add partial-payment support for Drop-in on the advanced (non-session) flow.
            break
        @unknown default:
            AdyenAssertion.assertionFailure(
                message: "Unhandled SubmitResult branch; ignored."
            )
        }
    }
}

// MARK: - ActionComponentDelegate

extension Checkout: ActionComponentDelegate {

    public func didProvide(_ data: Adyen.ActionComponentData, from component: any Adyen.ActionComponent) {
        if let onAdditionalDetails = configuration.onAdditionalDetails {
            additionalDetailsTask?.cancel()
            additionalDetailsTask = Task { [weak self] in
                do {
                    let additionalDetailsResult = try await onAdditionalDetails(data)
                    guard !Task.isCancelled else { return }
                    self?.handle(additionalDetailsResult: additionalDetailsResult, from: self?.pendingPaymentComponent)
                } catch {
                    // Ignore if this was a cancellation (task superseded or Checkout torn down).
                    guard !(error is CancellationError), !Task.isCancelled else { return }
                    self?.handle(error, from: self?.pendingPaymentComponent)
                }
            }
        } else if let session {
            session.didProvide(
                data,
                from: component,
                dropInComponent: nil
            )
        } else {
            // TODO: throw/assert to inform missing callbacks
        }
    }

    public func didComplete(from component: any Adyen.ActionComponent) {
        // TODO: need a result code here, refactor this function to contain it or create on here?
    }

    public func didFail(with error: any Error, from component: any Adyen.ActionComponent) {
        // Route back to the payment component that started this flow so any UI
        // it's still holding open (e.g. the Apple Pay sheet) can dismiss.
        handle(error, from: pendingPaymentComponent)
    }

    @MainActor
    private func handle(additionalDetailsResult: AdditionalDetailsResult, from component: (any PaymentComponent)?) {
        switch additionalDetailsResult {
        case let .completion(resultCode):
            finish(with: CheckoutResult(resultCode: CheckoutResultCode(rawValue: resultCode)), from: component)
        @unknown default:
            AdyenAssertion.assertionFailure(
                message: "Unhandled AdditionalDetailsResult branch; ignored."
            )
        }
    }
}

// MARK: - SessionDelegate

extension Checkout: SessionDelegate {

    public func didComplete(with result: CheckoutResult, component: any Component, session: Session) {
        finish(with: result, from: component as? (any PaymentComponent))
    }

    public func didFail(with error: any Error, from component: any Component, session: Session) {
        handle(error, from: component as? (any PaymentComponent))
    }
}

// MARK: - Private Helpers

private extension Checkout {

    /// Error entry point. Consolidates every error path (onSubmit, onAdditionalDetails,
    /// component/action/session failures) into a single place so finalization and merchant
    /// notification stay in lockstep.
    func handle(_ error: Error, from component: (any PaymentComponent)?) {
        finish(with: error, from: component)
    }

    // TODO: `onComplete` / `onError` currently fire synchronously right after finalization,
    // which for Apple Pay means they fire while PK is still animating its success/failure
    // result and has not yet dismissed the sheet. If a merchant's callback presents any
    // UI (alert, navigation, etc.), that presentation wedges UIKit's transition machinery
    // and the PK sheet never dismisses — same bug the advanced-flow demo hit.
    //
    // Proper fix: make `FinalizableComponent.didFinalize` async (or fire its completion
    // after the sheet has left the window hierarchy) and await it here before invoking
    // the integrator callbacks. Then every final path below — normal success/failure,
    // invalid-token in handleDidAuthorize, action-component errors, session errors — is
    // trivially correct with no per-path special casing.
    func finish(with result: CheckoutResult, from component: (any PaymentComponent)?) {
        (component as? any FinalizableComponent)?.didFinalize(with: result.resultCode.isSuccessful, completion: nil)
        pendingPaymentComponent = nil
        configuration.onComplete?(result)
    }

    func finish(with error: Error, from component: (any PaymentComponent)?) {
        (component as? any FinalizableComponent)?.didFinalize(with: false, completion: nil)
        pendingPaymentComponent = nil
        configuration.onError?(error)
    }
}
