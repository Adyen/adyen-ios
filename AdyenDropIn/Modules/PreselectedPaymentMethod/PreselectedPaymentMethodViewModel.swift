//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

internal protocol PreselectedPaymentMethodViewModelProtocol {
    var paymentMethodView: UIViewController { get }
}

internal class PreselectedPaymentMethodViewModel: PreselectedPaymentMethodViewModelProtocol, PreselectedPaymentMethodComponentDelegate {

    // MARK: - Properties

    private let router: PreselectedPaymentMethodRouterProtocol
    private let preselectedPaymentMethodComponent: PreselectedPaymentMethodComponent

    // MARK: - Initializers

    internal init(
        router: PreselectedPaymentMethodRouterProtocol,
        component: PaymentComponent,
        title: String,
        configuration: DropInComponent.Configuration
    ) {
        self.router = router

        let style = configuration.style
        self.preselectedPaymentMethodComponent = PreselectedPaymentMethodComponent(
            component: component,
            title: title,
            style: style.formComponent,
            listItemStyle: style.listComponent.listItem
        )
        self.preselectedPaymentMethodComponent.localizationParameters = configuration.localizationParameters
        self.preselectedPaymentMethodComponent.delegate = self
    }

    // MARK: - PreselectedPaymentMethodViewModelProtocol

    internal var paymentMethodView: UIViewController {
        preselectedPaymentMethodComponent.viewController
    }

    // MARK: - PreselectedPaymentMethodComponentDelegate

    internal func didRequestAllPaymentMethods() {
        router.showAllPaymentMethods()
    }

    internal func didProceed(with component: any Adyen.PaymentComponent) {
        print("Proceed with component: \(component)")
        router.proceed(with: component)
    }
}
