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
import UIKit

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
    
    internal func stopLoading() {
        paymentComponent.stopLoading()
    }
}

/// The final result of a payment attempt.
internal enum CheckoutOutcome {
    case completed(CheckoutResultCode)
    case failed(Error)

    internal var isSuccessful: Bool {
        switch self {
        case let .completed(resultCode):
            resultCode.isSuccessful
        case .failed:
            false
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
            } catch CallbackError.beforeSubmitAborted {
                // catch beforeSubmit abort here and reset the component UI
                guard !Task.isCancelled else { return }
                source.stopLoading()
                self?.pendingPaymentComponent = nil
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
        guard let resultCode = session?.state.resultCode else {
            // TODO: need a result code for advanced non-session action flows.
            return
        }
        finish(.completed(resultCode), from: component)
    }

    func handle(submitResult: SubmitResult, source: CheckoutCallbackSource) {
        switch submitResult {
        case let .action(action):
            handle(action, source: source)
        case let .completion(resultCode):
            finish(.completed(CheckoutResultCode(rawValue: resultCode)), from: source.paymentComponent)
        case .retry:
            source.stopLoading()
        // TODO: Re-prompt the shopper at payment-method selection. Optionally surface
        // `errorMessage` in the UI before re-prompting.
        case let .partialPayment(partialPayment):
            handle(partialPayment: partialPayment, source: source)
        }
    }

    func handle(additionalDetailsResult: AdditionalDetailsResult, from component: (any PaymentComponent)?) {
        switch additionalDetailsResult {
        case let .completion(resultCode):
            finish(.completed(CheckoutResultCode(rawValue: resultCode)), from: component)
        }
    }

    /// Error entry point. Consolidates every error path (onSubmit, onAdditionalDetails,
    /// component/action/session failures) into a single place so finalization and the
    /// result callbacks stay in lockstep.
    func handle(_ error: Error, from component: (any PaymentComponent)?) {
        finish(.failed(error), from: component)
    }

    /// Ends the payment attempt and calls the result callbacks once the component's UI is gone.
    ///
    /// The first outcome of an attempt wins: a result or action that arrives later for it is dropped.
    func finish(_ outcome: CheckoutOutcome, from component: (any PaymentComponent)?) {
        // Cleared before any suspension, so a submit that arrives while the component
        // finalizes doesn't trip the assertion in `performSubmit`.
        pendingPaymentComponent = nil
        submitTask?.cancel()
        additionalDetailsTask?.cancel()

        Task {
            if let component {
                await component.finalizeIfNeeded(success: outcome.isSuccessful)
            }
            callResultCallback(outcome)
        }
    }
}

private extension CheckoutCore {

    func callResultCallback(_ outcome: CheckoutOutcome) {
        switch outcome {
        case let .completed(resultCode):
            resultCallbacks.handleCompletion(
                resultCode: resultCode,
                sessionId: session?.state.identifier,
                sessionResult: session?.state.sessionResult
            )
        case let .failed(error):
            resultCallbacks.onFailure?(CheckoutError(error: error))
        }
    }

    func onSubmit(for data: PaymentComponentData) -> () async throws -> SubmitResult {
        let handler = callbackHandler
        return { try await handler.handleSubmit(data) }
    }
    
    func onAdditionalDetails(for data: ActionComponentData) -> () async throws -> AdditionalDetailsResult {
        let handler = callbackHandler
        return { try await handler.handleAdditionalDetails(data) }
    }
    
    func handle(_ action: Action, source: CheckoutCallbackSource) {
        source.stopLoading()
        if let dropInComponent = source.dropInComponent as? ActionHandlingComponent {
            dropInComponent.handle(action)
        } else {
            actionHandlingComponent.handle(action)
        }
    }
    
}

extension CheckoutCore: ActionPresentationDelegate {

    package func present(actionViewController: UIViewController, actionData: ActionData) {
        if let onAction = resultCallbacks.onAction {
            onAction(actionData, actionViewController)
        } else if let presentingViewController = pendingPaymentComponent?.viewController {
            presentingViewController.present(actionViewController, animated: true)
        } else {
            AdyenAssertion.assertionFailure(
                message: "No onAction handler is set and no payment component is available to present the action on."
            )
        }
    }
}
