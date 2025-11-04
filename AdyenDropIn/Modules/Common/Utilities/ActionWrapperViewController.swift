//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// A modal wrapper for action view controllers, adds a navigation bar with cancel button and handles dismissal.
internal class ActionWrapperViewController: UINavigationController {
    
    // MARK: - Properties

    private var onCancel: (() -> Void)?
    
    // MARK: - Initializers

    internal init(
        rootViewController: UIViewController,
        onCancel: (() -> Void)? = nil
    ) {
        super.init(rootViewController: rootViewController)
        self.onCancel = onCancel
        
        rootViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(
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
        dismiss(animated: true) { [weak self] in
            self?.onCancel?()
        }
    }
}
