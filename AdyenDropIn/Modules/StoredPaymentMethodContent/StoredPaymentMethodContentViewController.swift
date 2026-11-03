//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Combine
import SwiftUI
import UIKit

internal final class StoredPaymentMethodContentViewController: UIHostingController<StoredPaymentMethodContentView> {

    private let viewModel: StoredPaymentMethodContentViewModel
    private var cancellables = Set<AnyCancellable>()

    internal private(set) lazy var cancelButtonItem = UIBarButtonItem(
        systemItem: .cancel,
        primaryAction: UIAction { [weak self] _ in
            self?.viewModel.cancel()
        }
    )

    internal init(viewModel: StoredPaymentMethodContentViewModel) {
        self.viewModel = viewModel
        super.init(rootView: StoredPaymentMethodContentView(viewModel: viewModel))
        isModalInPresentation = true
        setupNavigationItem()
        observePaymentProgress()
    }

    @available(*, unavailable)
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override internal func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationLock(active: false)
    }

    override internal func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        guard navigationController?.viewControllers.contains(self) != true else { return }
        viewModel.cancel()
    }

    private func setupNavigationItem() {
        guard viewModel.showsCancelButton else { return }
        navigationItem.leftBarButtonItem = cancelButtonItem
    }

    private func observePaymentProgress() {
        viewModel.$isPaymentInProgress
            .removeDuplicates()
            .sink { [weak self] isPaymentInProgress in
                guard let self else { return }
                cancelButtonItem.isEnabled = !isPaymentInProgress
                guard navigationController?.topViewController === self else { return }
                navigationController?.setNavigationLock(active: isPaymentInProgress)
            }
            .store(in: &cancellables)
    }
}
