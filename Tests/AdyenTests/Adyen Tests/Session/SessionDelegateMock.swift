//
//  SessionDelegateMock.swift
//  AdyenUIKitTests
//
//  Created by Eren Besel on 3/29/22.
//  Copyright © 2022 Adyen. All rights reserved.
//

@_spi(AdyenInternal) import Adyen
@_spi(AdyenInternal) import AdyenActions
import AdyenComponents
import AdyenDropIn
import AdyenSession

class SessionDelegateMock: AdyenSessionDelegate {
    
    var handlerMock: SessionAdvancedHandlerMock?
    var onDidComplete: ((SessionPaymentResultCode, Component, AdyenSession) -> Void)?
    var onDidFail: ((Error, Component, AdyenSession) -> Void)?
    var onDidOpenExternalApplication: (() -> Void)?
    
    func didComplete(with resultCode: SessionPaymentResultCode, component: Component, session: AdyenSession) {
        onDidComplete?(resultCode, component, session)
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
