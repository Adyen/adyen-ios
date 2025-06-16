//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation
import UIKit

internal protocol DropInRootRouterProtocol {}

internal class DropInRootRouter: DropInRootRouterProtocol {

    // MARK: - Properties

    private let preselectedPaymentMethodAssembler: PreselectedPaymentMethodAssemblerProtocol
    private let paymentMethodListAssembler: PaymentMethodListAssemblerProtocol
    private let componentContainerAssemblerProtocol: ComponentContainerAssemblerProtocol
    private let componentManager: ComponentManager
    private let configuration: DropInComponent.Configuration

    private let navigationController: DropInRootViewController

    // MARK: - Initializers

    internal init(
        preselectedPaymentMethodAssembler: PreselectedPaymentMethodAssemblerProtocol,
        paymentMethodListAssembler: PaymentMethodListAssemblerProtocol,
        componentContainerAssemblerProtocol: ComponentContainerAssemblerProtocol,
        componentManager: ComponentManager,
        configuration: DropInComponent.Configuration
    ) {
        self.preselectedPaymentMethodAssembler = preselectedPaymentMethodAssembler
        self.paymentMethodListAssembler = paymentMethodListAssembler
        self.componentContainerAssemblerProtocol = componentContainerAssemblerProtocol
        self.componentManager = componentManager
        self.configuration = configuration
        self.navigationController = DropInRootViewController()
    }

    // MARK: - DropInRootRouterProtocol

    internal func start() {
        let rootView = resolveRootView()
        navigationController.setViewControllers([rootView], animated: false)
    }

    internal var rootViewController: UIViewController {
        navigationController
    }

    // MARK: - Private

    private func resolveRootView() -> UIViewController {
        if configuration.allowPreselectedPaymentView,
           let preselectedPaymentMethodComponent = componentManager.storedComponents.first {
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
            return paymentMethodListAssembler.resolvePaymentMethodListView()
        }
    }
}
