//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation

@_spi(AdyenInternal)
extension AdyenSession: StoredPaymentMethodsDelegate {
    
    public func disable(storedPaymentMethod: StoredPaymentMethod, dropInComponent: AnyDropInComponent? = nil, completion: @escaping Completion<Bool>) {
        let request = DisableStoredPaymentMethodRequest(sessionId: sessionContext.identifier,
                                                        sessionData: sessionContext.data,
                                                        storedPaymentMethodId: storedPaymentMethod.identifier)
        apiClient.perform(request) { result in
            switch result {
            case .success:
                completion(true)
            case .failure:
                
                completion(false)
            }
        }
    }
    
    private func showAlert(with error: Error) {}
    
    public func disable(storedPaymentMethod: Adyen.StoredPaymentMethod, completion: @escaping Adyen.Completion<Bool>) {}
}
