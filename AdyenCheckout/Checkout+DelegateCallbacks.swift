//
// Copyright (c) Adyen N.V.
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
            onSubmit(data) { [weak self] response in
                guard let self else { return }
                self.handle(response)
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
    
    private func handle(_ paymentsResponse: CheckoutPaymentsResponse) {
        if let action = paymentsResponse.action {
            actionHandlingComponent.handle(action)
        } else {
            // TODO: check for error cases here
            finish(with: CheckoutResult(resultCode: paymentsResponse.resultCode))
        }
    }
}

extension Checkout: ActionComponentDelegate {
    public func didProvide(_ data: Adyen.ActionComponentData, from component: any Adyen.ActionComponent) {
        if let onAdditionalDetails = configuration.onAdditionalDetails {
            onAdditionalDetails(data) { [weak self] response in
                guard let self else { return }
                self.handle(response)
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
}

extension Checkout: AdyenSessionDelegate {
    public func didComplete(with result: CheckoutResult, component: any Component, session: AdyenSession) {
        finish(with: result)
    }
    
    public func didFail(with error: any Error, from component: any Component, session: AdyenSession) {
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
