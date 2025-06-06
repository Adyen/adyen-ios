//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

internal protocol PreselectedPaymentMethodAssemblerProtocol {
    func resolvePreselectedPaymentMethodView(
        router: PreselectedPaymentMethodRouterProtocol,
        component: PaymentComponent,
        title: String,
        configuration: DropInComponent.Configuration
    ) -> UIViewController
}

internal struct PreselectedPaymentMethodAssembler {

    // MARK: - PreselectedPaymentMethodAssemblerProtocol

    internal func resolvePreselectedPaymentMethodView(
        router: PreselectedPaymentMethodRouterProtocol,
        component: PaymentComponent,
        title: String,
        configuration: DropInComponent.Configuration
    ) -> UIViewController {
        let viewModel = PreselectedPaymentMethodViewModel(
            router: router,
            component: component,
            title: title,
            configuration: configuration
        )
        let view = PreselectedPaymentMethodViewController(viewModel: viewModel)
        return view
    }
}
