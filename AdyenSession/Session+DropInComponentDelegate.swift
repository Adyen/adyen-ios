//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

@_spi(AdyenInternal)
extension Session: DropInComponentDelegate {
    public func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent, in dropInComponent: AnyDropInComponent) {
        didSubmit(data, from: component, dropInComponent: dropInComponent)
    }
    
    public func didFail(with error: Error, from component: PaymentComponent, in dropInComponent: AnyDropInComponent) {
        failWithError(error, component)
    }
    
    public func didProvide(_ data: ActionComponentData, from component: ActionComponent, in dropInComponent: AnyDropInComponent) {
        didProvide(data, from: component, dropInComponent: dropInComponent)
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
