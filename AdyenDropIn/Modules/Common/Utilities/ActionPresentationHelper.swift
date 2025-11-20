//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A centralized helper to prepare an action `PresentableComponent` for presentation.
/// Wraps the action component in `ActionWrapperViewController` only if needed.
internal enum ActionPresentationHelper {

    internal static func container(
        for actionComponent: PresentableComponent,
        onCancel: (() -> Void)? = nil
    ) -> UIViewController {
        let viewController = actionComponent.viewController

        // If the action component already manages its own navigation controller, return as-is
        if viewController is UINavigationController {
            return viewController
        }

        return ActionWrapperViewController(
            actionComponent: actionComponent,
            onCancel: onCancel
        )
    }
}
