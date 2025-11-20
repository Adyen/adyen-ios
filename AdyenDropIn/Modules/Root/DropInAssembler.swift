//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

#if canImport(AdyenCard)
    import AdyenCard
#endif
import Adyen
import AdyenNetworking
import Foundation
import UIKit

internal struct DropInAssembler {

    // MARK: - Properties

    private let title: String
    private let paymentMethods: PaymentMethods
    private let context: AdyenContext
    private let configuration: DropInComponent.Configuration
    private let componentManager: ComponentManager
    private let dropInFlowManager: DropInFlowManaging
    private let cardComponentDelegate: CardComponentDelegate?
    private let partialPaymentDelegate: PartialPaymentDelegate?

    // MARK: - Initializers

    internal init(
        title: String,
        paymentMethods: PaymentMethods,
        context: AdyenContext,
        configuration: DropInComponent.Configuration,
        dropInFlowManager: DropInFlowManaging,
        cardComponentDelegate: CardComponentDelegate?,
        partialPaymentDelegate: PartialPaymentDelegate?
    ) {
        self.title = title
        self.paymentMethods = paymentMethods
        self.context = context
        self.configuration = configuration
        self.cardComponentDelegate = cardComponentDelegate
        self.partialPaymentDelegate = partialPaymentDelegate
        self.dropInFlowManager = dropInFlowManager
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

    internal func resolveDropInRouter() -> DropInRouting {
        let apiClient = resolveAPIClient()

        let viewModel = DropInViewModel(
            title: title,
            componentManager: componentManager,
            apiClient: apiClient,
            paymentMethods: paymentMethods,
            context: context,
            configuration: configuration
        )

        let router = DropInRouter(
            viewModel: viewModel,
            preselectedPaymentMethodAssembler: preselectedPaymentMethodAssembler,
            paymentMethodListAssembler: paymentMethodListAssembler,
            componentContainerAssembler: componentContainerAssembler
        )

        return router
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
            paymentMethodListAssembler: paymentMethodListAssembler,
            componentContainerAssembler: componentContainerAssembler,
            context: context,
            configuration: configuration,
            dropInFlowManager: dropInFlowManager,
            cardComponentDelegate: cardComponentDelegate,
            partialPaymentDelegate: partialPaymentDelegate
        )
    }

    private var paymentMethodListAssembler: PaymentMethodListAssemblerProtocol {
        PaymentMethodListAssembler(
            componentContainerAssembler: componentContainerAssembler,
            componentManager: componentManager,
            context: context,
            configuration: configuration,
            dropInFlowManager: dropInFlowManager,
            cardComponentDelegate: cardComponentDelegate,
            partialPaymentDelegate: partialPaymentDelegate
        )
    }
    
    private var componentContainerAssembler: ComponentContainerAssemblerProtocol {
        ComponentContainerAssembler(
            context: context,
            configuration: configuration,
            dropInFlowManager: dropInFlowManager,
            cardComponentDelegate: cardComponentDelegate,
            partialPaymentDelegate: partialPaymentDelegate
        )
    }
}
