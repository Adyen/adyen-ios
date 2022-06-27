//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// :nodoc:
public final class StoredPaymentMethodComponent: PaymentComponent, PresentableComponent, Localizable {

    /// :nodoc:
    public let apiContext: APIContext
    
    /// :nodoc:
    public var paymentMethod: PaymentMethod { storedPaymentMethod }

    /// :nodoc:
    public weak var delegate: PaymentComponentDelegate?

    /// :nodoc:
    public init(paymentMethod: StoredPaymentMethod,
                apiContext: APIContext) {
        self.storedPaymentMethod = paymentMethod
        self.apiContext = apiContext
    }
    
    private let storedPaymentMethod: StoredPaymentMethod
    
    // MARK: - PresentableComponent

    /// :nodoc:
    public lazy var viewController: UIViewController = {
        Analytics.sendEvent(
            component: storedPaymentMethod.type,
            flavor: _isDropIn ? .dropin : .components,
            context: apiContext
        )
        
        let displayInformation = storedPaymentMethod.localizedDisplayInformation(using: localizationParameters)
        let alertController = UIAlertController(title: localizedString(.dropInStoredTitle,
                                                                       localizationParameters, storedPaymentMethod.name),
                                                message: displayInformation.title,
                                                preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: localizedString(.cancelButton, localizationParameters), style: .cancel) { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.didFail(with: ComponentError.cancelled, from: self)
        }
        alertController.addAction(cancelAction)
        
        let submitActionTitle = localizedSubmitButtonTitle(with: payment?.amount,
                                                           style: .immediate,
                                                           localizationParameters)
        let submitAction = UIAlertAction(title: submitActionTitle, style: .default) { [weak self] _ in
            guard let self = self else { return }
            let details = StoredPaymentDetails(paymentMethod: self.storedPaymentMethod)
            self.submit(data: PaymentComponentData(paymentMethodDetails: details, amount: self.payment?.amount, order: self.order))
        }
        alertController.addAction(submitAction)
        
        return alertController
    }()
    
    /// :nodoc:
    public var localizationParameters: LocalizationParameters?
    
}

/// :nodoc:
public struct StoredPaymentDetails: PaymentMethodDetails {
    
    internal let type: String
    
    internal let storedPaymentMethodIdentifier: String

    /// :nodoc:
    public init(paymentMethod: StoredPaymentMethod) {
        self.type = paymentMethod.type
        self.storedPaymentMethodIdentifier = paymentMethod.identifier
    }
    
    private enum CodingKeys: String, CodingKey {
        case type
        case storedPaymentMethodIdentifier = "storedPaymentMethodId"
    }
    
}
