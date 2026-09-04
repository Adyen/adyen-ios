//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

// sourcery:AutoMockable
@MainActor
internal protocol PreselectedPaymentMethodAssemblerProtocol {
    func resolvePreselectedPaymentMethodRouter(
        delegate: PreselectedPaymentMethodRouterListener?,
        component: PaymentComponent,
        title: String
    ) -> Router
}

@MainActor
internal struct PreselectedPaymentMethodAssembler: PreselectedPaymentMethodAssemblerProtocol {
    
    // MARK: - Properties
    
    private let paymentMethodListAssembler: PaymentMethodListAssemblerProtocol
    private let componentContainerAssembler: ComponentContainerAssemblerProtocol
    private let configuration: DropInConfiguration
    private let dropInFlowManager: DropInFlowManaging
    private let partialPaymentDelegate: PartialPaymentDelegate?
    private let analyticsProvider: AnyAnalyticsProvider?

    // MARK: - Initializers
    
    internal init(
        paymentMethodListAssembler: PaymentMethodListAssemblerProtocol,
        componentContainerAssembler: ComponentContainerAssemblerProtocol,
        configuration: DropInConfiguration,
        dropInFlowManager: DropInFlowManaging,
        partialPaymentDelegate: PartialPaymentDelegate?,
        analyticsProvider: AnyAnalyticsProvider?
    ) {
        self.paymentMethodListAssembler = paymentMethodListAssembler
        self.componentContainerAssembler = componentContainerAssembler
        self.configuration = configuration
        self.dropInFlowManager = dropInFlowManager
        self.partialPaymentDelegate = partialPaymentDelegate
        self.analyticsProvider = analyticsProvider
    }
    
    // MARK: - PreselectedPaymentMethodAssemblerProtocol
    
    internal func resolvePreselectedPaymentMethodRouter(
        delegate: PreselectedPaymentMethodRouterListener?,
        component: PaymentComponent,
        title: String
    ) -> Router {
        var component = component
        let viewModel = PreselectedPaymentMethodViewModel(
            component: component,
            theme: configuration.theme,
            localizationParameters: configuration.resolvedLocalizationParameters,
            analyticsProvider: analyticsProvider,
            dropInAnalyticsConfiguration: DropInAnalyticsConfiguration(configuration: configuration),
            dropInFlowManager: dropInFlowManager
        )
        component.delegate = viewModel
        let viewController = PreselectedPaymentMethodViewController(viewModel: viewModel)
        let router = PreselectedPaymentMethodRouter(
            viewController: viewController,
            listener: delegate,
            paymentMethodListAssembler: paymentMethodListAssembler,
            componentContainerAssembler: componentContainerAssembler
        )
        viewModel.router = router
        return router
    }
}
