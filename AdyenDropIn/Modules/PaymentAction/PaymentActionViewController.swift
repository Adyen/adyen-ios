//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

/// Hosts an action view controller that does not manage its own navigation.
internal class PaymentActionViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: PaymentActionViewModelProtocol
    internal let actionViewController: UIViewController

    // MARK: - Initializers

    internal init(
        viewModel: PaymentActionViewModelProtocol,
        actionViewController: UIViewController
    ) {
        self.viewModel = viewModel
        self.actionViewController = actionViewController
        super.init(nibName: nil, bundle: Bundle(for: PaymentActionViewController.self))
    }

    @available(*, unavailable)
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View life cycle

    override internal func viewDidLoad() {
        super.viewDidLoad()
        setupActionView()
        setupNavigationItem()
        navigationController?.presentationController?.delegate = self
    }

    // MARK: - Private

    private func setupActionView() {
        actionViewController.willMove(toParent: self)
        addChild(actionViewController)
        view.addSubview(actionViewController.view)
        actionViewController.didMove(toParent: self)
        setupLayout()
    }

    private func setupLayout() {
        actionViewController.view.adyen.anchor(inside: view)
    }

    private func setupNavigationItem() {
        navigationItem.title = actionViewController.title
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(didTapCancel)
        )
    }

    @objc private func didTapCancel() {
        viewModel.cancel()
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate

extension PaymentActionViewController: UIAdaptivePresentationControllerDelegate {

    internal func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        viewModel.cancel()
    }
}
