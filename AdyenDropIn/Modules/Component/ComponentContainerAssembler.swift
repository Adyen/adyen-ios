//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

internal protocol ComponentContainerAssemblerProtocol {
    func resolveContainerView(
        for component: PresentableComponent,
        delegate: ComponentContainerViewModelDelegate
    ) -> UIViewController
}

internal struct ComponentContainerAssembler: ComponentContainerAssemblerProtocol {

    // MARK: - Properties

    private let cardComponentDelegate: CardComponentDelegate?
    private let partialPaymentDelegate: PartialPaymentDelegate?

    // MARK: - Initializers

    internal init(
        cardComponentDelegate: CardComponentDelegate?,
        partialPaymentDelegate: PartialPaymentDelegate?
    ) {
        self.cardComponentDelegate = cardComponentDelegate
        self.partialPaymentDelegate = partialPaymentDelegate
    }

    // MARK: - ComponentContainerAssemblerProtocol

    internal func resolveContainerView(
        for component: PresentableComponent,
        delegate: ComponentContainerViewModelDelegate
    ) -> UIViewController {
        let viewModel = ComponentContainerViewModel(
            component: component,
            cardComponentDelegate: cardComponentDelegate,
            partialPaymentDelegate: partialPaymentDelegate
        )
        viewModel.delegate = delegate

        if let alertController = (component.viewController as? UIAlertController) {
            return alertController
        } else {
            let view = ComponentContainerViewController(viewModel: viewModel)
            return view
        }
    }
}
