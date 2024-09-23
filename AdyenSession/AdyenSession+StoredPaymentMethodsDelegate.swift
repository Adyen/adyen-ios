//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation
import UIKit

@_spi(AdyenInternal)
extension AdyenSession: SessionStoredPaymentMethodsDelegate {
    
    public var showRemovePaymentMethodButton: Bool { sessionContext.configuration.showRemovePaymentMethodButton }
    
    public func disable(storedPaymentMethod: StoredPaymentMethod, dropInComponent: AnyDropInComponent, completion: @escaping Completion<Bool>) {
        let request = DisableStoredPaymentMethodRequest(
            sessionId: sessionContext.identifier,
            sessionData: sessionContext.data,
            storedPaymentMethodId: storedPaymentMethod.identifier
        )
        apiClient.perform(request) { [weak self] result in
            switch result {
            case .success:
                completion(true)
            case let .failure(error):
                self?.showAlert(with: error, on: dropInComponent)
                completion(false)
            }
        }
    }
    
    private func showAlert(with error: Error?, on dropIn: AnyDropInComponent) {
        let localizationParameters = (dropIn as? Localizable)?.localizationParameters
        let title = localizedString(.errorTitle, localizationParameters)
        let message = localizedString(.errorUnknown, localizationParameters)
        let doneTitle = localizedString(.dismissButton, localizationParameters)
        
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let doneAction = UIAlertAction(title: doneTitle, style: .default)
        alertController.addAction(doneAction)
        
        dropIn.viewController.present(alertController, animated: true)
    }
    
    // empty implementation of the old method
    public func disable(storedPaymentMethod: Adyen.StoredPaymentMethod, completion: @escaping Adyen.Completion<Bool>) {
        AdyenAssertion.assertionFailure(message: "Use the new delegate method from session.")
    }
}
