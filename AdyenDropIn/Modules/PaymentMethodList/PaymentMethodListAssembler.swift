//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenCard)
    import AdyenCard
#endif
import Foundation

internal protocol PaymentMethodListAssemblerProtocol {
    func resolvePaymentMethodListRouter(delegate: PaymentMethodListRouterListener?) -> Router
}

internal struct PaymentMethodListAssembler: PaymentMethodListAssemblerProtocol {

    // MARK: - Properties

    private let componentManager: ComponentManager
    private let context: AdyenContext
    private let configuration: DropInComponent.Configuration
    private let cardComponentDelegate: CardComponentDelegate?
    private let partialPaymentDelegate: PartialPaymentDelegate?

    // MARK: - Initializers

    internal init(
        componentManager: ComponentManager,
        context: AdyenContext,
        configuration: DropInComponent.Configuration,
        cardComponentDelegate: CardComponentDelegate?,
        partialPaymentDelegate: PartialPaymentDelegate?
    ) {
        self.componentManager = componentManager
        self.context = context
        self.configuration = configuration
        self.cardComponentDelegate = cardComponentDelegate
        self.partialPaymentDelegate = partialPaymentDelegate
    }

    // MARK: - PaymentMethodListAssemblerProtocol

    internal func resolvePaymentMethodListRouter(
        delegate: PaymentMethodListRouterListener?
    ) -> Router {
        let componentContainerAssembler = ComponentContainerAssembler(
            context: context,
            configuration: configuration,
            cardComponentDelegate: cardComponentDelegate,
            partialPaymentDelegate: partialPaymentDelegate
        )
        let viewModel = PaymentMethodListViewModel(
            context: context,
            componentManager: componentManager,
            configuration: configuration
        )
        let view = PaymentMethodListViewController(viewModel: viewModel)
        let router = PaymentMethodListRouter(
            viewController: view,
            loadable: viewModel,
            listener: delegate,
            componentContainerAssembler: componentContainerAssembler
        )
        viewModel.router = router
        return router
    }
}
