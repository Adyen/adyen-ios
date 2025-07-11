//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import Foundation

internal protocol DropInViewModelProtocol {
    func cancel(completion: (() -> Void)?)
}

internal class DropInViewModel: DropInViewModelProtocol {

    // MARK: - Properties

    private let componentManager: ComponentManager
    private let apiClient: APIClientProtocol
    private let paymentMethods: PaymentMethods
    private let context: AdyenContext
    private let configuration: DropInComponent.Configuration
    private let title: String?

    // MARK: - Initializers

    internal init(
        componentManager: ComponentManager,
        apiClient: APIClientProtocol,
        paymentMethods: PaymentMethods,
        context: AdyenContext,
        configuration: DropInComponent.Configuration,
        title: String? = nil
    ) {
        self.componentManager = componentManager
        self.apiClient = apiClient
        self.paymentMethods = paymentMethods
        self.context = context
        self.configuration = configuration
        self.title = title

        self.componentManager.presentationDelegate = self
    }

    // MARK: - DropInRootViewModelProtocol

    func cancel(completion: (() -> Void)?) {
        print("⚠️ PAYMENT CANCELLED ⚠️")
    }
}

extension DropInViewModel: PresentationDelegate {

    internal func present(component: any Adyen.PresentableComponent) {
        // TODO: -
    }
}
