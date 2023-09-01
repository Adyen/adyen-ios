//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import PassKit
import UIKit
#if canImport(AdyenComponents)
    @_spi(AdyenInternal) import AdyenComponents
#endif

final class PreApplePayComponent: PresentableComponent,
    FinalizableComponent,
    PaymentComponent,
    Cancellable {
    
    struct Configuration: Localizable {
        
        var style: ApplePayStyle

        var localizationParameters: LocalizationParameters?

        init(style: ApplePayStyle = ApplePayStyle(),
             localizationParameters: LocalizationParameters? = nil) {
            self.style = style
            self.localizationParameters = localizationParameters
        }
    }

    private var isPresenting: Bool = false

    let amount: Amount

    private let applePayComponent: ApplePayComponent

    /// :nodoc:
    /// The context object for this component.
    let context: AdyenContext
    
    /// :nodoc:
    let paymentMethod: PaymentMethod

    weak var delegate: PaymentComponentDelegate?

    weak var presentationDelegate: NavigationDelegate?

    let configuration: Configuration
    
    lazy var viewController: UIViewController = {
        let view = PreApplePayView(model: createModel(with: amount))
        let viewController = ADYViewController(view: view, title: "Apple Pay")
        view.delegate = self
        
        return viewController
    }()
    
    let requiresModalPresentation: Bool = true
    
    init(paymentMethod: ApplePayPaymentMethod,
         context: AdyenContext,
         configuration: Configuration,
         applePayConfiguration: ApplePayComponent.Configuration) throws {
        self.context = context
        self.paymentMethod = paymentMethod
        self.configuration = configuration
        self.amount = applePayConfiguration.applePayPayment.amount
        self.applePayComponent = try ApplePayComponent(paymentMethod: paymentMethod,
                                                       context: context,
                                                       configuration: applePayConfiguration)
        self.applePayComponent.delegate = self
    }

    func didCancel() {
        if let navigation = presentationDelegate, isPresenting {
            isPresenting = false
            navigation.dismiss(completion: nil)
        }
    }

    func didFinalize(with success: Bool, completion: (() -> Void)?) {
        applePayComponent.didFinalize(with: success, completion: completion)
    }
    
    private func createModel(with amount: Amount) -> PreApplePayView.Model {
        PreApplePayView.Model(hint: amount.formatted, style: configuration.style)
    }
    
}

extension PreApplePayComponent: PaymentComponentDelegate {
    
    func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent) {
        submit(data: data, component: component)
    }
    
    func didFail(with error: Error, from component: PaymentComponent) {
        delegate?.didFail(with: error, from: self)
    }
    
}

extension PreApplePayComponent: PreApplePayViewDelegate {
    
    func pay() {
        isPresenting = true
        presentationDelegate?.present(component: applePayComponent)
    }
    
}
