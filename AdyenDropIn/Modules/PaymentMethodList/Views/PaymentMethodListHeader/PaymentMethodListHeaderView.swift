//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenUI
import PassKit
import UIKit

internal final class PaymentMethodListHeaderView: UIView {

    private enum Layout {
        static let applePayButtonHeight: CGFloat = 48
        static let subtitleBottomMargin: CGFloat = 24
    }

    // MARK: - UI Elements
    
    private lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.text = viewModel.amount
        label.apply(viewModel.theme.elements.labels.title)
        label.numberOfLines = 1
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = viewModel.subtitle
        label.apply(viewModel.theme.elements.labels.body)
        label.textColor = viewModel.theme.colors.textSecondary
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var applePayButton: PKPaymentButton = {
        let button = PKPaymentButton(paymentButtonType: .plain, paymentButtonStyle: .automatic)
        button.cornerRadius = viewModel.theme.attributes.cornerRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(applePayButtonTapped), for: .touchUpInside)
        button.isHidden = !viewModel.showApplePayButton
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                amountLabel,
                subtitleLabel,
                applePayButton
            ]
        )
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    // MARK: - Properties

    private let viewModel: PaymentMethodListHeaderViewModel

    // MARK: - Initializers

    internal init(viewModel: PaymentMethodListHeaderViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
    }

    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    @objc private func applePayButtonTapped() {
        viewModel.onApplePayTap?()
    }
    
    // MARK: - Private
    
    private func setupView() {
        layoutMargins = .zero

        addSubview(stackView)
        
        if viewModel.showApplePayButton {
            stackView.setCustomSpacing(Layout.subtitleBottomMargin, after: subtitleLabel)
        }

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),

            applePayButton.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            applePayButton.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            applePayButton.heightAnchor.constraint(equalToConstant: Layout.applePayButtonHeight)
        ])
    }
}
