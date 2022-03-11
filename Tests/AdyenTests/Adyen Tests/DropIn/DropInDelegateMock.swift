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

    var didSubmitHandler: ((PaymentComponentData, DropInComponentProtocol) -> Void)?
    var didProvideHandler: ((ActionComponentData, DropInComponentProtocol) -> Void)?
    var didCompleteHandler: ((DropInComponentProtocol) -> Void)?
    var didFailHandler: ((Error, DropInComponentProtocol) -> Void)?
    var didOpenExternalApplicationHandler: ((DropInComponentProtocol) -> Void)?
    var didCancelHandler: ((PaymentComponent, DropInComponentProtocol) -> Void)?

    func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent, in dropInComponent: DropInComponentProtocol) {
        didSubmitHandler?(data, dropInComponent)
    }

    func didProvide(_ data: ActionComponentData, from component: ActionComponent, in dropInComponent: DropInComponentProtocol) {
        didProvideHandler?(data, dropInComponent)
    }

    func didComplete(from component: ActionComponent, in dropInComponent: DropInComponentProtocol) {
        didCompleteHandler?(dropInComponent)
    }
    
    func didFail(with error: Error, from component: PaymentComponent, in dropInComponent: DropInComponentProtocol) {
        didFailHandler?(error, dropInComponent)
    }
    
    func didFail(with error: Error, from component: ActionComponent, in dropInComponent: DropInComponentProtocol) {
        didFailHandler?(error, dropInComponent)
    }

    func didFail(with error: Error, from component: DropInComponentProtocol) {
        didFailHandler?(error, component)
    }

    func didOpenExternalApplication(_ component: ActionComponent, in dropInComponent: DropInComponentProtocol) {
        didOpenExternalApplicationHandler?(dropInComponent)
    }

    func didCancel(component: PaymentComponent, from dropInComponent: DropInComponentProtocol) {
        didCancelHandler?(component, dropInComponent)
    }

}
