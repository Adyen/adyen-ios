//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit
import Adyen
import AdyenComponents

// :nodoc:
internal final class PreApplePayComponent: Localizable, PresentableComponent, FinalizableComponent, PaymentComponent {
    
    /// :nodoc:
    internal let paymentMethod: PaymentMethod
    
    /// :nodoc
    private let applePayConfiguration: DropInComponent.ApplePayConfiguration
    
    /// :nodoc:
    private let payment: Payment?
    
    /// :nodoc:
    internal weak var delegate: PaymentComponentDelegate?
    
    /// :nodoc:
    internal var localizationParameters: LocalizationParameters?
    
    /// :nodoc:
    internal weak var presentationDelegate: PresentationDelegate?
    
    /// :nodoc:
    fileprivate var applePayComponent: ApplePayComponent?
    
    /// :nodoc:
    internal lazy var viewController: UIViewController = {
        let viewController = UIViewController()
        viewController.title = "Apple Pay"
        let view = payment.map(\.amount)
            .map(createModel(with:))
            .map(PreApplePayView.init(model: ))
        view?.delegate = self
        viewController.view = view
        return viewController
    }()
    
    /// :nodoc:
    internal let requiresModalPresentation: Bool = true
    
    /// :nodoc:
    internal init(payment: Payment?, paymentMethod: PaymentMethod, configuration: DropInComponent.ApplePayConfiguration) {
        self.payment = payment
        self.paymentMethod = paymentMethod
        self.applePayConfiguration = configuration
    }
    
    /// :nodoc
    internal func didFinalize(with success: Bool) {
        applePayComponent?.didFinalize(with: success)
    }
    
    /// :nodoc:
    private func createModel(with amount: Payment.Amount) -> PreApplePayView.Model {
        PreApplePayView.Model(
            hint: amount.formatted,
            style: PreApplePayView.Model.Style(
                hintLabel: TextStyle(font: .preferredFont(forTextStyle: .footnote), color: UIColor.Adyen.componentSecondaryLabel),
                backgroundColor: UIColor.Adyen.componentBackground))
    }
    
    /// :nodoc:
    private func makeViewController() -> UIViewController {
        let viewController = UIViewController()
        viewController.title = "Apple Pay"
        let view = payment.map(\.amount)
            .map(createModel(with:))
            .map(PreApplePayView.init(model: ))
        view?.delegate = self
        viewController.view = view
        return viewController
    }
}

extension PreApplePayComponent: PaymentComponentDelegate {
    
    internal func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent) {
        delegate?.didSubmit(data, from: self)
        viewController.navigationController?.popViewController(animated: true)
    }
    
    internal func didFail(with error: Error, from component: PaymentComponent) {
        delegate?.didFail(with: error, from: self)
    }
    
}

extension PreApplePayComponent: Cancellable {
    
    func didCancel() {
        viewController.navigationController?.popViewController(animated: true)
    }
    
}

extension PreApplePayComponent: PreApplePayViewDelegate {
    
    /// :nodoc:
    internal func pay() {
        guard let navigationController = viewController.navigationController as? DropInNavigationController else {
            adyenPrint("Failed to instantiate ApplePayComponent because something went wrong")
            return
        }
        
        guard let payment = payment else {
            adyenPrint("Failed to instantiate ApplePayComponent because payment is missing")
            return
        }
        
        guard let paymentMethod = paymentMethod as? ApplePayPaymentMethod else {
            adyenPrint("Failed to instantiate ApplePayComponent because paymentMethod is not correct")
            return
        }
    
        let configuration = ApplePayComponent.Configuration(
            payment: payment,
            paymentMethod: paymentMethod,
            summaryItems: applePayConfiguration.summaryItems,
            merchantIdentifier: applePayConfiguration.merchantIdentifier,
            requiredBillingContactFields: applePayConfiguration.requiredBillingContactFields,
            requiredShippingContactFields: applePayConfiguration.requiredShippingContactFields)
        
        do {
            let component = try ApplePayComponent(configuration: configuration)
            component.delegate = self
            applePayComponent = component
            navigationController.present(asModal: component)
        } catch {
            adyenPrint("Failed to instantiate ApplePayComponent because of error: \(error.localizedDescription)")
        }
    }
}
