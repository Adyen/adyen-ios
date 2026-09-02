//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Combine
import SwiftUI
#if canImport(AdyenUI)
    import AdyenUI
#endif
import UIKit

@MainActor
// swiftlint:disable:next type_name
internal final class StoredPaymentMethodManagementHostingController: UIHostingController<StoredPaymentMethodManagementView> {

    private struct NavigationState {
        let isUserInteractionEnabled: Bool
        let tintColor: UIColor?
        let isInteractivePopGestureEnabled: Bool

        func apply(to navigationController: UINavigationController) {
            navigationController.navigationBar.isUserInteractionEnabled = isUserInteractionEnabled
            navigationController.navigationBar.tintColor = tintColor
            navigationController.interactivePopGestureRecognizer?.isEnabled = isInteractivePopGestureEnabled
        }
    }

    internal let viewModel: StoredPaymentMethodManagementViewModel
    internal var onDismissFromNavigation: (() -> Void)?
    private let theme: CheckoutTheme
    private var cancellables = Set<AnyCancellable>()
    private var originalNavigationState: NavigationState?

    internal init(viewModel: StoredPaymentMethodManagementViewModel, theme: CheckoutTheme) {
        self.viewModel = viewModel
        self.theme = theme
        super.init(rootView: StoredPaymentMethodManagementView(viewModel: viewModel, theme: theme))
        navigationItem.largeTitleDisplayMode = .never
        observeRemovalState()
    }

    @available(*, unavailable)
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override internal func viewDidLoad() {
        super.viewDidLoad()
        viewModel.sendRenderEvent()
    }

    override internal func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let navigationController else {
            return
        }

        originalNavigationState = NavigationState(
            isUserInteractionEnabled: navigationController.navigationBar.isUserInteractionEnabled,
            tintColor: navigationController.navigationBar.tintColor,
            isInteractivePopGestureEnabled: navigationController.interactivePopGestureRecognizer?.isEnabled ?? false
        )
        setNavigationLock(active: viewModel.isRemoving)
    }

    override internal func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setNavigationLock(active: false)
    }

    override internal func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if isMovingFromParent || isBeingDismissed || navigationController?.isBeingDismissed == true {
            onDismissFromNavigation?()
        }
    }

    private func observeRemovalState() {
        viewModel.$identifiersBeingRemoved
            .map { !$0.isEmpty }
            .removeDuplicates()
            .sink { [weak self] isActive in
                self?.setNavigationLock(active: isActive)
            }
            .store(in: &cancellables)
    }

    private func setNavigationLock(active isActive: Bool) {
        guard let navigationController, let originalNavigationState else {
            return
        }

        if isActive {
            navigationController.navigationBar.isUserInteractionEnabled = false
            navigationController.navigationBar.tintColor = theme.colors.textOnDisabled
            navigationController.interactivePopGestureRecognizer?.isEnabled = false
        } else {
            originalNavigationState.apply(to: navigationController)
        }
    }
}
