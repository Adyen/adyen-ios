//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import AdyenUI
import Foundation
import UIKit

@MainActor
internal struct DropInAssembler {

    // MARK: - Properties

    private let title: String
    private let paymentMethods: PaymentMethods
    private let context: AdyenContext
    private let configuration: DropInComponent.Configuration
    private let componentManager: ComponentManager
    private let dropInFlowManager: DropInFlowManaging
    private let partialPaymentDelegate: PartialPaymentDelegate?

    // MARK: - Initializers

    internal init(
        title: String,
        paymentMethods: PaymentMethods,
        context: AdyenContext,
        configuration: DropInComponent.Configuration,
        dropInFlowManager: DropInFlowManaging,
        partialPaymentDelegate: PartialPaymentDelegate?
    ) {
        self.title = title
        self.paymentMethods = paymentMethods
        self.context = context
        self.configuration = configuration
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

        return DropInRouter(
            viewModel: viewModel,
            preselectedPaymentMethodAssembler: preselectedPaymentMethodAssembler,
            paymentMethodListAssembler: paymentMethodListAssembler,
            componentContainerAssembler: componentContainerAssembler
        )
    }

    // MARK: - Private

    private func resolveAPIClient() -> APIClientProtocol {
        let scheduler = SimpleScheduler(maximumCount: 3)
        return APIClient(apiContext: context.apiContext)
            .retryAPIClient(with: scheduler)
            .retryOnErrorAPIClient()
    }

    // TODO: - This should be replaced by the future LocalizationProvider
    private func resolveLocalizationProvider() -> LocalizationParameters {
        LocalizationParameters()
    }

    private func resolveAdyenTheme() -> AdyenTheme {
        AdyenTheme.default
    }

    private var preselectedPaymentMethodAssembler: PreselectedPaymentMethodAssemblerProtocol {
        PreselectedPaymentMethodAssembler(
            paymentMethodListAssembler: paymentMethodListAssembler,
            componentContainerAssembler: componentContainerAssembler,
            configuration: configuration,
            dropInFlowManager: dropInFlowManager,
            partialPaymentDelegate: partialPaymentDelegate,
            analyticsProvider: context.analyticsProvider
        )
    }

    private var paymentMethodListAssembler: PaymentMethodListAssemblerProtocol {
        PaymentMethodListAssembler(
            componentContainerAssembler: componentContainerAssembler,
            componentManager: componentManager,
            context: context,
            localizationParameters: resolveLocalizationProvider(),
            configuration: configuration,
            dropInFlowManager: dropInFlowManager,
            theme: resolveAdyenTheme(),
            partialPaymentDelegate: partialPaymentDelegate
        )
    }
    
    private var componentContainerAssembler: ComponentContainerAssemblerProtocol {
        ComponentContainerAssembler(
            configuration: configuration,
            dropInFlowManager: dropInFlowManager,
            partialPaymentDelegate: partialPaymentDelegate
        )
    }
}
