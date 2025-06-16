//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import Foundation

internal protocol DropInAssemblerProtocol {
    func resolveDropInRootView() -> UIViewController
}

internal class DropInRootAssembler {

    // MARK: - Properties

    private let paymentMethods: PaymentMethods
    private let context: AdyenContext
    private let configuration: DropInComponent.Configuration
    private let componentManager: ComponentManager

    // MARK: - Initalizers

    internal init(
        paymentMethods: PaymentMethods,
        context: AdyenContext,
        configuration: DropInComponent.Configuration
    ) {
        self.paymentMethods = paymentMethods
        self.context = context
        self.configuration = configuration
        self.componentManager = ComponentManager(
            paymentMethods: paymentMethods,
            context: context,
            configuration: configuration,
            partialPaymentEnabled: false, // TODO: - Set partial payment flow
            order: nil,
            supportsEditingStoredPaymentMethods: false, // TODO: - Support editing stored PMs
            presentationDelegate: nil
        )
    }

    // MARK: - Public

    internal func resolveDropInRootView() -> UIViewController {
        let apiClient = resolveAPIClient()
        let router = DropInRootRouter(
            preselectedPaymentMethodAssembler: preselectedPaymentMethodAssembler,
            paymentMethodListAssembler: paymentMethodListAssembler,
            componentContainerAssemblerProtocol: componentContainerAssembler,
            componentManager: componentManager,
            configuration: configuration
        )

        let viewModel = DropInRootViewModel(
            componentManager: componentManager,
            apiClient: apiClient,
            paymentMethods: paymentMethods,
            context: context,
            configuration: configuration,
            router: router
        )
        componentManager.presentationDelegate = viewModel

        router.start()
        return router.rootViewController
    }

    // MARK: - Private

    private func resolveAPIClient() -> APIClientProtocol {
        let scheduler = SimpleScheduler(maximumCount: 3)
        let apiClient = APIClient(apiContext: context.apiContext)
            .retryAPIClient(with: scheduler)
            .retryOnErrorAPIClient()

        return apiClient
    }

    private var preselectedPaymentMethodAssembler: PreselectedPaymentMethodAssemblerProtocol {
        PreselectedPaymentMethodAssembler(
            componentManager: componentManager,
            context: context,
            configuration: configuration
        )
    }

    private var paymentMethodListAssembler: PaymentMethodListAssemblerProtocol {
        PaymentMethodListAssembler(
            componentManager: componentManager,
            context: context,
            configuration: configuration
        )
    }

    private var componentContainerAssembler: ComponentContainerAssemblerProtocol {
        ComponentContainerAssembler()
    }
}
