//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenDropIn

internal class DropInComponentDelegateMock: DropInComponentDelegate {
    
    internal init(
        onDidSubmit: ((PaymentComponentData, PaymentComponent, AnyDropInComponent) -> Void)? = nil,
        onPaymentComponentDidFail: ((Error, PaymentComponent, AnyDropInComponent) -> Void)? = nil,
        onDidProvide: ((ActionComponentData, ActionComponent, AnyDropInComponent) -> Void)? = nil,
        onDidComplete: ((ActionComponent, AnyDropInComponent) -> Void)? = nil,
        onActionComponentDidFail: ((Error, ActionComponent, AnyDropInComponent) -> Void)? = nil,
        onDidFail: ((Error, AnyDropInComponent) -> Void)? = nil
    ) {
        self.onDidSubmit = onDidSubmit
        self.onPaymentComponentDidFail = onPaymentComponentDidFail
        self.onDidProvide = onDidProvide
        self.onDidComplete = onDidComplete
        self.onActionComponentDidFail = onActionComponentDidFail
        self.onDidFail = onDidFail
    }
    
    var onDidSubmit: ((_ data: PaymentComponentData, _ component: PaymentComponent, _ dropInComponent: AnyDropInComponent) -> Void)?
    func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent, in dropInComponent: AnyDropInComponent) {
        onDidSubmit?(data, component, dropInComponent)
    }
    
    var onPaymentComponentDidFail: ((_ error: Error, _ component: PaymentComponent, _ dropInComponent: AnyDropInComponent) -> Void)?
    func didFail(with error: Error, from component: PaymentComponent, in dropInComponent: AnyDropInComponent) {
        onPaymentComponentDidFail?(error, component, dropInComponent)
    }
    
    var onDidProvide: ((_ data: ActionComponentData, _ component: ActionComponent, _ dropInComponent: AnyDropInComponent) -> Void)?
    func didProvide(_ data: ActionComponentData, from component: ActionComponent, in dropInComponent: AnyDropInComponent) {
        onDidProvide?(data, component, dropInComponent)
    }
    
    var onDidComplete: ((_ component: ActionComponent, _ dropInComponent: AnyDropInComponent) -> Void)?
    func didComplete(from component: ActionComponent, in dropInComponent: AnyDropInComponent) {
        onDidComplete?(component, dropInComponent)
    }
    
    var onActionComponentDidFail: ((_ error: Error, _ component: ActionComponent, _ dropInComponent: AnyDropInComponent) -> Void)?
    func didFail(with error: Error, from component: ActionComponent, in dropInComponent: AnyDropInComponent) {
        onActionComponentDidFail?(error, component, dropInComponent)
    }
    
    var onDidFail: ((_ error: Error, _ dropInComponent: AnyDropInComponent) -> Void)?
    func didFail(with error: Error, from dropInComponent: AnyDropInComponent) {
        onDidFail?(error, dropInComponent)
    }
    
}
