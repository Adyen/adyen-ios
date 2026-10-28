//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// Presents secondary screens by pushing them onto the navigation stack
/// of the view controller they originate from, instead of modally.
///
/// Injected into `SecondaryScreenNavigable` component view controllers by
/// the drop in. Standalone components are not injected and keep presenting
/// secondary screens modally.
@MainActor
internal final class SecondaryScreenPushPresenter: ViewControllerPresenter {

    // MARK: - Properties

    /// The view controller whose navigation stack receives the secondary screens.
    private weak var source: UIViewController?

    // MARK: - Initializers

    internal init(source: UIViewController) {
        self.source = source
    }

    // MARK: - ViewControllerPresenter

    internal func presentViewController(_ viewController: UIViewController, animated: Bool) {
        source?.navigationController?.pushViewController(viewController, animated: animated)
    }

    internal func dismissViewController(animated: Bool) {
        guard let navigationController = source?.navigationController,
              navigationController.topViewController !== source else {
            // Nothing was pushed on top of the source; fall back to a regular dismiss.
            source?.dismiss(animated: animated)
            return
        }
        navigationController.popViewController(animated: animated)
    }
}
