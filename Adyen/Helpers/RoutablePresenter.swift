//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// A presenter that forwards to a target which can be changed later with ``route(through:)``.
///
/// The object itself never changes, so whoever keeps it, like form items, always reaches the latest target,
/// for example Drop-in's router, which is set after the component is built.
@MainActor
package final class RoutablePresenter: ViewControllerPresenter {

    private var target: ViewControllerPresenter

    package init(default target: ViewControllerPresenter) {
        self.target = target
    }

    /// Forwards every later call to `target`. Called by whoever routes the component, like Drop-in's router.
    package func route(through target: ViewControllerPresenter) {
        self.target = target
    }

    package func presentViewController(_ viewController: UIViewController, animated: Bool) {
        target.presentViewController(viewController, animated: animated)
    }

    package func dismissViewController(_ viewController: UIViewController, animated: Bool) {
        target.dismissViewController(viewController, animated: animated)
    }
}
