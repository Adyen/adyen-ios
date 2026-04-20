//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
#if canImport(AdyenActions)
    @_spi(AdyenInternal) import AdyenActions
#endif
import Foundation

@_spi(AdyenInternal)
extension Session: ActionComponentDelegate {
    public func didFail(with error: Error, from component: ActionComponent) {
        failWithError(error, component)
    }

    public func didComplete(from component: ActionComponent) {
        didComplete(currentComponent: component)
    }
    
    @MainActor
    internal func didComplete(currentComponent: Component) {
        guard let resultCode = state.resultCode else {
            AdyenAssertion.assertionFailure(message: "Missing resultCode.")
            return
        }
        let result = CheckoutResult(
            resultCode: resultCode,
            sessionResult: state.sessionResult
        )
        delegate?.didComplete(with: result, component: currentComponent, session: self)
    }

    public func didProvide(_ data: ActionComponentData, from component: ActionComponent) {
        didProvide(data, from: component, dropInComponent: nil)
    }
    
    public func didOpenExternalApplication(component: ActionComponent) {
        didOpenExternalApplication(actionComponent: component)
    }
    
    @MainActor
    internal func didOpenExternalApplication(actionComponent: ActionComponent) {
        delegate?.didOpenExternalApplication(component: actionComponent, session: self)
    }
}

extension Session {
    
    @MainActor
    package func didProvide(
        _ actionComponentData: ActionComponentData,
        from component: ActionComponent,
        dropInComponent: AnyDropInComponent?
    ) {
        (component as? PresentableComponent)?.viewController.view.isUserInteractionEnabled = false
        
        let request = PaymentDetailsRequest(
            sessionId: state.identifier,
            sessionData: state.data,
            paymentData: actionComponentData.paymentData,
            details: actionComponentData.details
        )
        Task { [weak self] in
            guard let self else { return }
            do {
                let response: PaymentsResponse = try await apiClient.performAsync(request)
                handle(paymentResponse: response, for: component, in: dropInComponent)
            } catch {
                finish(with: error, component: component)
            }
        }
    }
}
