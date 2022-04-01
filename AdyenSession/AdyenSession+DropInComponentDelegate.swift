//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// :nodoc:
extension AdyenSession: DropInComponentDelegate {
    public func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent, in dropInComponent: AnyDropInComponent) {
        let handler = delegate?.handlerForPayments(in: component, session: self) ?? self
        handler.didSubmit(data, from: component, session: self)
    }
    
    public func didFail(with error: Error, from component: PaymentComponent, in dropInComponent: AnyDropInComponent) {
        didFail(with: error, currentComponent: dropInComponent)
    }
    
    public func didProvide(_ data: ActionComponentData, from component: ActionComponent, in dropInComponent: AnyDropInComponent) {
        let handler = delegate?.handlerForAdditionalDetails(in: component, session: self) ?? self
        handler.didProvide(data, from: component, session: self)
    }
    
    public func didComplete(from component: ActionComponent, in dropInComponent: AnyDropInComponent) {
        didComplete(currentComponent: dropInComponent)
    }
    
    public func didFail(with error: Error, from component: ActionComponent, in dropInComponent: AnyDropInComponent) {
        didFail(with: error, currentComponent: dropInComponent)
    }
    
    public func didFail(with error: Error, from dropInComponent: AnyDropInComponent) {
        didFail(with: error, currentComponent: dropInComponent)
    }
    
    public func didOpenExternalApplication(_ component: ActionComponent, in dropInComponent: AnyDropInComponent) {
        didOpenExternalApplication(actionComponent: component)
    }
    
}
