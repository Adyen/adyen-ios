//
//  MockDropInDelegate.swift
//  AdyenUIKitTests
//
//  Created by Vladimir Abramichev on 10/06/2021.
//  Copyright © 2021 Adyen. All rights reserved.
//

import Adyen
import AdyenActions
import AdyenDropIn

class DropInDelegateMock: DropInComponentDelegate {
    
    var paymentComponentDelegateMock: PaymentComponentDelegateMock = .init()
    
    var actionComponentDelegateMock: ActionComponentDelegateMock = .init()

    var didFailHandler: ((Error, DropInComponent) -> Void)?
    var didCancelHandler: ((PaymentComponent, DropInComponent) -> Void)?
    
    func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent) {
        paymentComponentDelegateMock.didSubmit(data, from: component)
    }
    
    func didProvide(_ data: ActionComponentData, from component: ActionComponent) {
        actionComponentDelegateMock.didProvide(data, from: component)
    }
    
    func didComplete(from component: ActionComponent) {
        actionComponentDelegateMock.didComplete(from: component)
    }

    func didFail(with error: Error, from component: ActionComponent) {
        actionComponentDelegateMock.didFail(with: error, from: component)
    }
    
    func didFail(with error: Error, from component: PaymentComponent) {
        paymentComponentDelegateMock.didFail(with: error, from: component)
    }
    
    func didFail(with error: Error, from dropInComponent: DropInComponent) {
        didFailHandler?(error, dropInComponent)
    }
    
    func didOpenExternalApplication(_ component: ActionComponent) {
        actionComponentDelegateMock.didOpenExternalApplication(component)
    }

    func didCancel(component: PaymentComponent, from dropInComponent: DropInComponent) {
        didCancelHandler?(component, dropInComponent)
    }

}
