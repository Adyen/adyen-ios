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

    private var applePayComponent: ApplePayComponent?

    private let configuration: ApplePayComponent.Configuration

    private let payment: Payment

    private let applePayPaymentMethod: ApplePayPaymentMethod

    /// :nodoc:
    internal var paymentMethod: PaymentMethod { applePayPaymentMethod }

    /// :nodoc:
    internal let apiContext: APIContext

    /// :nodoc:
    internal weak var delegate: PaymentComponentDelegate?
    
    /// :nodoc:
    internal var localizationParameters: LocalizationParameters?
    
    /// :nodoc:
    internal weak var navigationDelegate: NavigationDelegate?
    
    /// :nodoc:
    internal let style: ApplePayStyle
    
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
                  apiContext: APIContext,
                  payment: Payment,
                  configuration: ApplePayComponent.Configuration,
                  style: ApplePayStyle) throws {
        self.apiContext = apiContext
        self.payment = payment
        self.applePayPaymentMethod = paymentMethod
        self.style = style
        self.configuration = configuration
        applePayComponent = try createApplePayComponent()
    }
    
    /// :nodoc
    internal func didFinalize(with success: Bool) {
        applePayComponent = nil
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
        navigationDelegate?.dismiss()
        applePayComponent = nil
    }
    
}

extension PreApplePayComponent: PreApplePayViewDelegate {
    
    /// :nodoc:
    internal func pay() {
        let component: ApplePayComponent
        if let applePayComponent = applePayComponent {
            component = applePayComponent
        } else {
            do {
                component = try createApplePayComponent()
                applePayComponent = component
            } catch {
                delegate?.didFail(with: error, from: self)
                return
            }
        }

        navigationDelegate?.present(component: component)
    }

    private func createApplePayComponent() throws -> ApplePayComponent {
        let applePayComponent = try ApplePayComponent(paymentMethod: applePayPaymentMethod,
                                                       apiContext: apiContext,
                                                       payment: payment,
                                                       configuration: configuration)
        applePayComponent.delegate = self
        return applePayComponent
    }
    
}

internal protocol NavigationDelegate: PresentationDelegate {

    func dismiss()

}
