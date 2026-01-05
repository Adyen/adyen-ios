//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// A modal wrapper for action view controllers, adds a navigation bar with cancel button and handles dismissal.
internal class ActionWrapperViewController: UINavigationController {

    // MARK: - Properties

    internal var onCancel: (() -> Void)?

    // MARK: - Initializers

    internal init(
        actionComponent: any PresentableComponent,
        onCancel: (() -> Void)? = nil
    ) {
        let actionComponentViewController = actionComponent.viewController
        super.init(rootViewController: actionComponentViewController)
        self.onCancel = onCancel

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

    // MARK: - View life cycle

    override internal func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        onCancel?()
    }

    // MARK: - Private

    @objc private func didTapCancel() {
        dismiss(animated: true)
    }
}
