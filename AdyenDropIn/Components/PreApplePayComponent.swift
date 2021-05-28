//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit
#if canImport(AdyenComponents)
    import AdyenComponents
#endif

// :nodoc:
internal final class PreApplePayComponent: Localizable, PresentableComponent, FinalizableComponent, PaymentComponent {
    
    /// :nodoc:
    internal let paymentMethod: PaymentMethod
    
    /// :nodoc:
    private var payment: Payment? { _payment }
    
    /// :nodoc:
    private let _payment: Payment
    
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
        let view = PreApplePayView(model: createModel(with: _payment.amount))
        let viewController = ADYViewController(view: view, title: "Apple Pay")
        view.delegate = self
        
        return viewController
    }()
    
    /// :nodoc:
    internal let requiresModalPresentation: Bool = true
    
    /// :nodoc:
    internal init(configuration: ApplePayComponent.Configuration) throws {
        self._payment = configuration.payment
        self.paymentMethod = configuration.paymentMethod
        
        self.applePayComponent = try ApplePayComponent(configuration: configuration)
        self.applePayComponent.delegate = self
    }
    
    /// :nodoc
    internal func didFinalize(with success: Bool) {
        applePayComponent.didFinalize(with: success)
    }
    
    /// :nodoc:
    private func createModel(with amount: Amount) -> PreApplePayView.Model {
        PreApplePayView.Model(
            hint: amount.formatted,
            style: PreApplePayView.Model.Style(
                hintLabel: TextStyle(font: .preferredFont(forTextStyle: .footnote), color: UIColor.Adyen.componentSecondaryLabel),
                backgroundColor: UIColor.Adyen.componentBackground
            )
        )
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
