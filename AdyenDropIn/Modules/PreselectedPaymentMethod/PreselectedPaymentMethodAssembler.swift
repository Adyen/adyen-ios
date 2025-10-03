//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenCard)
    import AdyenCard
#endif
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
    
    private let context: AdyenContext
    private let configuration: DropInComponent.Configuration
    private let cardComponentDelegate: CardComponentDelegate?
    private let partialPaymentDelegate: PartialPaymentDelegate?
    
    // MARK: - Initializers
    
    internal init(
        context: AdyenContext,
        configuration: DropInComponent.Configuration,
        cardComponentDelegate: CardComponentDelegate?,
        partialPaymentDelegate: PartialPaymentDelegate?
    ) {
        self.context = context
        self.configuration = configuration
        self.cardComponentDelegate = cardComponentDelegate
        self.partialPaymentDelegate = partialPaymentDelegate
    }
    
    // MARK: - PreselectedPaymentMethodAssemblerProtocol
    
    internal func resolvePreselectedPaymentMethodRouter(
        delegate: PreselectedPaymentMethodRouterListener?,
        component: PaymentComponent,
        title: String
    ) -> Router {
        let componentContainerAssembler = ComponentContainerAssembler(
            context: context,
            configuration: configuration,
            cardComponentDelegate: cardComponentDelegate,
            partialPaymentDelegate: partialPaymentDelegate
        )
        let viewModel = PreselectedPaymentMethodViewModel(
            component: component,
            title: title,
            configuration: configuration
        )
        let view = PreselectedPaymentMethodViewController(viewModel: viewModel)
        let router = PreselectedPaymentMethodRouter(
            viewController: view,
            viewModel: viewModel,
            listener: delegate,
            componentContainerAssembler: componentContainerAssembler
        )
        viewModel.router = router
        return router
    }
}
