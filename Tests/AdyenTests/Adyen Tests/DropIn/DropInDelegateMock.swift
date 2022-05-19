//
//  MockDropInDelegate.swift
//  AdyenUIKitTests
//
//  Created by Vladimir Abramichev on 10/06/2021.
//  Copyright © 2021 Adyen. All rights reserved.
//

@_spi(AdyenInternal) import Adyen
@_spi(AdyenInternal) import AdyenActions
import AdyenDropIn

class DropInDelegateMock: DropInComponentDelegate {

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
