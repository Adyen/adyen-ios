//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// A header shown at the top of a picker search screen, displaying a title and an optional subtitle.
internal final class FormPickerHeaderView: UIView {

    private enum Layout {
        static let stackSpacing: CGFloat = 4
    }

    // MARK: - Subviews

    internal lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = header.title
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    internal lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = header.subtitle
        label.isHidden = header.subtitle?.isEmpty ?? true
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = Layout.stackSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    // MARK: - Properties

    private let header: FormPickerConfiguration.Header
    private let theme: CheckoutTheme

    // MARK: - Initializers

    internal init?(header: FormPickerConfiguration.Header, theme: CheckoutTheme) {
        guard !header.title.isEmpty else {
            return nil
        }

        self.header = header
        self.theme = theme
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

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ])

        applyTheme()
    }

    private func applyTheme() {
        titleLabel.apply(theme.elements.labels.title)

        subtitleLabel.apply(theme.elements.labels.body)
        subtitleLabel.textColor = theme.colors.textSecondary
    }
}
