//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

#if canImport(AdyenUI)
    import AdyenUI
#endif

/// Hosts an action view controller that does not manage its own navigation.
internal class PaymentActionViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: PaymentActionViewModelProtocol
    internal let actionViewController: UIViewController
    private var isInteractivePopGestureEnabled: Bool?

    private var theme: CheckoutTheme {
        viewModel.theme
    }

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
        setupView()
        setupActionView()
        setupNavigationItem()
        navigationController?.presentationController?.delegate = self
    }

    /// The payment has already been submitted at this point, so there is no way back to the
    /// payment details of the selected payment method. The only exit is dismissing the drop in.
    override internal func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let popGestureRecognizer = navigationController?.interactivePopGestureRecognizer else {
            return
        }

        isInteractivePopGestureEnabled = popGestureRecognizer.isEnabled
        popGestureRecognizer.isEnabled = false
    }

    /// The navigation controller is shared with the rest of the drop in,
    /// so its original state is restored once this view is no longer on screen.
    override internal func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        guard let isInteractivePopGestureEnabled else {
            return
        }

        navigationController?.interactivePopGestureRecognizer?.isEnabled = isInteractivePopGestureEnabled
        self.isInteractivePopGestureEnabled = nil
    }

    // MARK: - Private

    private func setupView() {
        view.backgroundColor = theme.colors.background
    }

    private func setupActionView() {
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
        navigationItem.hidesBackButton = true

        let doneButton = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(didTapDone)
        )
        doneButton.tintColor = theme.colors.primary

        navigationItem.rightBarButtonItem = doneButton
    }

    @objc private func didTapDone() {
        viewModel.cancel()
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate

extension PaymentActionViewController: UIAdaptivePresentationControllerDelegate {

    internal func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        viewModel.cancel()
    }
}
