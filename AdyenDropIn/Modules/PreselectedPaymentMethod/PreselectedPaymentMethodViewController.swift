//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit
@_spi(AdyenInternal) import Adyen

internal class PreselectedPaymentMethodViewController: UIViewController {

    private enum Constants {
        static let topMargin = 30.0
        static let leadingMargin = 15.0
        static let trailingMargin = 15.0
        static let bottomMargin = 15.0
    }

    // MARK: - Properties

    private let viewModel: PreselectedPaymentMethodViewModelProtocol

    private lazy var scrollView = UIScrollView(frame: .zero)

    private lazy var contentStackView: UIStackView = .init(
        arrangedSubviews: [
        ],
        spacing: 16,
        view: self
    )

    internal lazy var buttonsStackView: UIStackView = .init(
        arrangedSubviews: [
        ],
        distribution: .fillEqually,
        spacing: 8,
        view: self
    )

    // MARK: - Initializers

    internal init(viewModel: PreselectedPaymentMethodViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View life cycle

    override internal func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
        // setupPaymentMethodView()
        // setupNavigationItem()
    }

    // MARK: - Private

    private func buildUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStackView)
        view.addSubview(scrollView)
        view.addSubview(buttonsStackView)
    }

    private func configureViews() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStackView)
        addSubview(scrollView)
        addSubview(buttonsStackView)

        NSLayoutConstraint.activate([
            logoImage.heightAnchor.constraint(equalToConstant: 40),

            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: Constants.topMargin),
            scrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: Constants.leadingMargin),
            scrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -Constants.trailingMargin),
            scrollView.bottomAnchor.constraint(equalTo: buttonsStackView.topAnchor, constant: -8),

            contentStackView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor),
            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 10),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),

            buttonsStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: Constants.leadingMargin),
            buttonsStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -Constants.trailingMargin),
            buttonsStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -Constants.bottomMargin)
        ])
    }

    // MARK: - Unused methods //TODO: To Review these methods usage.

    private func setupPaymentMethodView() {
        let paymentMethodView = viewModel.paymentMethodView

        paymentMethodView.willMove(toParent: self)
        addChild(paymentMethodView)
        view.addSubview(paymentMethodView.view)
        paymentMethodView.didMove(toParent: self)
        paymentMethodView.view.adyen.anchor(inside: view)
    }

    private func setupNavigationItem() {
        navigationItem.title = viewModel.paymentMethodView.title
        setupCancelButton()
    }
    
    private func setupCancelButton() {
        let cancelButton = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        navigationItem.leftBarButtonItem = cancelButton
    }
    
    @objc private func cancelTapped() {
        viewModel.cancel()
    }
}
