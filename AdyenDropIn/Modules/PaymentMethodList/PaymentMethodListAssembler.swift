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
    private let localizationParameters: LocalizationParameters
    private let configuration: DropInComponent.Configuration
    private let dropInFlowManager: DropInFlowManaging
    private let partialPaymentDelegate: PartialPaymentDelegate?

    // MARK: - Initializers

    internal init(
        componentContainerAssembler: ComponentContainerAssemblerProtocol,
        componentManager: ComponentManager,
        context: AdyenContext,
        localizationParameters: LocalizationParameters,
        configuration: DropInComponent.Configuration,
        dropInFlowManager: DropInFlowManaging,
        partialPaymentDelegate: PartialPaymentDelegate?
    ) {
        self.componentContainerAssembler = componentContainerAssembler
        self.componentManager = componentManager
        self.context = context
        self.localizationParameters = localizationParameters
        self.configuration = configuration
        self.dropInFlowManager = dropInFlowManager
        self.partialPaymentDelegate = partialPaymentDelegate
    }

    // MARK: - PaymentMethodListAssemblerProtocol

    internal func resolvePaymentMethodListRouter(
        delegate: PaymentMethodListRouterListener?
    ) -> Router {
        let logoURLProvider = LogoURLProvider(environment: context.apiContext.environment)
        let viewModel = PaymentMethodListViewModel(
            context: context,
            localizationParameters: localizationParameters,
            componentManager: componentManager,
            configuration: configuration,
            dropInFlowManager: dropInFlowManager,
            logoURLProvider: logoURLProvider
        )
        let view = PaymentMethodListViewController(viewModel: viewModel)
        let router = PaymentMethodListRouter(
            viewController: view,
            listener: delegate,
            componentContainerAssembler: componentContainerAssembler
        )
        viewModel.router = router
        return router
    }
}
