//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation

@_spi(AdyenInternal)
extension AdyenSession: DropInComponentDelegate {
    public func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent, in dropInComponent: AnyDropInComponent) {
        let handler = delegate?.handlerForPayments(in: component, session: self) ?? self
        handler.didSubmit(data, from: component, dropInComponent: dropInComponent, session: self)
    }
    
    public func didFail(with error: Error, from component: PaymentComponent, in dropInComponent: AnyDropInComponent) {
        failWithError(error, component)
    }
    
    public func didProvide(_ data: ActionComponentData, from component: ActionComponent, in dropInComponent: AnyDropInComponent) {
        let handler = delegate?.handlerForAdditionalDetails(in: component, session: self) ?? self
        handler.didProvide(data, from: component, session: self)
    }
    
    public func didComplete(from component: ActionComponent, in dropInComponent: AnyDropInComponent) {
        didComplete(currentComponent: dropInComponent)
    }
    
    public func didFail(with error: Error, from component: ActionComponent, in dropInComponent: AnyDropInComponent) {
        failWithError(error, component)
    }
    
    public func didFail(with error: Error, from dropInComponent: AnyDropInComponent) {
        failWithError(error, dropInComponent)
    }
    
    public func didOpenExternalApplication(component: ActionComponent, in dropInComponent: AnyDropInComponent) {
        didOpenExternalApplication(actionComponent: component)
    }
    
}
