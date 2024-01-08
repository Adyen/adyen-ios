//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation
import UIKit

/// A component that provides a form for stored card payments.
internal final class StoredCardComponent: PaymentComponent, PaymentAware, PresentableComponent, Localizable {
    
    /// The context object for this component.
    internal let context: AdyenContext
    
    /// The card payment method.
    internal var paymentMethod: PaymentMethod { storedCardPaymentMethod }
    
    /// The delegate of the component.
    internal weak var delegate: PaymentComponentDelegate?
    
    internal var localizationParameters: LocalizationParameters?
    
    internal var requiresModalPresentation: Bool = false
    
    private let storedCardPaymentMethod: StoredCardPaymentMethod
    
    internal init(storedCardPaymentMethod: StoredCardPaymentMethod,
                  context: AdyenContext) {
        self.storedCardPaymentMethod = storedCardPaymentMethod
        self.context = context
    }
    
    internal lazy var viewController: UIViewController = {
        
        let localizationParameters = localizationParameters

        let topSpace = UIView()
        topSpace.frame.size.height = 80
        
        let title = UILabel()
        title.textAlignment = .center
        title.font = .boldSystemFont(ofSize: 32)
        title.text = localizedString(
            .dropInStoredTitle,
            localizationParameters,
            storedCardPaymentMethod.name
        )
        
        let inputField = UITextField()
        inputField.placeholder = "Enter your security code"
        
        let submitButton = UIButton(style: .init(title: .init(font: .boldSystemFont(ofSize: 18), color: .white)))
        submitButton.setTitle("Submit", for: .normal)
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        
        let bottomSpace = UIView()
        bottomSpace.frame.size.height = 200
        
        let view = UIStackView(arrangedSubviews: [
            topSpace,
            title,
            inputField,
            submitButton,
            bottomSpace
        ])
        view.axis = .vertical
        view.backgroundColor = .white
        let storedPaymentMethodConfirmation = ADYViewController(
            view: view
        )
        
        let navigationController = UINavigationController(rootViewController: storedPaymentMethodConfirmation)
        
        if #available(iOS 13.0, *) {
            navigationController.isModalInPresentation = true
            storedPaymentMethodConfirmation.navigationItem.rightBarButtonItem = .init(
                barButtonSystemItem: .close,
                target: self,
                action: #selector(cancelTapped)
            )
        }
        
        DispatchQueue.main.async {
            inputField.becomeFirstResponder()
        }
        
        return navigationController
        
        storedCardAlertManager.alertController
    }()
    
    @objc
    func cancelTapped() {
        self.viewController.dismiss(animated: true)
        self.delegate?.didFail(with: ComponentError.cancelled, from: self)
    }
    
    @objc
    func submitTapped() {
        self.viewController.dismiss(animated: true)
        // TODO: Implement correctly
        self.submit(data: PaymentComponentData(paymentMethodDetails: StoredPaymentDetails(paymentMethod: storedCardPaymentMethod),
                                               amount: self.payment?.amount,
                                               order: self.order))
    }
    
    internal lazy var storedCardAlertManager: StoredCardAlertManager = {
        Analytics.sendEvent(
            component: paymentMethod.type.rawValue,
            flavor: _isDropIn ? .dropin : .components,
            context: context.apiContext
        )
        sendTelemetryEvent()
        
        let manager = StoredCardAlertManager(paymentMethod: storedCardPaymentMethod,
                                             context: context,
                                             amount: payment?.amount)
        
        manager.localizationParameters = localizationParameters
        manager.completionHandler = { [weak self] result in
            guard let self else { return }
            
            switch result {
            case let .success(details):
                self.submit(data: PaymentComponentData(paymentMethodDetails: details,
                                                       amount: self.payment?.amount,
                                                       order: self.order))
            case let .failure(error):
                self.delegate?.didFail(with: error, from: self)
            }
        }
        
        return manager
    }()
}

/// :nodoc:
extension StoredCardComponent: TrackableComponent {}
