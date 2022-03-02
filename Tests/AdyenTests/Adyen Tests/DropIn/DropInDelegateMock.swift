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

    var didSubmitHandler: ((PaymentComponentData, DropInComponent) -> Void)?
    var didProvideHandler: ((ActionComponentData, DropInComponent) -> Void)?
    var didCompleteHandler: ((DropInComponent) -> Void)?
    var didFailHandler: ((Error, DropInComponent) -> Void)?
    var didOpenExternalApplicationHandler: ((DropInComponent) -> Void)?
    var didCancelHandler: ((PaymentComponent, DropInComponent) -> Void)?

    func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent, in dropInComponent: DropInComponent) {
        didSubmitHandler?(data, dropInComponent)
    }

    func didProvide(_ data: ActionComponentData, from component: ActionComponent, in dropInComponent: DropInComponent) {
        didProvideHandler?(data, dropInComponent)
    }

    func didComplete(from component: ActionComponent, in dropInComponent: DropInComponent) {
        didCompleteHandler?(dropInComponent)
    }
    
    func didFail(with error: Error, from component: PaymentComponent, in dropInComponent: DropInComponent) {
        didFailHandler?(error, dropInComponent)
    }
    
    func didFail(with error: Error, from component: ActionComponent, in dropInComponent: DropInComponent) {
        didFailHandler?(error, dropInComponent)
    }

    func didFail(with error: Error, from component: DropInComponent) {
        didFailHandler?(error, component)
    }

    func didOpenExternalApplication(_ component: ActionComponent, in dropInComponent: DropInComponent) {
        didOpenExternalApplicationHandler?(dropInComponent)
    }

    func didCancel(component: PaymentComponent, from dropInComponent: DropInComponent) {
        didCancelHandler?(component, dropInComponent)
    }

}
