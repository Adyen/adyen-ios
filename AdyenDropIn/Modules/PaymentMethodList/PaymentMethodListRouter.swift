//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

internal protocol PaymentMethodListRouterProtocol {
    func didLoad()
    func present(_ component: PresentableComponent)
    func delete(
        storedPaymentMethod: StoredPaymentMethod,
        completion: @escaping (Bool) -> Void
    )
}

internal class PaymentMethodListRouter: PaymentMethodListRouterProtocol {

    // MARK: - Properties

    private let componentContainerAssembler: ComponentContainerAssemblerProtocol
    internal weak var view: UIViewController?

    // MARK: - Initializers

    internal init(componentContainerAssembler: ComponentContainerAssemblerProtocol) {
        self.componentContainerAssembler = componentContainerAssembler
    }

    // MARK: - PaymentMethodListRouterProtocol

    internal func didLoad() {
        // TODO: -
        print("Payment method list did load")
    }

    internal func present(_ component: PresentableComponent) {
        let componentContainerView = componentContainerAssembler.resolveContainerView(for: component)
        view?.navigationController?.pushViewController(componentContainerView, animated: true)
    }

    internal func delete(
        storedPaymentMethod: any Adyen.StoredPaymentMethod,
        completion: @escaping (Bool) -> Void
    ) {
        // TODO: -
    }

    // MARK: - Private
}
