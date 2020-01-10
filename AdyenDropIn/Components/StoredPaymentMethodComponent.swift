//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal final class StoredPaymentMethodComponent: PaymentComponent, PresentableComponent, Localizable {
    
    internal let paymentMethod: PaymentMethod
    
    internal weak var delegate: PaymentComponentDelegate?
    
    internal init(paymentMethod: StoredPaymentMethod) {
        self.paymentMethod = paymentMethod
        self.storedPaymentMethod = paymentMethod
    }
    
    private let storedPaymentMethod: StoredPaymentMethod
    
    // MARK: - PresentableComponent
    
    internal var preferredPresentationMode: PresentableComponentPresentationMode {
        return .present
    }
    
    internal lazy var viewController: UIViewController = {
        Analytics.sendEvent(component: paymentMethod.type, flavor: _isDropIn ? .dropin : .components, environment: environment)
        
        let displayInformation = paymentMethod.localizedDisplayInformation(using: localizationParameters)
        let alertController = UIAlertController(title: ADYLocalizedString("adyen.dropIn.stored.title",
                                                                          localizationParameters, paymentMethod.name),
                                                message: displayInformation.title,
                                                preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: ADYLocalizedString("adyen.cancelButton", localizationParameters), style: .cancel) { _ in
            self.delegate?.didFail(with: ComponentError.cancelled, from: self)
        }
        alertController.addAction(cancelAction)
        
        let submitActionTitle = ADYLocalizedSubmitButtonTitle(with: payment?.amount, localizationParameters)
        let submitAction = UIAlertAction(title: submitActionTitle, style: .default) { _ in
            let details = StoredPaymentDetails(paymentMethod: self.storedPaymentMethod)
            self.delegate?.didSubmit(PaymentComponentData(paymentMethodDetails: details), from: self)
        }
        alertController.addAction(submitAction)
        
        return alertController
    }()
    
    /// :nodoc:
    internal var localizationParameters: LocalizationParameters?
    
}

internal struct StoredPaymentDetails: PaymentMethodDetails {
    
    internal let type: String
    
    internal let storedPaymentMethodIdentifier: String
    
    internal init(paymentMethod: StoredPaymentMethod) {
        self.type = paymentMethod.type
        self.storedPaymentMethodIdentifier = paymentMethod.identifier
    }
    
    private enum CodingKeys: String, CodingKey {
        case type
        case storedPaymentMethodIdentifier = "storedPaymentMethodId"
    }
    
}
