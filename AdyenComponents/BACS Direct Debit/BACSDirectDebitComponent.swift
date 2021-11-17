//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

// TODO: - Complete documentation

public final class BACSDirectDebitComponent: PaymentComponent, PresentableComponent {

    // TODO: - Set up view controller
    public var viewController: UIViewController

    // TODO: - Set up delegate
    public weak var delegate: PaymentComponentDelegate?

    public let paymentMethod: PaymentMethod
    public let apiContext: APIContext
    public let style: FormComponentStyle

    // MARK: - Initializers

    public init(paymentMethod: BACSDirectDebitPaymentMethod,
                apiContext: APIContext,
                style: FormComponentStyle = .init()) {
        self.paymentMethod = paymentMethod
        self.apiContext = apiContext
        self.style = style

        let view = BACSDirectDebitInputFormView(title: paymentMethod.name,
                                                styleProvider: style)
        let itemsFactory = BACSDirectDebitItemsFactory(styleProvider: style)
        let presenter = BACSDirectDebitPresenter(view: view,
                                                 itemsFactory: itemsFactory,
                                                 localizationParameters: localizationParameters)
        view.presenter = presenter

        viewController = view as FormViewController
    }
}
