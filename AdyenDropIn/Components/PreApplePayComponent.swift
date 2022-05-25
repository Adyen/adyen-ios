//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import PassKit
import UIKit
#if canImport(AdyenComponents)
    import AdyenComponents
#endif

/// :nodoc:
internal final class PreApplePayComponent: PresentableComponent,
    FinalizableComponent,
    PaymentComponent,
    Cancellable {
    
    internal struct Configuration: Localizable {
        
        internal var style: ApplePayStyle

        internal var localizationParameters: LocalizationParameters?

        internal init(style: ApplePayStyle = ApplePayStyle(),
                      localizationParameters: LocalizationParameters? = nil) {
            self.style = style
            self.localizationParameters = localizationParameters
        }
    }

    private var isPresenting: Bool = false

    private let payment: Payment

    private let applePayComponent: ApplePayComponent

    /// :nodoc:
    /// The context object for this component.
    internal let context: AdyenContext
    
    /// :nodoc:
    internal let paymentMethod: PaymentMethod

    internal weak var delegate: PaymentComponentDelegate?

    internal weak var presentationDelegate: NavigationDelegate?

    internal let configuration: Configuration
    
    /// :nodoc:
    internal lazy var viewController: UIViewController = {
        let view = PreApplePayView(model: createModel(with: payment.amount))
        let viewController = ADYViewController(view: view, title: "Apple Pay")
        view.delegate = self
        
        return viewController
    }()
    
    /// :nodoc:
    internal let requiresModalPresentation: Bool = true
    
    /// :nodoc:
    internal init(paymentMethod: ApplePayPaymentMethod,
                  context: AdyenContext,
                  configuration: Configuration,
                  applePayConfiguration: ApplePayComponent.Configuration) throws {
        self.context = context
        self.paymentMethod = paymentMethod
        self.configuration = configuration
        self.payment = applePayConfiguration.applePayPayment.payment
        self.applePayComponent = try ApplePayComponent(paymentMethod: paymentMethod,
                                                       context: context,
                                                       configuration: applePayConfiguration)
        self.applePayComponent.delegate = self
    }

    internal func didCancel() {
        if let navigation = presentationDelegate, isPresenting {
            isPresenting = false
            navigation.dismiss(completion: nil)
        }
    }

    internal func didFinalize(with success: Bool, completion: (() -> Void)?) {
        applePayComponent.didFinalize(with: success, completion: completion)
    }
    
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
        isPresenting = true
        presentationDelegate?.present(component: applePayComponent)
    }
    
}
