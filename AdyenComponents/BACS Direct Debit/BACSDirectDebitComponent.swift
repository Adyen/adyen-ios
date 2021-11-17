//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

public final class BACSDirectDebitComponent {

    public let paymentMethod: PaymentMethod
    public let apiContext: APIContext
    public let style: FormComponentStyle
    public let localizationParameters: LocalizationParameters

    // MARK: - Initializers

    public init(paymentMethod: PaymentMethod,
                apiContext: APIContext,
                style: FormComponentStyle = .init(),
                localizationParameters: LocalizationParameters) {
        self.paymentMethod = paymentMethod
        self.apiContext = apiContext
        self.style = style
        self.localizationParameters = localizationParameters

        let view = BACSDirectDebitInputFormView(title: paymentMethod.name,
                                                styleProvider: style)
        let itemsFactory = BACSDirectDebitItemsFactory(styleProvider: style)
        let presenter = BACSDirectDebitPresenter(view: view,
                                                 itemsFactory: itemsFactory,
                                                 localizationParameters: localizationParameters)
        view.presenter = presenter
    }

    // MARK: - View Controller

    private lazy var formViewController: FormViewController = {
        let formViewController = FormViewController(style: style)
        formViewController.localizationParameters = localizationParameters

        return formViewController
    }()
}
