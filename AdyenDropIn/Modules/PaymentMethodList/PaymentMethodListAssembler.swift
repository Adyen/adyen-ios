//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenUI)
    import AdyenUI
#endif
import Foundation

// sourcery:AutoMockable
@MainActor
internal protocol PaymentMethodListAssemblerProtocol {
    func resolvePaymentMethodListRouter(delegate: PaymentMethodListRouterListener?) -> Router
}

@MainActor
internal struct PaymentMethodListAssembler: PaymentMethodListAssemblerProtocol {

    // MARK: - Properties

    private let componentContainerAssembler: ComponentContainerAssemblerProtocol
    private let storedPaymentComponentAssembler: StoredPaymentComponentAssemblerProtocol
    private let componentManager: ComponentManager
    private let context: AdyenContext
    private let localizationParameters: LocalizationParameters
    private let configuration: DropInComponent.Configuration
    private let dropInFlowManager: DropInFlowManaging
    private let theme: CheckoutTheme
    private let partialPaymentDelegate: PartialPaymentDelegate?
    private let storedPaymentMethodManagementCapability: StoredPaymentMethodManagementCapability?

    // MARK: - Initializers

    internal init(
        componentContainerAssembler: ComponentContainerAssemblerProtocol,
        storedPaymentComponentAssembler: StoredPaymentComponentAssemblerProtocol,
        componentManager: ComponentManager,
        context: AdyenContext,
        localizationParameters: LocalizationParameters,
        configuration: DropInComponent.Configuration,
        dropInFlowManager: DropInFlowManaging,
        theme: CheckoutTheme,
        partialPaymentDelegate: PartialPaymentDelegate?,
        storedPaymentMethodManagementCapability: StoredPaymentMethodManagementCapability?
    ) {
        self.componentContainerAssembler = componentContainerAssembler
        self.storedPaymentComponentAssembler = storedPaymentComponentAssembler
        self.componentManager = componentManager
        self.context = context
        self.localizationParameters = localizationParameters
        self.configuration = configuration
        self.dropInFlowManager = dropInFlowManager
        self.theme = theme
        self.partialPaymentDelegate = partialPaymentDelegate
        self.storedPaymentMethodManagementCapability = storedPaymentMethodManagementCapability
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
            logoURLProvider: logoURLProvider,
            supportsStoredPaymentMethodManagement: storedPaymentMethodManagementCapability != nil,
            theme: theme
        )
        let view = PaymentMethodListViewController(viewModel: viewModel)
        let storedPaymentMethodManagementAssembler = StoredPaymentMethodManagementAssembler(
            localizationParameters: localizationParameters,
            logoURLProvider: logoURLProvider,
            theme: theme
        )
        let router = PaymentMethodListRouter(
            viewController: view,
            listener: delegate,
            componentContainerAssembler: componentContainerAssembler,
            storedPaymentComponentAssembler: storedPaymentComponentAssembler,
            storedPaymentMethodManagementAssembler: storedPaymentMethodManagementAssembler,
            storedPaymentMethodManagementCapability: storedPaymentMethodManagementCapability,
            storedPaymentMethodsProvider: { componentManager.visibleStoredPaymentMethods },
            onStoredPaymentMethodRemoved: { paymentMethod in
                viewModel.remove(storedPaymentMethod: paymentMethod)
            }
        )
        viewModel.router = router
        return router
    }
}
