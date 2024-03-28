//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
@_spi(AdyenInternal) import AdyenActions
import AdyenComponents
import AdyenDropIn
import AdyenSession

class SessionDelegateMock: AdyenSessionDelegate {
    
    var handlerMock: SessionAdvancedHandlerMock?
    var onDidComplete: ((AdyenSessionResult, Component, AdyenSession) -> Void)?
    var onDidFail: ((Error, Component, AdyenSession) -> Void)?
    var onDidOpenExternalApplication: (() -> Void)?
    
    func didComplete(with result: AdyenSessionResult, component: Component, session: AdyenSession) {
        onDidComplete?(result, component, session)
    }
    
    func didFail(with error: Error, from component: Component, session: AdyenSession) {
        onDidFail?(error, component, session)
    }
    
    func didOpenExternalApplication(component: ActionComponent, session: AdyenSession) {
        onDidOpenExternalApplication?()
    }
    
    func handlerForPayments(in component: PaymentComponent, session: AdyenSession) -> AdyenSessionPaymentsHandler? {
        handlerMock
    }
    
    func handlerForAdditionalDetails(in component: ActionComponent, session: AdyenSession) -> AdyenSessionPaymentDetailsHandler? {
        handlerMock
    }
}

class SessionAdvancedHandlerMock: AdyenSessionPaymentsHandler, AdyenSessionPaymentDetailsHandler {
    
    var onDidSubmit: ((PaymentComponentData, Component, AdyenSession) -> Void)?
    var onDidProvide: ((ActionComponentData, Component, AdyenSession) -> Void)?
    
    func didSubmit(_ paymentComponentData: PaymentComponentData,
                   from component: Component,
                   dropInComponent: AnyDropInComponent?,
                   session: AdyenSession) {
        onDidSubmit?(paymentComponentData, component, session)
    }
    
    func didProvide(_ actionComponentData: ActionComponentData, from component: ActionComponent, session: AdyenSession) {
        onDidProvide?(actionComponentData, component, session)
    }
}
