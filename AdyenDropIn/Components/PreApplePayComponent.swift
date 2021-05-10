//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// :nodoc:
internal final class PreApplePayComponent: Localizable, PresentableComponent, PaymentComponent {

    /// :nodoc:
    internal var paymentMethod: PaymentMethod { applePayComponent.paymentMethod }

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
    internal init(payment: Payment, paymentMethod: ApplePayPaymentMethod, configuration: ApplePayComponent.Configuration) throws {
        self._payment = payment
        self.applePayComponent = try ApplePayComponent(paymentMethod: paymentMethod,
                                                       payment: payment,
                                                       configuration: configuration)
        self.applePayComponent.delegate = self
    }

    /// :nodoc
    internal func stopLoading(withSuccess success: Bool, completion: (() -> Void)?) {
        applePayComponent.stopLoading(withSuccess: success) {
            completion?()
        }
    }

    /// :nodoc:
    private func createModel(with amount: Payment.Amount) -> PreApplePayView.Model {
        PreApplePayView.Model(
            hint: amount.formatted,
            style: PreApplePayView.Model.Style(
                hintLabel: TextStyle(font: .preferredFont(forTextStyle: .footnote), color: UIColor.AdyenDropIn.componentSecondaryLabel),
                backgroundColor: UIColor.AdyenDropIn.componentBackground
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
        presentationDelegate?.present(component: applePayComponent, disableCloseButton: false)
    }

}
