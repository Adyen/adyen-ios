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
internal protocol ComponentContainerAssemblerProtocol {
    func resolveComponentContainerRouter(
        for component: PaymentComponent,
        listener: ComponentContainerRouterListener
    ) -> Router
}

@MainActor
internal struct ComponentContainerAssembler: ComponentContainerAssemblerProtocol {

    // MARK: - Properties

    private let configuration: DropInConfiguration
    private let dropInFlowManager: DropInFlowManaging
    private let paymentActionAssembler: PaymentActionAssemblerProtocol
    private let partialPaymentDelegate: PartialPaymentDelegate?

    // MARK: - Initializers

    internal init(
        configuration: DropInConfiguration,
        dropInFlowManager: DropInFlowManaging,
        paymentActionAssembler: PaymentActionAssemblerProtocol,
        partialPaymentDelegate: PartialPaymentDelegate?
    ) {
        self.configuration = configuration
        self.dropInFlowManager = dropInFlowManager
        self.paymentActionAssembler = paymentActionAssembler
        self.partialPaymentDelegate = partialPaymentDelegate
    }

    // MARK: - ComponentContainerAssemblerProtocol

    internal func resolveComponentContainerRouter(
        for component: PaymentComponent,
        listener: ComponentContainerRouterListener
    ) -> Router {
        let viewModel = ComponentContainerViewModel(
            component: component,
            configuration: configuration,
            dropInFlowManager: dropInFlowManager,
            partialPaymentDelegate: partialPaymentDelegate
        )
        let viewController = ComponentContainerViewController(viewModel: viewModel)
        let router = ComponentContainerRouter(
            viewController: viewController,
            paymentActionAssembler: paymentActionAssembler,
            listener: listener
        )
        viewModel.router = router
        return router
    }
}
