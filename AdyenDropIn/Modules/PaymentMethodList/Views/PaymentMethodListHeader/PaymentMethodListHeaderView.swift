//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

#if canImport(AdyenUI)
    import AdyenUI
#endif
import UIKit

internal final class PaymentMethodListHeaderView: UIView {

    private enum Layout {
        static let subtitleBottomMargin: CGFloat = 24
        static let labelMargins = NSDirectionalEdgeInsets(
            top: 0,
            leading: PaymentMethodItemView.contentHorizontalInset,
            bottom: 0,
            trailing: PaymentMethodItemView.contentHorizontalInset
        )
    }

    // MARK: - UI Elements
    
    private lazy var amountLabel: UILabel = {
        let label = AdyenLabel()
        label.text = viewModel.title
        label.numberOfLines = 1
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = AdyenLabel()
        label.text = viewModel.subtitle
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var labelsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [amountLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        // The labels are inset like the item content, so that they line up with the item titles
        // rather than with the edges the item backgrounds and the Apple Pay button reach out to.
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = Layout.labelMargins
        return stackView
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                labelsStackView
            ]
        )
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .fill
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
    
    // MARK: - Private
    
    private func setupView() {
        layoutMargins = .zero
        accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "headerView")

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ])

        setupApplePayView()
        applyTheme()
    }

    private func setupApplePayView() {
        guard let applePayView = viewModel.applePayView else { return }

        applePayView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(applePayView)
        stackView.setCustomSpacing(Layout.subtitleBottomMargin, after: labelsStackView)
    }

    private func applyTheme() {
        // Amount Label
        amountLabel.apply(viewModel.theme.elements.labels.title)

        // Subtitle Label
        subtitleLabel.apply(viewModel.theme.elements.labels.body)
        subtitleLabel.textColor = viewModel.theme.colors.textSecondary
    }
}
