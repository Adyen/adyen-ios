//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
#if canImport(AdyenActions)
    import AdyenActions
#endif
import Adyen

extension DropInSession: DropInComponentDelegate {
    
    public func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent, in dropInComponent: DropInComponent) {
        session?.didSubmit(data, from: component)
    }
    
    public func didFail(with error: Error, from component: PaymentComponent, in dropInComponent: DropInComponent) {
        session?.didFail(with: error, from: component)
    }
    
    public func didProvide(_ data: ActionComponentData, from component: ActionComponent, in dropInComponent: DropInComponent) {
        session?.didProvide(data, from: component)
    }
    
    public func didComplete(from component: ActionComponent, in dropInComponent: DropInComponent) {
        session?.didComplete(from: component)
    }
    
    public func didFail(with error: Error, from component: ActionComponent, in dropInComponent: DropInComponent) {
        session?.didFail(with: error, from: component)
    }
    
    public func didOpenExternalApplication(_ component: ActionComponent, in dropInComponent: DropInComponent) {
        session?.didOpenExternalApplication(component)
    }
    
}
