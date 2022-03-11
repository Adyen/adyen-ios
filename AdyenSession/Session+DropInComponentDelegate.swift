//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// :nodoc:
extension Session: DropInComponentDelegate {
    public func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent, in dropInComponent: DropInComponentProtocol) {
        didSubmit(data, currentComponent: dropInComponent)
    }
    
    public func didFail(with error: Error, from component: PaymentComponent, in dropInComponent: DropInComponentProtocol) {
        didFail(with: error, currentComponent: dropInComponent)
    }
    
    public func didProvide(_ data: ActionComponentData, from component: ActionComponent, in dropInComponent: DropInComponentProtocol) {
        didProvide(data, currentComponent: dropInComponent)
    }
    
    public func didComplete(from component: ActionComponent, in dropInComponent: DropInComponentProtocol) {
        didComplete(currentComponent: dropInComponent)
    }
    
    public func didFail(with error: Error, from component: ActionComponent, in dropInComponent: DropInComponentProtocol) {
        didFail(with: error, currentComponent: dropInComponent)
    }
    
    public func didFail(with error: Error, from dropInComponent: DropInComponentProtocol) {
        didFail(with: error, currentComponent: dropInComponent)
    }
    
}
