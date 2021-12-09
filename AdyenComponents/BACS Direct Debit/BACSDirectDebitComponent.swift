//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

internal protocol BACSDirectDebitRouterProtocol {
    func presentConfirmation(with data: BACSDirectDebitData)
    func confirmPayment(with data: BACSDirectDebitData)
    func cancelPayment()
}

/// A component that provides a form for BACS Direct Debit payments.
public final class BACSDirectDebitComponent: PaymentComponent, PresentableComponent {

    // MARK: - PresentableComponent

    /// :nodoc:
    public var viewController: UIViewController

    /// :nodoc:
    public var requiresModalPresentation: Bool = false

    /// The object that acts as the delegate of the component.
    public weak var delegate: PaymentComponentDelegate?

    /// The BACS Direct Debit payment method.
    public let paymentMethod: PaymentMethod

    /// :nodoc:
    public let apiContext: APIContext

    /// :nodoc:
    public let style: FormComponentStyle

    /// :nodoc:
    public var localizationParameters: LocalizationParameters?

    // MARK: - Initializers

    /// Creates and returns a BACS Direct Debit component.
    /// - Parameters:
    ///   - paymentMethod: The BACS Direct Debit payment method.
    ///   - apiContext: The API context.
    ///   - style: The component's UI style.
    ///   - localizationParameters: The localization parameters.
    public init(paymentMethod: BACSDirectDebitPaymentMethod,
                apiContext: APIContext,
                style: FormComponentStyle = .init(),
                localizationParameters: LocalizationParameters? = nil) {
        self.paymentMethod = paymentMethod
        self.apiContext = apiContext
        self.style = style
        self.localizationParameters = localizationParameters

        let view = BACSDirectDebitInputFormViewController(title: paymentMethod.name,
                                                          styleProvider: style)
        self.viewController = view as UIViewController

        let itemsFactory = BACSDirectDebitItemsFactory(styleProvider: style,
                                                       localizationParameters: localizationParameters,
                                                       scope: String(describing: self))
        let presenter = BACSDirectDebitPresenter(view: view,
                                                 router: self,
                                                 itemsFactory: itemsFactory)
        view.presenter = presenter
    }
}

// MARK: - BACSDirectDebitRouterProtocol

extension BACSDirectDebitComponent: BACSDirectDebitRouterProtocol {

    internal func presentConfirmation(with data: BACSDirectDebitData) {
        // TODO: - Continue payment logic
        // 1. Assamble confirmation scene
        // 2. Present confirmation scene
        adyenPrint("PAYMENT: \(data)")

        let confirmationView = UIViewController()
        confirmationView.title = "Confirmation View"
        confirmationView.view.backgroundColor = UIColor(red: 0.19, green: 0.84, blue: 0.78, alpha: 1.00)
        viewController.navigationController?.pushViewController(confirmationView, animated: true)
    }

    internal func confirmPayment(with data: BACSDirectDebitData) {
        // TODO: - Payment processing logic
        guard let bacsDirectDebitPaymentMethod = paymentMethod as? BACSDirectDebitPaymentMethod else {
            return
        }
        let bacsDirectDebitDetails = BACSDirectDebitDetails(paymentMethod: bacsDirectDebitPaymentMethod,
                                                            holderName: data.holderName,
                                                            bankAccountNumber: data.bankAccountNumber,
                                                            bankLocationId: data.bankLocationId)
    }

    internal func cancelPayment() {
        viewController.navigationController?.dismiss(animated: true)
    }
}
