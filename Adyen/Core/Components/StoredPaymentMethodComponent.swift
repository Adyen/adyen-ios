//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

// TODO: Fix Stored PM UI
///  A component that handle stored payment methods.
@MainActor
package final class StoredPaymentMethodComponent: StoredPaymentComponent {

    package var localizationParameters: LocalizationParameters?

    /// The context object for this component.
    package let context: AdyenContext

    /// The stored payment method.
    package var paymentMethod: PaymentMethod {
        storedPaymentMethod
    }

    package weak var delegate: PaymentComponentDelegate?

    /// Initializes new instance of `StoredPaymentMethodComponent`.
    ///
    /// - Parameters:
    ///   - paymentMethod: The stored payment method.
    ///   - context: The context object.
    package init(
        paymentMethod: StoredPaymentMethod,
        context: AdyenContext
    ) {
        self.storedPaymentMethod = paymentMethod
        self.context = context
    }
    
    private let storedPaymentMethod: StoredPaymentMethod
    
    // MARK: - PresentableComponent

    package lazy var viewController: UIViewController = {
        sendInitialAnalytics()
        sendDidLoadEvent()
        
        // TODO: Fix

        let displayInformation = storedPaymentMethod.displayInformation(using: localizationParameters)
        let alertController = UIAlertController(
            title: localizedString(
                .dropInStoredTitle,
                localizationParameters,
                storedPaymentMethod.name
            ),
            message: displayInformation.title,
            preferredStyle: .alert
        )

        let cancelAction = UIAlertAction(title: localizedString(.cancelButton, localizationParameters), style: .cancel) { [weak self] _ in
            guard let self else { return }
            self.delegate?.didFail(with: ComponentError.cancelled, from: self)
        }
        alertController.addAction(cancelAction)

        let submitActionTitle = localizedSubmitButtonTitle(
            with: context.amount,
            style: .immediate,
            localizationParameters
        )
        let submitAction = UIAlertAction(title: submitActionTitle, style: .default) { [weak self] _ in
            guard let self else { return }
            let details = StoredPaymentDetails(paymentMethod: self.storedPaymentMethod)
            self.submit(data: PaymentComponentData(
                paymentMethodDetails: details,
                amount: self.context.amount,
                order: self.order
            ))
        }
        alertController.addAction(submitAction)
        
        return alertController
    }()
    
}

extension StoredPaymentMethodComponent: TrackableComponent {}

/// Store payment method details.
public struct StoredPaymentDetails: PaymentMethodDetails {
    
    @_spi(AdyenInternal)
    public var checkoutAttemptId: String?
    
    /// An encoded string containing important SDK-specific data.
    /// It is recommended to pass this field to your server to ensure maximum performance and reliability.
    public var sdkData: String?
    
    internal let type: PaymentMethodType
    
    internal let storedPaymentMethodIdentifier: String
    
    /// Initializes a new instance of `StoredPaymentDetails`
    ///
    /// - Parameter paymentMethod: The payment method.
    public init(paymentMethod: StoredPaymentMethod) {
        self.type = paymentMethod.type
        self.storedPaymentMethodIdentifier = paymentMethod.identifier
    }
    
    private enum CodingKeys: String, CodingKey {
        case type
        case storedPaymentMethodIdentifier = "storedPaymentMethodId"
        case sdkData
    }
    
}
