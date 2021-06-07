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

    internal let paymentMethod: PaymentMethod

    internal let apiContext: APIContext

    private var payment: Payment? { _payment }
    
    private let _payment: Payment
    
    internal weak var delegate: PaymentComponentDelegate?
    
    internal var localizationParameters: LocalizationParameters?
    
    internal weak var presentationDelegate: PresentationDelegate?
    
    fileprivate let applePayComponent: ApplePayComponent
    
    internal lazy var viewController: UIViewController = {
        let view = PreApplePayView(model: createModel(with: _payment.amount))
        let viewController = ADYViewController(view: view, title: "Apple Pay")
        view.delegate = self
        
        return viewController
    }()
    
    internal let requiresModalPresentation: Bool = true
    
    internal init(paymentMethod: ApplePayPaymentMethod,
                  apiContext: APIContext,
                  payment: Payment,
                  configuration: ApplePayComponent.Configuration) throws {
        self.apiContext = apiContext
        self._payment = payment
        self.paymentMethod = paymentMethod

        self.applePayComponent = try ApplePayComponent(paymentMethod: paymentMethod,
                                                       apiContext: apiContext,
                                                       payment: payment,
                                                       configuration: configuration)
        self.applePayComponent.delegate = self
    }
    
    internal func didFinalize(with success: Bool) {
        applePayComponent.didFinalize(with: success)
    }
    
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
