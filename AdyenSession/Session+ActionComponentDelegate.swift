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
extension Session: ActionComponentDelegate {
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
        didProvide(data, currentComponent: component)
    }
    
    internal func didProvide(_ data: ActionComponentData, currentComponent: Component) {
        (currentComponent as? PresentableComponent)?.viewController.view.isUserInteractionEnabled = false
        let request = PaymentDetailsRequest(sessionId: sessionContext.identifier,
                                            sessionData: sessionContext.data,
                                            paymentData: data.paymentData,
                                            details: data.details)
        apiClient.perform(request) { [weak self] in
            self?.paymentResponseHandler(result: $0, for: currentComponent)
        }
    }
    
    public func didOpenExternalApplication(_ component: ActionComponent) {
        // TODO: call back the merchant
    }
}
