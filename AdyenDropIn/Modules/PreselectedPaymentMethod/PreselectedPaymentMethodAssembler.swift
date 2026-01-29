//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

internal protocol PreselectedPaymentMethodAssemblerProtocol {
    func resolvePreselectedPaymentMethodRouter(
        delegate: PreselectedPaymentMethodRouterListener?,
        component: PaymentComponent,
        title: String
    ) -> Router
}

internal struct PreselectedPaymentMethodAssembler: PreselectedPaymentMethodAssemblerProtocol {
    
    // MARK: - Properties
    
    private let paymentMethodListAssembler: PaymentMethodListAssemblerProtocol
    private let componentContainerAssembler: ComponentContainerAssemblerProtocol
    private let configuration: DropInComponent.Configuration
    private let dropInFlowManager: DropInFlowManaging
    private let partialPaymentDelegate: PartialPaymentDelegate?
    
    // MARK: - Initializers
    
    internal init(
        paymentMethodListAssembler: PaymentMethodListAssemblerProtocol,
        componentContainerAssembler: ComponentContainerAssemblerProtocol,
        configuration: DropInComponent.Configuration,
        dropInFlowManager: DropInFlowManaging,
        partialPaymentDelegate: PartialPaymentDelegate?
    ) {
        self.paymentMethodListAssembler = paymentMethodListAssembler
        self.componentContainerAssembler = componentContainerAssembler
        self.configuration = configuration
        self.dropInFlowManager = dropInFlowManager
        self.partialPaymentDelegate = partialPaymentDelegate
    }
    
    // MARK: - PreselectedPaymentMethodAssemblerProtocol
    
    internal func resolvePreselectedPaymentMethodRouter(
        delegate: PreselectedPaymentMethodRouterListener?,
        component: PaymentComponent,
        title: String
    ) -> Router {
        let viewModel = PreselectedPaymentMethodViewModel(
            component: component,
            theme: configuration.theme,
            localizationParameters: configuration.localizationParameters,
            dropInFlowManager: dropInFlowManager
        )
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
