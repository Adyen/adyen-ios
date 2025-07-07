//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

internal protocol PreselectedPaymentMethodAssemblerProtocol {
    func resolvePreselectedPaymentMethodRouter(
        component: PaymentComponent,
        title: String
    ) -> PreselectedPaymentMethodRouterProtocol
}

internal struct PreselectedPaymentMethodAssembler: PreselectedPaymentMethodAssemblerProtocol {

    // MARK: - Properties

    private let configuration: DropInComponent.Configuration

    // MARK: - Initializers

    internal init(configuration: DropInComponent.Configuration) {
        self.configuration = configuration
    }

    // MARK: - PreselectedPaymentMethodAssemblerProtocol

    internal func resolvePreselectedPaymentMethodRouter(
        component: PaymentComponent,
        title: String
    ) -> PreselectedPaymentMethodRouterProtocol {
        let router = PreselectedPaymentMethodRouter()
        let viewModel = PreselectedPaymentMethodViewModel(
            router: router,
            component: component,
            title: title,
            configuration: configuration
        )
        let view = PreselectedPaymentMethodViewController(viewModel: viewModel)
        router.view = view
        return router
    }
}
