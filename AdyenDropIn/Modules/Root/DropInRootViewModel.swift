//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import Foundation

internal protocol DropInRootViewModelProtocol {
    var rootViewController: UIViewController? { get }
}

internal class DropInRootViewModel: DropInRootViewModelProtocol {

    // MARK: - Properties

    private let router: DropInRootRouterProtocol
    private let componentManager: ComponentManager
    private let apiClient: APIClientProtocol
    private let paymentMethods: PaymentMethods
    private let context: AdyenContext
    private let configuration: DropInComponent.Configuration
    private let title: String?

    // MARK: - Initializers

    internal init(
        router: DropInRootRouterProtocol,
        componentManager: ComponentManager,
        apiClient: APIClientProtocol,
        paymentMethods: PaymentMethods,
        context: AdyenContext,
        configuration: DropInComponent.Configuration,
        title: String? = nil
    ) {
        self.router = router
        self.componentManager = componentManager
        self.apiClient = apiClient
        self.paymentMethods = paymentMethods
        self.context = context
        self.configuration = configuration
        self.title = title
    }

    // MARK: - DropInRootViewModelProtocol

    internal var rootViewController: UIViewController? {
        nil
    }

    // MARK: - Private

    private func resolveRootViewController() -> UIViewController? {
        nil
    }

    private func resolvePreselectedPaymentMethodView() -> UIViewController? {
        nil
    }
}

extension DropInRootViewModel: PresentationDelegate {

    internal func present(component: any Adyen.PresentableComponent) {
        // TODO: -
    }
}
