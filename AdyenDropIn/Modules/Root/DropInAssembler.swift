//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
#if canImport(AdyenUI)
    import AdyenUI
#endif
import Foundation
import UIKit

@MainActor
internal struct DropInAssembler {

    // MARK: - Properties

    private let title: String
    private let paymentMethods: PaymentMethods
    private let context: AdyenContext
    private let configuration: DropInConfiguration
    private let componentManager: ComponentManager
    private let dropInFlowManager: DropInFlowManaging
    private let partialPaymentDelegate: PartialPaymentDelegate?
    private let storedPaymentMethodManagementCapability: StoredPaymentMethodManagementCapability?

    // MARK: - Initializers

    internal init(
        title: String,
        paymentMethods: PaymentMethods,
        context: AdyenContext,
        configuration: DropInConfiguration,
        dropInFlowManager: DropInFlowManaging,
        partialPaymentDelegate: PartialPaymentDelegate?,
        storedPaymentMethodManagementCapability: StoredPaymentMethodManagementCapability?
    ) {
        self.title = title
        self.paymentMethods = paymentMethods
        self.context = context
        self.configuration = configuration
        self.partialPaymentDelegate = partialPaymentDelegate
        self.dropInFlowManager = dropInFlowManager
        self.storedPaymentMethodManagementCapability = storedPaymentMethodManagementCapability
        self.componentManager = ComponentManager(
            paymentMethods: paymentMethods,
            context: context,
            configuration: configuration,
            partialPaymentEnabled: false, // TODO: - Set partial payment flow
            order: nil,
            presentationDelegate: nil
        )
    }

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

    private func resolveAPIClient() -> AsyncAPIClientProtocol {
        APIClient(apiContext: context.apiContext)
    }

    private func resolveLocalizationParameters() -> LocalizationParameters {
        configuration.resolvedLocalizationParameters ?? LocalizationParameters()
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
            localizationParameters: resolveLocalizationParameters(),
            configuration: configuration,
            dropInFlowManager: dropInFlowManager,
            theme: configuration.theme,
            partialPaymentDelegate: partialPaymentDelegate,
            storedPaymentMethodManagementCapability: storedPaymentMethodManagementCapability
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
