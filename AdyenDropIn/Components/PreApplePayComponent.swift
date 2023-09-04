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
final class PreApplePayComponent: PresentableComponent,
    FinalizableComponent,
    PaymentComponent,
    Localizable,
    Cancellable {

    private var isPresenting: Bool = false
    
    let apiContext: APIContext
    
    let paymentMethod: PaymentMethod
    
    let amount: Amount
    
    weak var delegate: PaymentComponentDelegate?
    
    var localizationParameters: LocalizationParameters?
    
    weak var presentationDelegate: NavigationDelegate?
    
    fileprivate let applePayComponent: ApplePayComponent
    
    let style: ApplePayStyle
    
    lazy var viewController: UIViewController = {
        let view = PreApplePayView(model: createModel(with: amount))
        let viewController = ADYViewController(view: view, title: "Apple Pay")
        view.delegate = self
        
        return viewController
    }()
    
    /// :nodoc:
    let requiresModalPresentation: Bool = true
    
    /// :nodoc:
    init(paymentMethod: ApplePayPaymentMethod,
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
    func didFinalize(with success: Bool) {
        assertionFailure("Do not call this method. Use didFinalize(with success:completion:) ")
    }

    func didFinalize(with success: Bool, completion: (() -> Void)?) {
        applePayComponent.didFinalize(with: success, completion: completion)
    }
    
    /// :nodoc:
    private func createModel(with amount: Amount) -> PreApplePayView.Model {
        PreApplePayView.Model(hint: amount.formatted, style: style)
    }

    func didCancel() {
        if let presenter = presentationDelegate, isPresenting {
            isPresenting = false
            presenter.dismiss(completion: nil)
        }
    }
    
}

extension PreApplePayComponent: PaymentComponentDelegate {
    
    func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent) {
        delegate?.didSubmit(data, from: self)
    }
    
    func didFail(with error: Error, from component: PaymentComponent) {
        delegate?.didFail(with: error, from: self)
    }
    
}

extension PreApplePayComponent: PreApplePayViewDelegate {
    
    /// :nodoc:
    func pay() {
        isPresenting = true
        presentationDelegate?.present(component: applePayComponent)
    }
    
}
