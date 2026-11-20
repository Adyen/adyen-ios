//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

// sourcery:AutoMockable
@MainActor
internal protocol PaymentActionRouterListener: AnyObject {
    func didDismissPaymentAction(completion: (@MainActor @Sendable () -> Void)?)
}

// sourcery:AutoMockable
@MainActor
internal protocol PaymentActionRouting: AnyObject {
    func dismiss(completion: (@MainActor @Sendable () -> Void)?)
}

@MainActor
internal class PaymentActionRouter: @MainActor Router, @MainActor PaymentActionRouting {

    // MARK: - Properties

    internal let rootViewController: UIViewController
    internal var childRouter: Router?
    private let viewModel: PaymentActionViewModelProtocol
    private weak var listener: PaymentActionRouterListener?

    // MARK: - Initializers

    internal init(
        viewController: UIViewController,
        viewModel: PaymentActionViewModelProtocol,
        listener: PaymentActionRouterListener
    ) {
        self.rootViewController = viewController
        self.viewModel = viewModel
        self.listener = listener
    }

    // MARK: - PaymentActionRouting

    /// The action view is dismissed along with the drop in it is presented on top of,
    /// so the listener is only informed about the dismissal.
    internal func dismiss(completion: (@MainActor @Sendable () -> Void)?) {
        listener?.didDismissPaymentAction(completion: completion)
    }
}
