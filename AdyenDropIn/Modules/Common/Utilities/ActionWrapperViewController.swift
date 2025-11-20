//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// A modal wrapper for action view controllers, adds a navigation bar with cancel button and handles dismissal.
internal class ActionWrapperViewController: UINavigationController {

    // MARK: - Initializers

    internal init(actionComponent: any PresentableComponent) {
        let actionComponentViewController = actionComponent.viewController
        super.init(rootViewController: actionComponentViewController)

        actionComponentViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(didTapCancel)
        )
    }

    @available(*, unavailable)
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private

    @objc private func didTapCancel() {
        dismiss(animated: true)
    }
}
