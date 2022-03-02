//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

extension DropInSession: DropInComponentDelegate {
    public func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent) {
        session?.didSubmit(data, from: component)
    }
    
    public func didFail(with error: Error, from component: PaymentComponent) {
        session?.didFail(with: error, from: component)
    }
    
    public func didProvide(_ data: ActionComponentData, from component: ActionComponent) {
        session?.didProvide(data, from: component)
    }
    
    public func didComplete(from component: ActionComponent) {
        session?.didComplete(from: component)
    }
    
    public func didFail(with error: Error, from component: ActionComponent) {
        session?.didFail(with: error, from: component)
    }
}
