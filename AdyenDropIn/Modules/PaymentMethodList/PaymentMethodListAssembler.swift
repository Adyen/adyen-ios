//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

// sourcery:AutoMockable
internal protocol PaymentMethodListAssemblerProtocol {
    func resolvePaymentMethodListRouter(delegate: PaymentMethodListRouterListener?) -> Router
}

internal struct PaymentMethodListAssembler: PaymentMethodListAssemblerProtocol {

    // MARK: - Properties

    private let componentContainerAssembler: ComponentContainerAssemblerProtocol
    private let componentManager: ComponentManager
    private let context: AdyenContext
    private let configuration: DropInComponent.Configuration
    private let dropInFlowManager: DropInFlowManaging
    private let partialPaymentDelegate: PartialPaymentDelegate?

    // MARK: - Initializers

    internal init(
        componentContainerAssembler: ComponentContainerAssemblerProtocol,
        componentManager: ComponentManager,
        context: AdyenContext,
        configuration: DropInComponent.Configuration,
        dropInFlowManager: DropInFlowManaging,
        partialPaymentDelegate: PartialPaymentDelegate?
    ) {
        self.componentContainerAssembler = componentContainerAssembler
        self.componentManager = componentManager
        self.context = context
        self.configuration = configuration
        self.dropInFlowManager = dropInFlowManager
        self.partialPaymentDelegate = partialPaymentDelegate
    }

    // MARK: - PaymentMethodListAssemblerProtocol

    internal func resolvePaymentMethodListRouter(
        delegate: PaymentMethodListRouterListener?
    ) -> Router {
        let viewModel = PaymentMethodListViewModel(
            context: context,
            componentManager: componentManager,
            configuration: configuration,
            dropInFlowManager: dropInFlowManager
        )
        let view = PaymentMethodListViewController(viewModel: viewModel)
        let router = PaymentMethodListRouter(
            viewController: view,
            listener: delegate,
            componentContainerAssembler: componentContainerAssembler
        )
        viewModel.view = view
        viewModel.router = router
        return router
    }
}
