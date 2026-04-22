//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
#if canImport(AdyenSession)
    @_spi(AdyenInternal) import AdyenSession
#endif

// This is where the main flow checking/forwarding happens.
// Through conforming to the delegates, Checkout will be the bridge.
// If there is a callback, regardless of session, we call it first.
// If not, we check session and pass the work to it.
// Finally if neither, we will fail/assert/show error.

extension Checkout: PaymentComponentDelegate {
    
    public func didSubmit(_ data: PaymentComponentData, from component: any PaymentComponent) {
        if let onSubmit = configuration.onSubmit {
            submitTask?.cancel()
            submitTask = Task { [weak self] in
                let result: SubmitResult
                do {
                    result = try await onSubmit(data)
                } catch is CancellationError {
                    return
                } catch {
                    result = .error(error)
                }
                guard !Task.isCancelled else { return }
                self?.handle(submitResult: result)
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
        finish(with: error)
    }
    
    private func handle(submitResult: SubmitResult) {
        switch submitResult {
        case let .action(action):
            actionHandlingComponent.handle(action)
        case let .finished(resultCode):
            finish(with: CheckoutResult(resultCode: CheckoutResultCode(rawValue: resultCode)))
        case let .error(error):
            finish(with: error)
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

extension Checkout: ActionComponentDelegate {
    public func didProvide(_ data: Adyen.ActionComponentData, from component: any Adyen.ActionComponent) {
        if let onAdditionalDetails = configuration.onAdditionalDetails {
            additionalDetailsTask?.cancel()
            additionalDetailsTask = Task { [weak self] in
                let result: AdditionalDetailsResult
                do {
                    result = try await onAdditionalDetails(data)
                } catch is CancellationError {
                    return
                } catch {
                    result = .error(error)
                }
                guard !Task.isCancelled else { return }
                self?.handle(additionalDetailsResult: result)
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
        finish(with: error)
    }
    
    private func handle(additionalDetailsResult: AdditionalDetailsResult) {
        switch additionalDetailsResult {
        case let .finished(resultCode):
            finish(with: CheckoutResult(resultCode: CheckoutResultCode(rawValue: resultCode)))
        case let .error(error):
            finish(with: error)
        @unknown default:
            AdyenAssertion.assertionFailure(
                message: "Unhandled AdditionalDetailsResult branch; ignored."
            )
        }
    }
}

extension Checkout: SessionDelegate {
    public func didComplete(with result: CheckoutResult, component: any Component, session: Session) {
        finish(with: result)
    }
    
    public func didFail(with error: any Error, from component: any Component, session: Session) {
        finish(with: error)
    }
    
    private func finish(with result: CheckoutResult) {
        // TODO: add any finalizing code if needed
        configuration.onComplete?(result)
    }
    
    private func finish(with error: Error) {
        // TODO: add any finalizing code if needed
        configuration.onError?(CheckoutError(error: error))
    }
}
