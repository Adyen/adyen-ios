//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

internal protocol PreselectedPaymentMethodRouterProtocol: AnyObject {
    var rootViewController: UIViewController { get }
    var delegate: PreselectedPaymentMethodRouterDelegate? { get set }
    func dismiss(completion: (() -> Void)?)
    func showAllPaymentMethods()
    func proceed(with paymentComponent: PresentableComponent)
}

internal protocol PreselectedPaymentMethodRouterDelegate: AnyObject {
    func showAllPaymentMethods()
    func didProceed(with paymentComponent: PresentableComponent)
}

internal class PreselectedPaymentMethodRouter: PreselectedPaymentMethodRouterProtocol {
    
    // MARK: - Properties

    internal var view: UIViewController?
    internal weak var delegate: PreselectedPaymentMethodRouterDelegate?

    // MARK: - Initializers

    // MARK: - PreselectedPaymentMethodRouterProtocol

    internal var rootViewController: UIViewController {
        guard let view else {
            fatalError("Router's view was not set.")
        }
        return view
    }

    internal func dismiss(completion: (() -> Void)?) {
        view?.dismiss(animated: true, completion: completion)
    }

    internal func showAllPaymentMethods() {
        delegate?.showAllPaymentMethods()
    }

    internal func proceed(with paymentComponent: any PresentableComponent) {
        // TODO: - Handle logic with preselected payment method
        delegate?.didProceed(with: paymentComponent)
    }
}
