//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

// TODO: - Complete documentation

internal protocol BACSDirectDebitRouterProtocol {
    func presentConfirmation(with data: BACSDirectDebitData)
    func confirmPayment(with data: BACSDirectDebitData)
}

/// A component that provides a form for BACS Direct Debit payments.
public final class BACSDirectDebitComponent: PaymentComponent, PresentableComponent {

    // MARK: - PresentableComponent

    // TODO: - Set up view controller
    public var viewController: UIViewController {
        navigationController
    }

    private let navigationController: UINavigationController

    public var requiresModalPresentation: Bool = true

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

        let view = BACSDirectDebitInputFormView(title: paymentMethod.name,
                                                styleProvider: style)

        // TODO: - Set navigation controller
        self.navigationController = UINavigationController(rootViewController: view as UIViewController)

        let itemsFactory = BACSDirectDebitItemsFactory(styleProvider: style,
                                                       localizationParameters: localizationParameters,
                                                       scope: self)
        let presenter = BACSDirectDebitPresenter(view: view,
                                                 router: self,
                                                 itemsFactory: itemsFactory)
        view.presenter = presenter
    }
}

// MARK: - BACSDirectDebitRouterProtocol

extension BACSDirectDebitComponent: BACSDirectDebitRouterProtocol {

    func presentConfirmation(with data: BACSDirectDebitData) {
        // TODO: - Continue payment logic
        print("PAYMENT: \(data)")

        let confirmationView = UIViewController()
        confirmationView.title = "Confirmation View"
        confirmationView.view.backgroundColor = UIColor(red: 0.19, green: 0.84, blue: 0.78, alpha: 1.00)
        navigationController.pushViewController(confirmationView, animated: true)
    }

    func confirmPayment(with data: BACSDirectDebitData) {
        // TODO: - Payment processing logic
        guard let bacsDirectDebitPaymentMethod = paymentMethod as? BACSDirectDebitPaymentMethod else {
            return
        }
        let bacsDirectDebitDetails = BACSDirectDebitDetails(paymentMethod: bacsDirectDebitPaymentMethod,
                                                            holderName: data.holderName,
                                                            bankAccountNumber: data.bankAccountNumber,
                                                            bankLocationId: data.bankLocationId)
    }
}
