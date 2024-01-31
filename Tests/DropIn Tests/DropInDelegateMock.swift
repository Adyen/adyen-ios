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
    
    internal init(
        didSubmitHandler: ((PaymentComponentData, AnyDropInComponent) -> Void)? = nil,
        didProvideHandler: ((ActionComponentData, AnyDropInComponent) -> Void)? = nil,
        didCompleteHandler: ((AnyDropInComponent) -> Void)? = nil,
        didFailHandler: ((Error, AnyDropInComponent) -> Void)? = nil,
        didOpenExternalApplicationHandler: ((AnyDropInComponent) -> Void)? = nil,
        didCancelHandler: ((PaymentComponent, AnyDropInComponent) -> Void)? = nil
    ) {
        self.didSubmitHandler = didSubmitHandler
        self.didProvideHandler = didProvideHandler
        self.didCompleteHandler = didCompleteHandler
        self.didFailHandler = didFailHandler
        self.didOpenExternalApplicationHandler = didOpenExternalApplicationHandler
        self.didCancelHandler = didCancelHandler
    }

    var didSubmitHandler: ((PaymentComponentData, AnyDropInComponent) -> Void)?
    var didProvideHandler: ((ActionComponentData, AnyDropInComponent) -> Void)?
    var didCompleteHandler: ((AnyDropInComponent) -> Void)?
    var didFailHandler: ((Error, AnyDropInComponent) -> Void)?
    var didOpenExternalApplicationHandler: ((AnyDropInComponent) -> Void)?
    var didCancelHandler: ((PaymentComponent, AnyDropInComponent) -> Void)?

    func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent, in dropInComponent: AnyDropInComponent) {
        didSubmitHandler?(data, dropInComponent)
    }

    func didProvide(_ data: ActionComponentData, from component: ActionComponent, in dropInComponent: AnyDropInComponent) {
        didProvideHandler?(data, dropInComponent)
    }

    func didComplete(from component: ActionComponent, in dropInComponent: AnyDropInComponent) {
        didCompleteHandler?(dropInComponent)
    }
    
    func didFail(with error: Error, from component: PaymentComponent, in dropInComponent: AnyDropInComponent) {
        didFailHandler?(error, dropInComponent)
    }
    
    func didFail(with error: Error, from component: ActionComponent, in dropInComponent: AnyDropInComponent) {
        didFailHandler?(error, dropInComponent)
    }

    func didFail(with error: Error, from component: AnyDropInComponent) {
        didFailHandler?(error, component)
    }

    func didOpenExternalApplication(component: ActionComponent, in dropInComponent: AnyDropInComponent) {
        didOpenExternalApplicationHandler?(dropInComponent)
    }

    func didCancel(component: PaymentComponent, from dropInComponent: AnyDropInComponent) {
        didCancelHandler?(component, dropInComponent)
    }

}
