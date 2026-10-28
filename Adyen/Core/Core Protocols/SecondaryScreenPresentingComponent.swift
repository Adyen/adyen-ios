//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// A component whose form opens secondary screens, like the installments, country and phone prefix pickers or the address lookup.
///
/// Whoever routes the component decides how those screens appear:
/// - Drop-in's router sets itself as ``secondaryScreenPresenter`` and pushes them onto Drop-in's navigation stack.
/// - Left `nil`, as for a standalone component, they are presented modally by ``modalSecondaryScreenPresenter``.
@MainActor
package protocol SecondaryScreenPresentingComponent: PaymentComponent, ViewControllerPresenter {

    /// The presenter set by whoever routes the component. `nil` presents secondary screens modally.
    var secondaryScreenPresenter: ViewControllerPresenter? { get set }

    /// The presenter used when ``secondaryScreenPresenter`` is `nil`.
    var modalSecondaryScreenPresenter: ModalSecondaryScreenPresenter { get }
}

extension SecondaryScreenPresentingComponent {

    package func presentViewController(_ viewController: UIViewController, animated: Bool) {
        routingPresenter.presentViewController(viewController, animated: animated)
    }

    package func dismissViewController(animated: Bool) {
        routingPresenter.dismissViewController(animated: animated)
    }

    private var routingPresenter: ViewControllerPresenter {
        secondaryScreenPresenter ?? modalSecondaryScreenPresenter
    }
}
