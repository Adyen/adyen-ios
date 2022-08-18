//
// Copyright (c) 2022 Adyen N.V.
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
    internal let apiContext: APIContext
    
    /// :nodoc:
    internal let paymentMethod: PaymentMethod
    
    /// :nodoc:
    internal let amount: Amount
    
    /// :nodoc:
    internal weak var delegate: PaymentComponentDelegate?
    
    /// :nodoc:
    internal var localizationParameters: LocalizationParameters?
    
    /// :nodoc:
    internal weak var presentationDelegate: PresentationDelegate?
    
    /// :nodoc:
    fileprivate let applePayComponent: ApplePayComponent
    
    /// :nodoc:
    internal let style: ApplePayStyle
    
    /// :nodoc:
    internal lazy var viewController: UIViewController = {
        let view = PreApplePayView(model: createModel(with: amount))
        let viewController = ADYViewController(view: view, title: "Apple Pay")
        view.delegate = self
        
        return viewController
    }()
    
    /// :nodoc:
    internal let requiresModalPresentation: Bool = true
    
    /// :nodoc:
    internal init(paymentMethod: ApplePayPaymentMethod,
                  apiContext: APIContext,
                  payment: Payment,
                  configuration: ApplePayComponent.Configuration,
                  style: ApplePayStyle) throws {
        self.apiContext = apiContext
        self.amount = payment.amount
        self.paymentMethod = paymentMethod
        self.style = style

        self.applePayComponent = try ApplePayComponent(paymentMethod: paymentMethod,
                                                       apiContext: apiContext,
                                                       payment: payment,
                                                       configuration: configuration)
        self.applePayComponent.delegate = self
    }
    
    /// :nodoc
    internal func didFinalize(with success: Bool) {
        assertionFailure("Do not call this method. Use didFinalize(with success:completion:) ")
    }

    internal func didFinalize(with success: Bool, completion: (() -> Void)?) {
        applePayComponent.didFinalize(with: success, completion: completion)
    }
    
    /// :nodoc:
    private func createModel(with amount: Amount) -> PreApplePayView.Model {
        PreApplePayView.Model(hint: amount.formatted, style: style)
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
