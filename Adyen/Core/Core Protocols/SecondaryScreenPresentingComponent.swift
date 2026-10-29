//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// A component whose form opens secondary screens, like the installments, country and phone prefix pickers or the address lookup.
///
/// Whoever routes the component decides how those screens appear, by setting ``presenter``:
/// - A standalone component routes itself and presents them modally, as it does not know where the merchant shows it.
/// - Drop-in's router replaces it to push them onto Drop-in's navigation stack.
@MainActor
package protocol SecondaryScreenPresentingComponent: PaymentComponent, ViewControllerPresenter {

    /// Shows the screens this component opens, like pickers or the address lookup.
    /// Modal by default, replaced by whoever routes the component.
    var presenter: ViewControllerPresenter { get set }
}

extension SecondaryScreenPresentingComponent {

    package func presentViewController(_ viewController: UIViewController, animated: Bool) {
        presenter.presentViewController(viewController, animated: animated)
    }

    package func dismissViewController(animated: Bool) {
        presenter.dismissViewController(animated: animated)
    }
}
