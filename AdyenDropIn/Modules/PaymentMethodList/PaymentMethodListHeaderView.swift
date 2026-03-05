//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import PassKit
import UIKit

internal struct PaymentMethodListHeaderViewModel {
    internal let amount: String
    internal let subtitle: String
    internal let showApplePayButton: Bool
    internal let onApplePayTap: (() -> Void)?
}

internal final class PaymentMethodListHeaderView: UIView {
    
    // MARK: - UI Elements
    
    private lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 1
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var applePayButton: PKPaymentButton = {
        let buttonStyle: PKPaymentButtonStyle
        if #available(iOS 14.0, *) {
            buttonStyle = .automatic
        } else {
            buttonStyle = .black
        }
        let button = PKPaymentButton(paymentButtonType: .plain, paymentButtonStyle: buttonStyle)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(applePayButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [amountLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Initializers
    
    override internal init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    private var onApplePayTap: (() -> Void)?
    
    // MARK: - Configuration
    
    internal func configure(with viewModel: PaymentMethodListHeaderViewModel) {
        amountLabel.text = viewModel.amount
        subtitleLabel.text = viewModel.subtitle
        onApplePayTap = viewModel.onApplePayTap
        applePayButton.isHidden = !viewModel.showApplePayButton
    }
    
    // MARK: - Actions
    
    @objc private func applePayButtonTapped() {
        onApplePayTap?()
    }
    
    // MARK: - Private
    
    private func setupView() {
        layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        addSubview(stackView)
        addSubview(applePayButton)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            
            applePayButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 24),
            applePayButton.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            applePayButton.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            applePayButton.heightAnchor.constraint(equalToConstant: 48),
            applePayButton.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ])
    }
}
