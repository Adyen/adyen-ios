//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation

final class StoredPaymentMethodDelegateMock: StoredPaymentMethodsDelegate {
    
    var onDisableCallCount = 0
    var onDisable: ((_ paymentMethod: StoredPaymentMethod) -> Bool)?
    
    func disable(storedPaymentMethod: StoredPaymentMethod, completion: @escaping Completion<Bool>) {
        let success = onDisable?(storedPaymentMethod)
        onDisableCallCount += 1
        completion(success!)
    }
}

final class SessionStoredPaymentMethodDelegateMock: SessionStoredPaymentMethodsDelegate {
    
    var showRemovePaymentMethodButton: Bool = true
    
    var isSession: Bool = true
    
    var onDisableCallCount = 0
    var onDisable: ((_ paymentMethod: StoredPaymentMethod, _ dropIn: AnyDropInComponent) -> Bool)?
    
    func disable(storedPaymentMethod: StoredPaymentMethod, dropInComponent: AnyDropInComponent, completion: @escaping Completion<Bool>) {
        let success = onDisable?(storedPaymentMethod, dropInComponent)
        onDisableCallCount += 1
        completion(success!)
    }
    
    func disable(storedPaymentMethod: StoredPaymentMethod, completion: @escaping Completion<Bool>) {}
}
