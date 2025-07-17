//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import Foundation

internal protocol DropInViewModelProtocol {
    var root: DropInRoot { get }
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

    internal var root: DropInRoot {
        if configuration.allowPreselectedPaymentView, let storedPaymentMethod = componentManager.storedComponents.first {
            return .preselected(storedPaymentMethod)
        } else if configuration.allowsSkippingPaymentList, let paymentComponent = componentManager.singleRegularComponent {
            return .component(paymentComponent)
        } else {
            return .paymentMethodList
        }
    }
}

extension DropInViewModel: PresentationDelegate {

    internal func present(component: any Adyen.PresentableComponent) {
        // TODO: -
    }
}
