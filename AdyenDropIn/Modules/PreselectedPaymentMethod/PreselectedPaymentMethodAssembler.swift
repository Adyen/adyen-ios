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

    // MARK: - Properties

    private let componentManager: ComponentManager
    private let context: AdyenContext
    private let configuration: DropInComponent.Configuration

    // MARK: - Initializers

    internal init(
        componentManager: ComponentManager,
        context: AdyenContext,
        configuration: DropInComponent.Configuration
    ) {
        self.componentManager = componentManager
        self.context = context
        self.configuration = configuration
    }

    // MARK: - PreselectedPaymentMethodAssemblerProtocol

    internal func resolvePreselectedPaymentMethodView(
        component: PaymentComponent,
        title: String
    ) -> UIViewController {
        let paymentMethodListAssembler = PaymentMethodListAssembler(
            componentManager: componentManager,
            context: context,
            configuration: configuration
        )

        let router = PreselectedPaymentMethodRouter(paymentMethodListAssembler: paymentMethodListAssembler)
        let viewModel = PreselectedPaymentMethodViewModel(
            router: router,
            component: component,
            title: title,
            configuration: configuration
        )
        let view = PreselectedPaymentMethodViewController(viewModel: viewModel)
        router.view = view
        return view
    }
}
