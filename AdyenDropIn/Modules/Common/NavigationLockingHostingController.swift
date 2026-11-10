//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Combine
import SwiftUI
import UIKit

/// Hosts a SwiftUI Drop-in screen that keeps the system back button, and locks the navigation while a payment is in progress.
internal final class NavigationLockingHostingController<Content: View>: UIHostingController<Content> {

    private let onPop: () -> Void
    private let onCancel: (() -> Void)?
    private var isLocked = false
    private var cancellables = Set<AnyCancellable>()

    internal private(set) lazy var cancelButtonItem = UIBarButtonItem(
        systemItem: .cancel,
        primaryAction: UIAction { [weak self] _ in
            self?.onCancel?()
        }
    )

    /// - Parameters:
    ///   - rootView: The screen to host.
    ///   - isNavigationLocked: Whether the shopper cannot navigate away from the screen, for example while a payment is in progress.
    ///   - onPop: Called when the shopper went back from the screen.
    ///   - onCancel: When set, the screen gets the system Cancel button, which calls it.
    internal init(
        rootView: Content,
        isNavigationLocked: AnyPublisher<Bool, Never>,
        onPop: @escaping () -> Void,
        onCancel: (() -> Void)? = nil
    ) {
        self.onPop = onPop
        self.onCancel = onCancel
        super.init(rootView: rootView)
        isModalInPresentation = true
        setupNavigationItem()
        observe(isNavigationLocked)
    }

    @available(*, unavailable)
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override internal func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateNavigationLock()
    }

    override internal func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationLock(active: false)
    }

    override internal func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        guard navigationController?.viewControllers.contains(self) != true else { return }
        onPop()
    }

    private func setupNavigationItem() {
        guard onCancel != nil else { return }
        navigationItem.leftBarButtonItem = cancelButtonItem
    }

    private func observe(_ isNavigationLocked: AnyPublisher<Bool, Never>) {
        isNavigationLocked
            .removeDuplicates()
            .sink { [weak self] isNavigationLocked in
                guard let self else { return }
                isLocked = isNavigationLocked
                cancelButtonItem.isEnabled = !isNavigationLocked
                updateNavigationLock()
            }
            .store(in: &cancellables)
    }

    private func updateNavigationLock() {
        guard let navigationController, navigationController.topViewController === self else { return }
        navigationController.setNavigationLock(active: isLocked)
        let hasScreenBehind = navigationController.viewControllers.first !== self
        navigationItem.backAction = isLocked && hasScreenBehind ? UIAction { _ in } : nil
    }
}
