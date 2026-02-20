//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import PassKit
import UIKit

internal struct PaymentMethodListHeaderViewModel {
    let amount: String
    let subtitle: String
    let showApplePayButton: Bool
    let onApplePayTap: (() -> Void)?
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
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var applePayButton: PKPaymentButton = {
        let button = PKPaymentButton(paymentButtonType: .plain, paymentButtonStyle: .black)
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
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
        addSubview(stackView)
        addSubview(applePayButton)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            applePayButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 16),
            applePayButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            applePayButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            applePayButton.heightAnchor.constraint(equalToConstant: 48),
            applePayButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
}
