//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenActions)
    import AdyenActions
#endif
import Foundation

/// :nodoc:
extension AdyenSession: ActionComponentDelegate {
    public func didFail(with error: Error, from component: ActionComponent) {
        didFail(with: error, currentComponent: component)
    }

    public func didComplete(from component: ActionComponent) {
        didComplete(currentComponent: component)
    }
    
    internal func didComplete(currentComponent: Component) {
        // TODO: call back the merchant
    }

    public func didProvide(_ data: ActionComponentData, from component: ActionComponent) {
        let handler = delegate?.handlerForAdditionalDetails(in: component, session: self) ?? self
        handler.didProvide(data, from: component, session: self)
    }
    
    public func didOpenExternalApplication(_ component: ActionComponent) {
        // TODO: call back the merchant
    }
}

/// :nodoc:
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
