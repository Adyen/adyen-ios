//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import Foundation
#if canImport(AdyenActions)
    @_spi(AdyenInternal) import AdyenActions
#endif

@MainActor
internal protocol DropInViewModelProtocol {
    var root: DropInRoot { get }
    var title: String { get }
}

@MainActor
internal class DropInViewModel: DropInViewModelProtocol {

    // MARK: - Properties

    internal let title: String
    private let componentManager: ComponentManager
    private let apiClient: AsyncAPIClientProtocol
    private let paymentMethods: PaymentMethods
    private let context: AdyenContext
    private let configuration: DropInComponent.Configuration

    // MARK: - Initializers

    internal init(
        title: String,
        componentManager: ComponentManager,
        apiClient: AsyncAPIClientProtocol,
        paymentMethods: PaymentMethods,
        context: AdyenContext,
        configuration: DropInComponent.Configuration
    ) {
        self.title = title
        self.componentManager = componentManager
        self.apiClient = apiClient
        self.paymentMethods = paymentMethods
        self.context = context
        self.configuration = configuration
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
