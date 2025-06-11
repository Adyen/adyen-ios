//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal protocol PaymentMethodListAssemblerProtocol {
    func resolvePaymentMethodListView() -> UIViewController
}

internal struct PaymentMethodListAssembler: PaymentMethodListAssemblerProtocol {

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

    // MARK: - PaymentMethodListAssemblerProtocol

    internal func resolvePaymentMethodListView() -> UIViewController {
        let componentContainerAssembler = ComponentContainerAssembler()
        let router = PaymentMethodListRouter(componentContainerAssembler: componentContainerAssembler)
        let viewModel = PaymentMethodListViewModel(
            router: router,
            context: context,
            componentManager: componentManager,
            configuration: configuration
        )
        let view = PaymentMethodListViewController(viewModel: viewModel)
        router.view = view
        return view
    }
}
