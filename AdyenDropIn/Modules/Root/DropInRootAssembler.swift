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

    // MARK: - Initalizers

    internal init(
        paymentMethods: PaymentMethods,
        context: AdyenContext,
        configuration: DropInComponent.Configuration
    ) {
        self.paymentMethods = paymentMethods
        self.context = context
        self.configuration = configuration
    }

    // MARK: - Public

    internal func resolveDropInRootView() -> UIViewController {
        let componentManager = resolveComponentManager()
        let apiClient = resolveAPIClient()

        let viewModel = DropInRootViewModel(
            componentManager: componentManager,
            apiClient: apiClient,
            paymentMethods: paymentMethods,
            context: context,
            configuration: configuration
        )
        componentManager.presentationDelegate = viewModel

        let rootViewController = resolveRootView(componentManager: componentManager)
        let dropInRootViewController = DropInRootViewController(
            rootViewController: rootViewController,
            viewModel: viewModel
        )
        return dropInRootViewController
    }

    // MARK: - Private

    private func resolveRootView(
        componentManager: ComponentManager
    ) -> UIViewController {
        if configuration.allowPreselectedPaymentView,
           let preselectedPaymentMethodComponent = componentManager.storedComponents.first {
            let preselectedPaymentMethodAssembler = PreselectedPaymentMethodAssembler(
                componentManager: componentManager,
                context: context,
                configuration: configuration
            )
            let view = preselectedPaymentMethodAssembler.resolvePreselectedPaymentMethodView(
                component: preselectedPaymentMethodComponent,
                title: "Preselected PM"
            )
            return view
        } else if configuration.allowsSkippingPaymentList,
                  let singleRegularComponent = componentManager.singleRegularComponent {
            let viewModel = ComponentContainerViewModel(
                component: singleRegularComponent,
                isRoot: false,
                cancelHandler: nil
            )

            let componentViewController = ComponentContainerViewController(viewModel: viewModel)
            return componentViewController
        } else {
            let paymentMethodListAssembler = PaymentMethodListAssembler(
                componentManager: componentManager,
                context: context,
                configuration: configuration
            )
            let paymentMethodListView = paymentMethodListAssembler.resolvePaymentMethodListView()
            return paymentMethodListView
        }
    }

    private func resolveComponentManager() -> ComponentManager {
        let componentManager = ComponentManager(
            paymentMethods: paymentMethods,
            context: context,
            configuration: configuration,
            partialPaymentEnabled: false, // TODO: - Set partial payment flow
            order: nil,
            supportsEditingStoredPaymentMethods: false, // TODO: - Support editing stored PMs
            presentationDelegate: nil
        )

        return componentManager
    }

    private func resolveAPIClient() -> APIClientProtocol {
        let scheduler = SimpleScheduler(maximumCount: 3)
        let apiClient = APIClient(apiContext: context.apiContext)
            .retryAPIClient(with: scheduler)
            .retryOnErrorAPIClient()

        return apiClient
    }
}
