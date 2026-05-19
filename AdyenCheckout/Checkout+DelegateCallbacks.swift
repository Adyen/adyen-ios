//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenSession)
    import AdyenSession
#endif
#if canImport(AdyenActions)
    @_spi(AdyenInternal) import AdyenActions
#endif
import Foundation

// MARK: - Internal Helpers

internal enum CheckoutCallbackSource {
    case component(any PaymentComponent)
    case dropIn(component: any PaymentComponent, dropInComponent: any AnyDropInComponent)

    internal var paymentComponent: any PaymentComponent {
        switch self {
        case let .component(component):
            component
        case let .dropIn(component, _):
            component
        }
    }

    internal var dropInComponent: (any AnyDropInComponent)? {
        switch self {
        case .component:
            nil
        case let .dropIn(_, dropInComponent):
            dropInComponent
        }
    }
}

internal extension CheckoutCore {

    func performSubmit(
        _ data: PaymentComponentData,
        source: CheckoutCallbackSource
    ) {
        AdyenAssertion.assert(
            message: "A new payment component submitted while another flow is still pending.",
            condition: pendingPaymentComponent != nil
        )
        pendingPaymentComponent = source.paymentComponent
        submitTask?.cancel()

        let onSubmit = onSubmit(for: data)

        submitTask = Task { [weak self] in
            do {
                let submitResult = try await onSubmit()
                guard !Task.isCancelled else { return }
                self?.handle(submitResult: submitResult, source: source)
            } catch {
                // Ignore if this was a cancellation (task superseded or Checkout torn down).
                guard !(error is CancellationError), !Task.isCancelled else { return }
                self?.handle(error, from: source.paymentComponent)
            }
        }
    }

    func performAdditionalDetails(
        _ data: ActionComponentData,
        from component: any ActionComponent
    ) {
        (component as? any PresentableComponent)?.viewController.view.isUserInteractionEnabled = false
        let paymentComponent = pendingPaymentComponent
        additionalDetailsTask?.cancel()

        let onAdditionalDetails = onAdditionalDetails(for: data)

        additionalDetailsTask = Task { [weak self] in
            do {
                let additionalDetailsResult = try await onAdditionalDetails()
                guard !Task.isCancelled else { return }
                self?.handle(additionalDetailsResult: additionalDetailsResult, from: paymentComponent)
            } catch {
                // Ignore if this was a cancellation (task superseded or Checkout torn down).
                guard !(error is CancellationError), !Task.isCancelled else { return }
                self?.handle(error, from: paymentComponent)
            }
        }
    }

    func completeAction(from component: (any PaymentComponent)?) {
        guard let result = session?.currentResult else {
            // TODO: need a result code for advanced non-session action flows.
            return
        }
        finish(with: result, from: component)
    }

    func handle(submitResult: SubmitResult, source: CheckoutCallbackSource) {
        switch submitResult {
        case let .action(action):
            handle(action, source: source)
        case let .completion(resultCode):
            finish(with: CheckoutResult(resultCode: CheckoutResultCode(rawValue: resultCode)), from: source.paymentComponent)
        case .retry:
            // TODO: Re-prompt the shopper at payment-method selection. Optionally surface
            // `errorMessage` in the UI before re-prompting.
            break
        case let .partialPayment(partialPayment):
            handle(partialPayment: partialPayment, source: source)
        }
    }

    func handle(additionalDetailsResult: AdditionalDetailsResult, from component: (any PaymentComponent)?) {
        switch additionalDetailsResult {
        case let .completion(resultCode):
            finish(with: CheckoutResult(resultCode: CheckoutResultCode(rawValue: resultCode)), from: component)
        }
    }

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
        resultCallbacks.onComplete?(result)
    }

    func finish(with error: Error, from component: (any PaymentComponent)?) {
        (component as? any FinalizableComponent)?.didFinalize(with: false, completion: nil)
        pendingPaymentComponent = nil
        resultCallbacks.onError?(CheckoutError(error: error))
    }
}

private extension CheckoutCore {
    
    func onSubmit(for data: PaymentComponentData) -> () async throws -> SubmitResult {
        let handler = callbackHandler
        return { try await handler.handleSubmit(data) }
    }
    
    func onAdditionalDetails(for data: ActionComponentData) -> () async throws -> AdditionalDetailsResult {
        let handler = callbackHandler
        return { try await handler.handleAdditionalDetails(data) }
    }
    
    func handle(_ action: Action, source: CheckoutCallbackSource) {
        if let dropInComponent = source.dropInComponent as? ActionHandlingComponent {
            dropInComponent.handle(action)
        } else {
            actionHandlingComponent.handle(action)
        }
    }
    
}

internal enum CallbackError: LocalizedError {
    case missingSubmitHandler
    case missingAdditionalDetailsHandler
    case unsupportedSubmit

    internal var errorDescription: String? {
        switch self {
        case .missingSubmitHandler:
            "Checkout requires `onSubmit` to submit payment data."
        case .missingAdditionalDetailsHandler:
            "Checkout requires `onAdditionalDetails` to submit additional details."
        case .unsupportedSubmit:
            "Action-only checkout cannot submit payment data."
        }
    }
}
