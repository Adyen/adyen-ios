//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

// TODO: - Complete documentation

internal protocol BACSDirectDebitRouterProtocol {
    func continuePayment(data: BACSDirectDebitData)
}

public final class BACSDirectDebitComponent: PaymentComponent, PresentableComponent {

    // TODO: - Set up view controller

    // MARK: - PresentableComponent

    public var viewController: UIViewController

    public var requiresModalPresentation: Bool = true
    
    // TODO: - Set up delegate
    public weak var delegate: PaymentComponentDelegate?

    public let paymentMethod: PaymentMethod
    public let apiContext: APIContext
    public let style: FormComponentStyle
    public var localizationParameters: LocalizationParameters?

    // MARK: - Initializers

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
        let navigationController = UINavigationController(rootViewController: view as UIViewController)
        viewController = navigationController

        let itemsFactory = BACSDirectDebitItemsFactory(styleProvider: style,
                                                       localizationParameters: localizationParameters,
                                                       scope: self)
        let presenter = BACSDirectDebitPresenter(view: view,
                                                 router: self,
                                                 itemsFactory: itemsFactory)
        view.presenter = presenter
    }
}

extension BACSDirectDebitComponent: BACSDirectDebitRouterProtocol {

    func continuePayment(data: BACSDirectDebitData) {
        // TODO: - Continue payment
        print("PAYMENT: \(data)")
    }
}
