//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import SwiftUI
import UIKit

/// Locks the navigation bar and the pop gestures of the screen it is attached to while `isActive`,
/// and reports when the shopper goes back from that screen.
/// When `onCancel` is set, the screen also gets the system Cancel button.
internal struct NavigationLock: UIViewControllerRepresentable {

    internal let isActive: Bool
    internal let onPop: () -> Void
    internal var onCancel: (() -> Void)?

    internal func makeUIViewController(context: Context) -> NavigationLockViewController {
        NavigationLockViewController()
    }

    internal func updateUIViewController(_ uiViewController: NavigationLockViewController, context: Context) {
        uiViewController.onPop = onPop
        uiViewController.onCancel = onCancel
        uiViewController.isLockActive = isActive
    }
}

internal final class NavigationLockViewController: UIViewController {

    internal var onPop: (() -> Void)?
    internal var onCancel: (() -> Void)?

    internal var isLockActive = false {
        didSet {
            guard isLockActive != oldValue else { return }
            cancelButtonItem.isEnabled = !isLockActive
            applyLock()
        }
    }

    /// The ancestor of this controller that sits in the navigation stack.
    private weak var screen: UIViewController?
    private weak var stack: UINavigationController?

    internal private(set) lazy var cancelButtonItem = UIBarButtonItem(
        systemItem: .cancel,
        primaryAction: UIAction { [weak self] _ in
            self?.onCancel?()
        }
    )

    override internal func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        screen = screenInNavigationStack
        stack = screen?.navigationController
        setupCancelButton()
        applyLock()
    }

    override internal func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationLock(active: false)
    }

    override internal func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        guard let screen, let stack, !stack.viewControllers.contains(screen) else { return }
        onPop?()
    }

    private func setupCancelButton() {
        guard let screen, onCancel != nil else { return }
        cancelButtonItem.isEnabled = !isLockActive
        screen.navigationItem.leftBarButtonItem = cancelButtonItem
    }

    private func applyLock() {
        guard let navigationController, let screen, navigationController.topViewController === screen else { return }
        navigationController.setNavigationLock(active: isLockActive)
    }

    private var screenInNavigationStack: UIViewController? {
        var candidate: UIViewController = self
        while let parent = candidate.parent {
            if parent is UINavigationController {
                return candidate
            }
            candidate = parent
        }
        return nil
    }
}
