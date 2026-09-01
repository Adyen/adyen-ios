//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

// sourcery:AutoMockable
@MainActor
internal protocol StoredPaymentComponentAssemblerProtocol {
    func resolveStoredPaymentComponentRouter(
        delegate: StoredPaymentComponentRouterListener?,
        component: PaymentComponent,
        title: String
    ) -> Router
}

@MainActor
internal struct StoredPaymentComponentAssembler: StoredPaymentComponentAssemblerProtocol {

    // MARK: - Properties

    private let configuration: DropInComponent.Configuration
    private let dropInFlowManager: DropInFlowManaging
    private let componentContainerAssembler: ComponentContainerAssemblerProtocol
    private let analyticsProvider: AnyAnalyticsProvider?

    // MARK: - Initializers

    internal init(
        configuration: DropInComponent.Configuration,
        dropInFlowManager: DropInFlowManaging,
        componentContainerAssembler: ComponentContainerAssemblerProtocol,
        analyticsProvider: AnyAnalyticsProvider?
    ) {
        self.configuration = configuration
        self.dropInFlowManager = dropInFlowManager
        self.componentContainerAssembler = componentContainerAssembler
        self.analyticsProvider = analyticsProvider
    }

    // MARK: - StoredPaymentComponentAssemblerProtocol

    internal func resolveStoredPaymentComponentRouter(
        delegate: StoredPaymentComponentRouterListener?,
        component: PaymentComponent,
        title: String
    ) -> Router {
        let viewModel = StoredPaymentComponentViewModel(
            component: component,
            title: title,
            theme: configuration.theme,
            localizationParameters: configuration.localizationParameters,
            analyticsProvider: analyticsProvider,
            dropInAnalyticsConfiguration: DropInAnalyticsConfiguration(configuration: configuration),
            dropInFlowManager: dropInFlowManager
        )
        let viewController = StoredPaymentComponentViewController(viewModel: viewModel)
        let router = StoredPaymentComponentRouter(
            viewController: viewController,
            listener: delegate,
            componentContainerAssembler: componentContainerAssembler
        )
        viewModel.router = router
        return router
    }
}
