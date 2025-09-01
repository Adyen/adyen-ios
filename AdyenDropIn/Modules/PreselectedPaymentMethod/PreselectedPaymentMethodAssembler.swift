//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenCard
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

    private let context: AdyenContext
    private let configuration: DropInComponent.Configuration
    private let cardComponentDelegate: CardComponentDelegate?
    private let partialPaymentDelegate: PartialPaymentDelegate?

    // MARK: - Initializers

    internal init(
        context: AdyenContext,
        configuration: DropInComponent.Configuration,
        cardComponentDelegate: CardComponentDelegate?,
        partialPaymentDelegate: PartialPaymentDelegate?
    ) {
        self.context = context
        self.configuration = configuration
        self.cardComponentDelegate = cardComponentDelegate
        self.partialPaymentDelegate = partialPaymentDelegate
    }

    // MARK: - PreselectedPaymentMethodAssemblerProtocol

    internal func resolvePreselectedPaymentMethodRouter(
        component: PaymentComponent,
        title: String
    ) -> PreselectedPaymentMethodRouterProtocol {
        let componentContainerAssembler = ComponentContainerAssembler(
            context: context,
            configuration: configuration,
            cardComponentDelegate: cardComponentDelegate,
            partialPaymentDelegate: partialPaymentDelegate
        )
        let router = PreselectedPaymentMethodRouter(componentContainerAssembler: componentContainerAssembler)
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
