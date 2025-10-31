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

internal protocol ComponentContainerAssemblerProtocol {
    func resolveComponentContainerRouter(
        for component: PresentableComponent,
        delegate: ComponentContainerRouterListener,
        onCancel: (() -> Void)?
    ) -> Router
}

internal struct ComponentContainerAssembler: ComponentContainerAssemblerProtocol {

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

    // MARK: - ComponentContainerAssemblerProtocol

    internal func resolveComponentContainerRouter(
        for component: PresentableComponent,
        delegate: ComponentContainerRouterListener,
        onCancel: (() -> Void)?
    ) -> Router {
        let viewModel = ComponentContainerViewModel(
            component: component,
            context: context,
            configuration: configuration,
            dropInComponent: dropInComponent,
            dropInComponentDelegate: dropInComponentDelegate,
            cardComponentDelegate: cardComponentDelegate,
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
    
//    private func resolveComponentContainerViewController(
//        for component: PresentableComponent,
//        viewModel: ComponentContainerViewModelProtocol
//    ) -> UIViewController {
//        if let alertController = component.viewController as? UIAlertController {
//            return alertController
//        } else {
//            return ComponentContainerViewController(viewModel: viewModel)
//        }
//    }
}
