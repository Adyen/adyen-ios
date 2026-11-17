//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenUI
import Foundation
import UIKit

@MainActor
internal protocol ComponentContainerAssemblerProtocol {

    /// - Parameter isDropInRoot: Whether the container is the root of the drop in, in which case it lets the shopper close the drop in.
    func resolveComponentContainerRouter(
        for component: PaymentComponent,
        isDropInRoot: Bool,
        listener: ComponentContainerRouterListener
    ) -> Router
}

@MainActor
internal struct ComponentContainerAssembler: ComponentContainerAssemblerProtocol {

    // MARK: - Properties

    private let configuration: DropInConfiguration
    private let dropInFlowManager: DropInFlowManaging
    private let partialPaymentDelegate: PartialPaymentDelegate?

    // MARK: - Initializers

    internal init(
        configuration: DropInConfiguration,
        dropInFlowManager: DropInFlowManaging,
        partialPaymentDelegate: PartialPaymentDelegate?
    ) {
        self.configuration = configuration
        self.dropInFlowManager = dropInFlowManager
        self.partialPaymentDelegate = partialPaymentDelegate
    }

    // MARK: - ComponentContainerAssemblerProtocol

    internal func resolveComponentContainerRouter(
        for component: PaymentComponent,
        isDropInRoot: Bool,
        listener: ComponentContainerRouterListener
    ) -> Router {
        let viewModel = ComponentContainerViewModel(
            component: component,
            theme: configuration.theme,
            configuration: configuration,
            dropInFlowManager: dropInFlowManager,
            partialPaymentDelegate: partialPaymentDelegate,
            isDropInRoot: isDropInRoot
        )
        let viewController = ComponentContainerViewController(viewModel: viewModel)
        let router = ComponentContainerRouter(
            viewController: viewController,
            listener: listener
        )
        viewModel.router = router
        return router
    }
}
