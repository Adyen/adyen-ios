//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

// sourcery:AutoMockable
internal protocol ComponentContainerAssemblerProtocol {
    func resolveComponentContainerRouter(
        for component: PresentableComponent,
        delegate: ComponentContainerRouterListener,
        onCancel: (() -> Void)?
    ) -> Router
}

internal struct ComponentContainerAssembler: ComponentContainerAssemblerProtocol {

    // MARK: - Properties

    private let configuration: DropInComponent.Configuration
    private let dropInFlowManager: DropInFlowManaging
    private let partialPaymentDelegate: PartialPaymentDelegate?

    // MARK: - Initializers

    internal init(
        configuration: DropInComponent.Configuration,
        dropInFlowManager: DropInFlowManaging,
        partialPaymentDelegate: PartialPaymentDelegate?
    ) {
        self.configuration = configuration
        self.dropInFlowManager = dropInFlowManager
        self.partialPaymentDelegate = partialPaymentDelegate
    }

    // MARK: - ComponentContainerAssemblerProtocol

    internal func resolveComponentContainerRouter(
        for component: PresentableComponent,
        delegate: ComponentContainerRouterListener,
        onCancel: (() -> Void)?
    ) -> Router {
        let viewModel = ComponentContainerViewModel(
            component: component,
            configuration: configuration,
            dropInFlowManager: dropInFlowManager,
            partialPaymentDelegate: partialPaymentDelegate,
            onCancel: onCancel
        )
        let viewController = ComponentContainerViewController(viewModel: viewModel)
        let router = ComponentContainerRouter(
            viewController: viewController,
            listener: delegate
        )
        viewModel.router = router
        return router
    }
}
