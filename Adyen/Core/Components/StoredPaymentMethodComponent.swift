//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

///  A component that handle stored payment methods.
public final class StoredPaymentMethodComponent: PaymentComponent,
    PresentableComponent,
    PaymentAware {

    /// Component's configuration.
    public var configuration: Configuration

    /// The context object for this component.
    public let context: AdyenContext

    /// The stored payment method.
    public var paymentMethod: PaymentMethod { storedPaymentMethod }

    public weak var delegate: PaymentComponentDelegate?
    
    /// Initializes new instance of `StoredPaymentMethodComponent`.
    ///
    /// - Parameters:
    ///   - paymentMethod: The stored payment method.
    ///   - context: The context object.
    ///   - configuration: The configuration for the component.
    public init(paymentMethod: StoredPaymentMethod,
                context: AdyenContext,
                configuration: Configuration = .init()) {
        self.storedPaymentMethod = paymentMethod
        self.context = context
        self.configuration = configuration
    }
    
    private let storedPaymentMethod: StoredPaymentMethod
    
    // MARK: - PresentableComponent

    public lazy var viewController: UIViewController = {
        sendInitialAnalytics()
        sendDidLoadEvent()

        let localizationParameters = configuration.localizationParameters
        let displayInformation = storedPaymentMethod.displayInformation(using: localizationParameters)
        let alertController = UIAlertController(title: localizedString(.dropInStoredTitle,
                                                                       localizationParameters,
                                                                       storedPaymentMethod.name),
                                                message: displayInformation.title,
                                                preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: localizedString(.cancelButton, localizationParameters), style: .cancel) { [weak self] _ in
            guard let self else { return }
            self.delegate?.didFail(with: ComponentError.cancelled, from: self)
        }
        alertController.addAction(cancelAction)
        
        let submitActionTitle = localizedSubmitButtonTitle(with: payment?.amount,
                                                           style: .immediate,
                                                           localizationParameters)
        let submitAction = UIAlertAction(title: submitActionTitle, style: .default) { [weak self] _ in
            guard let self else { return }
            let details = StoredPaymentDetails(paymentMethod: self.storedPaymentMethod)
            self.submit(data: PaymentComponentData(paymentMethodDetails: details,
                                                   amount: self.payment?.amount,
                                                   order: self.order))
        }
        alertController.addAction(submitAction)
        
        return alertController
    }()
    
}

extension StoredPaymentMethodComponent {

    /// Configuration for Stored Payment type components.
    public struct Configuration: AnyBasicComponentConfiguration {

        /// A Boolean value that determines whether the payment button is displayed. Defaults to `false`.
        public var hidePayButton: Bool

        public var localizationParameters: LocalizationParameters?

        /// Initializes the configuration for Issuer list type components.
        /// - Parameters:
        ///   - hidePayButton: Boolean value that determines whether the payment button is displayed.
        ///   Defaults to `false`.
        ///   - localizationParameters: Localization parameters.
        public init(hidePayButton: Bool = false,
                    localizationParameters: LocalizationParameters? = nil) {
            self.hidePayButton = hidePayButton
            self.localizationParameters = localizationParameters
        }
    }

}

@_spi(AdyenInternal)
extension StoredPaymentMethodComponent: TrackableComponent {}

/// Store payment method details.
public struct StoredPaymentDetails: PaymentMethodDetails {
    
    @_spi(AdyenInternal)
    public var checkoutAttemptId: String?
    
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
    }
    
}
