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

    internal let viewModel: StoredPaymentMethodManagementViewModel
    internal var onDismissFromNavigation: (() -> Void)?
    private let theme: CheckoutTheme
    private var cancellables = Set<AnyCancellable>()

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

    override internal func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateNavigation(isEnabled: !viewModel.isRemoving)
    }

    override internal func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if isMovingFromParent || isBeingDismissed || navigationController?.isBeingDismissed == true {
            onDismissFromNavigation?()
        }
    }

    private func observeRemovalState() {
        // disable navigation if there is a removal operation
        viewModel.$identifiersBeingRemoved
            .map(\.isEmpty)
            .removeDuplicates()
            .sink { [weak self] isEmpty in
                self?.updateNavigation(isEnabled: isEmpty)
            }
            .store(in: &cancellables)
    }

    private func updateNavigation(isEnabled: Bool) {
        navigationController?.navigationBar.isUserInteractionEnabled = isEnabled
        navigationController?.navigationBar.tintColor = isEnabled ? theme.colors.highlight : theme.colors.textOnDisabled
        navigationController?.interactivePopGestureRecognizer?.isEnabled = isEnabled
    }
}
