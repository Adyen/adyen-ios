//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit
import Adyen
#if canImport(AdyenComponents)
    import AdyenComponents
#endif

// :nodoc:
internal final class PreApplePayComponent: Localizable, PresentableComponent, FinalizableComponent, PaymentComponent {
    
    /// :nodoc:
    internal let paymentMethod: PaymentMethod
    
    /// :nodoc:
    private let payment: Payment?
    
    /// :nodoc:
    internal weak var delegate: PaymentComponentDelegate?
    
    /// :nodoc:
    internal var localizationParameters: LocalizationParameters?
    
    /// :nodoc:
    internal weak var presentationDelegate: PresentationDelegate?
    
    /// :nodoc:
    fileprivate let applePayComponent: ApplePayComponent
    
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
    internal init (configuration: ApplePayComponent.Configuration) throws {
        self.payment = configuration.payment
        self.paymentMethod = configuration.paymentMethod
        
        self.applePayComponent = try ApplePayComponent(configuration: configuration)
        self.applePayComponent.delegate = self
    }
    
    /// :nodoc
    internal func didFinalize(with success: Bool) {
        applePayComponent.didFinalize(with: success)
    }
    
    /// :nodoc:
    private func createModel(with amount: Payment.Amount) -> PreApplePayView.Model {
        PreApplePayView.Model(
            hint: amount.formatted,
            style: PreApplePayView.Model.Style(
                hintLabel: TextStyle(font: .preferredFont(forTextStyle: .footnote), color: UIColor.Adyen.componentSecondaryLabel),
                backgroundColor: UIColor.Adyen.componentBackground))
    }
    
}

extension PreApplePayComponent: PaymentComponentDelegate {
    
    internal func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent) {
        delegate?.didSubmit(data, from: self)
    }
    
    internal func didFail(with error: Error, from component: PaymentComponent) {
        delegate?.didFail(with: error, from: self)
    }
    
}

extension PreApplePayComponent: PreApplePayViewDelegate {
    
    /// :nodoc:
    internal func pay() {
        presentationDelegate?.present(component: applePayComponent)
    }
    
}
