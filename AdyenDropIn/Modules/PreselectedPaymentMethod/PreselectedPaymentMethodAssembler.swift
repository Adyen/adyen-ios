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
    private let dropInComponent: DropInComponent
    private let dropInComponentDelegate: DropInComponentDelegate?
    private let cardComponentDelegate: CardComponentDelegate?
    private let partialPaymentDelegate: PartialPaymentDelegate?
    
    // MARK: - Initializers
    
    internal init(
        context: AdyenContext,
        configuration: DropInComponent.Configuration,
        dropInComponent: DropInComponent,
        dropInComponentDelegate: DropInComponentDelegate?,
        cardComponentDelegate: CardComponentDelegate?,
        partialPaymentDelegate: PartialPaymentDelegate?
    ) {
        self.context = context
        self.configuration = configuration
        self.dropInComponent = dropInComponent
        self.dropInComponentDelegate = dropInComponentDelegate
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
            dropInComponent: dropInComponent,
            dropInComponentDelegate: dropInComponentDelegate,
            cardComponentDelegate: cardComponentDelegate,
            partialPaymentDelegate: partialPaymentDelegate
        )
        let viewModel = PreselectedPaymentMethodViewModel(
            component: component,
            title: title,
            configuration: configuration,
            dropInComponent: dropInComponent,
            dropInComponentDelegate: dropInComponentDelegate
        )
        let view = PreselectedPaymentMethodViewController(viewModel: viewModel)
        let router = PreselectedPaymentMethodRouter(
            viewController: view,
            loadable: viewModel,
            listener: delegate,
            componentContainerAssembler: componentContainerAssembler
        )
        viewModel.router = router
        return router
    }
}
