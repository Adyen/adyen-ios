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
extension AdyenSession: ActionComponentDelegate {
    public func didFail(with error: Error, from component: ActionComponent) {
        failWithError(error, component)
    }

    public func didComplete(from component: ActionComponent) {
        didComplete(currentComponent: component)
    }
    
    internal func didComplete(currentComponent: Component) {
        guard let resultCode = sessionContext.resultCode else {
            AdyenAssertion.assertionFailure(message: "Missing resultCode.")
            return
        }
        delegate?.didComplete(with: SessionPaymentResultCode(paymentResultCode: resultCode),
                              component: currentComponent, session: self)
    }

    public func didProvide(_ data: ActionComponentData, from component: ActionComponent) {
        let handler = delegate?.handlerForAdditionalDetails(in: component, session: self) ?? self
        handler.didProvide(data, from: component, session: self)
    }
    
    public func didOpenExternalApplication(component: ActionComponent) {
        didOpenExternalApplication(actionComponent: component)
    }
    
    internal func didOpenExternalApplication(actionComponent: ActionComponent) {
        delegate?.didOpenExternalApplication(component: actionComponent, session: self)
    }
}

@_spi(AdyenInternal)
extension AdyenSession: AdyenSessionPaymentDetailsHandler {
    public func didProvide(_ actionComponentData: ActionComponentData,
                           from component: ActionComponent,
                           session: AdyenSession) {
        (component as? PresentableComponent)?.viewController.view.isUserInteractionEnabled = false
        let request = PaymentDetailsRequest(sessionId: sessionContext.identifier,
                                            sessionData: sessionContext.data,
                                            paymentData: actionComponentData.paymentData,
                                            details: actionComponentData.details)
        apiClient.perform(request) { [weak self] in
            self?.handle(paymentResponseResult: $0, for: component)
        }
    }
}
