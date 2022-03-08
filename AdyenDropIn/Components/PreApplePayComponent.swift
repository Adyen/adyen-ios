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
internal final class PreApplePayComponent: PresentableComponent, FinalizableComponent, PaymentComponent {
    
    internal struct Configuration: Localizable {
        
        internal var style: ApplePayStyle

        internal var localizationParameters: LocalizationParameters?

        internal init(style: ApplePayStyle = ApplePayStyle(),
                      localizationParameters: LocalizationParameters? = nil) {
            self.style = style
            self.localizationParameters = localizationParameters
        }
    }
    
    /// :nodoc:
    internal let apiContext: APIContext
    
    /// :nodoc:
    internal let paymentMethod: PaymentMethod
    
    /// :nodoc:
    private var payment: Payment? { _payment }
    
    /// :nodoc:
    private let _payment: Payment
    
    /// :nodoc:
    internal weak var delegate: PaymentComponentDelegate?
    
    /// :nodoc:
    internal weak var presentationDelegate: PresentationDelegate?
    
    /// :nodoc:
    fileprivate let applePayComponent: ApplePayComponent

    /// :nodoc:
    internal let configuration: Configuration
    
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
    internal init(paymentMethod: ApplePayPaymentMethod,
                  apiContext: APIContext,
                  payment: Payment,
                  configuration: Configuration,
                  applePayConfiguration: ApplePayComponent.Configuration) throws {
        self.apiContext = apiContext
        self._payment = payment
        self.paymentMethod = paymentMethod
        self.configuration = configuration

        self.applePayComponent = try ApplePayComponent(paymentMethod: paymentMethod,
                                                       apiContext: apiContext,
                                                       payment: payment,
                                                       configuration: applePayConfiguration)
        self.applePayComponent.delegate = self
    }
    
    /// :nodoc
    internal func didFinalize(with success: Bool) {
        applePayComponent.didFinalize(with: success)
    }
    
    /// :nodoc:
    private func createModel(with amount: Amount) -> PreApplePayView.Model {
        PreApplePayView.Model(hint: amount.formatted, style: configuration.style)
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
