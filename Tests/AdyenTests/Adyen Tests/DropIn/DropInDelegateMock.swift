//
//  DropInDelegateMock.swift
//  AdyenUIKitTests
//
//  Created by Vladimir Abramichev on 10/06/2021.
//  Copyright © 2021 Adyen. All rights reserved.
//

import Adyen
import AdyenActions
import AdyenDropIn

class DropInDelegateMock: DropInComponentDelegate {

    var didSubmitHandler: ((PaymentComponentData, PaymentMethod, DropInComponent) -> Void)?
    var didProvideHandler: ((ActionComponentData, DropInComponent) -> Void)?
    var didCompleteHandler: ((DropInComponent) -> Void)?
    var didFailHandler: ((Error, DropInComponent) -> Void)?
    var didOpenExternalApplicationHandler: ((DropInComponent) -> Void)?
    var didCancelHandler: ((PaymentComponent, DropInComponent) -> Void)?

    func didSubmit(_ data: PaymentComponentData, for paymentMethod: PaymentMethod, from component: DropInComponent) {
        didSubmitHandler?(data, paymentMethod, component)
    }

    func didProvide(_ data: ActionComponentData, from component: DropInComponent) {
        didProvideHandler?(data, component)
    }

    func didComplete(from component: DropInComponent) {
        didCompleteHandler?(component)
    }

    func didFail(with error: Error, from component: DropInComponent) {
        didFailHandler?(error, component)
    }

    func didOpenExternalApplication(_ component: DropInComponent) {
        didOpenExternalApplicationHandler?(component)
    }

    func didCancel(component: PaymentComponent, from dropInComponent: DropInComponent) {
        didCancelHandler?(component, dropInComponent)
    }

}
