//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// A modal wrapper for action view controllers, adds a navigation bar with cancel button and handles dismissal.
internal class ActionNavigationController: UINavigationController {

    // MARK: - Properties

    internal var onCancel: (() -> Void)?

    // MARK: - Initializers

    internal init(
        actionViewController: UIViewController,
        onCancel: (() -> Void)? = nil
    ) {
        super.init(rootViewController: actionViewController)
        self.onCancel = onCancel

        actionViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(
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
