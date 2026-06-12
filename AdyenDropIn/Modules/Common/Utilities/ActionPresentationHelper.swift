//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import SafariServices

/// A centralized helper to prepare an action view controller for presentation.
/// Wraps the action component in `ActionWrapperViewController` only if needed.
@MainActor
internal enum ActionPresentationHelper {

    internal static func viewController(
        for actionViewController: UIViewController,
        onCancel: (() -> Void)? = nil
    ) -> UIViewController {
        let viewController = actionViewController

        // If the action component already manages its own navigation controller, return as-is
        if viewController is SFSafariViewController {
            return viewController
        }

        return ActionWrapperViewController(
            actionViewController: actionViewController,
            onCancel: onCancel
        )
    }
}
