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
        pendingPaymentComponent = component

        if let onSubmit = configuration.onSubmit {
            submitTask?.cancel()
            submitTask = Task { [weak self] in
                do {
                    let response = try await onSubmit(data)
                    guard !Task.isCancelled else { return }
                    self?.handle(response, from: component)
                } catch {
                    // Ignore if this was a cancellation (task superseded or Checkout torn down).
                    guard !(error is CancellationError), !Task.isCancelled else { return }
                    self?.finish(with: error, from: component)
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
        finish(with: error, from: component)
    }
}

// MARK: - ActionComponentDelegate

extension Checkout: ActionComponentDelegate {

    public func didProvide(_ data: Adyen.ActionComponentData, from component: any Adyen.ActionComponent) {
        if let onAdditionalDetails = configuration.onAdditionalDetails {
            additionalDetailsTask?.cancel()
            additionalDetailsTask = Task { [weak self] in
                do {
                    let response = try await onAdditionalDetails(data)
                    guard !Task.isCancelled else { return }
                    self?.handle(response, from: self?.pendingPaymentComponent)
                } catch {
                    // Ignore if this was a cancellation (task superseded or Checkout torn down).
                    guard !(error is CancellationError), !Task.isCancelled else { return }
                    self?.finish(with: error, from: self?.pendingPaymentComponent)
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
        finish(with: error, from: pendingPaymentComponent)
    }
}

// MARK: - SessionDelegate

extension Checkout: SessionDelegate {

    public func didComplete(with result: CheckoutResult, component: any Component, session: Session) {
        finish(with: result, from: component as? (any PaymentComponent))
    }

    public func didFail(with error: any Error, from component: any Component, session: Session) {
        finish(with: error, from: component as? (any PaymentComponent))
    }
}

// MARK: - Private Helpers

private extension Checkout {

    /// If the response carries an action, dispatch it and keep `pendingPaymentComponent`
    /// set so the final result (arriving later via `didProvide`) can still finalize
    /// the component that originally submitted.
    func handle(_ paymentsResponse: CheckoutPaymentsResponse, from component: (any PaymentComponent)?) {
        if let action = paymentsResponse.action {
            actionHandlingComponent.handle(action)
        } else {
            // TODO: check for error cases here
            finish(
                with: CheckoutResult(resultCode: paymentsResponse.resultCode),
                from: component
            )
        }
    }

    // TODO: `onComplete` / `onError` currently fire synchronously right after `finalize`,
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
        finalize(component, success: result.resultCode.isSuccessful)
        configuration.onComplete?(result)
    }

    func finish(with error: Error, from component: (any PaymentComponent)?) {
        finalize(component, success: false)
        configuration.onError?(CheckoutError(error: error))
    }

    /// Resumes the originating component if it needs finalization (e.g. Apple Pay sheet)
    /// and clears the pending reference so a new flow can start clean.
    func finalize(_ component: (any PaymentComponent)?, success: Bool) {
        (component as? any FinalizableComponent)?.didFinalize(with: success, completion: nil)
        pendingPaymentComponent = nil
    }
}
