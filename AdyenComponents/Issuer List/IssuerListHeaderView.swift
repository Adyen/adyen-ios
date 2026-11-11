//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenUI
import UIKit

/// The header of the issuer list, showing a title, a description and a validation error.
internal final class IssuerListHeaderView: UIView {

    private enum Layout {
        static let titleToDescriptionSpacing: CGFloat = 8
        static let descriptionToErrorSpacing: CGFloat = 16
    }

    /// Whether the validation error is shown.
    internal var showsError: Bool {
        get { !errorLabel.isHidden }
        set {
            guard newValue != showsError else { return }
            errorLabel.isHidden = !newValue
            if newValue {
                UIAccessibility.post(notification: .announcement, argument: errorLabel.text)
            }
        }
    }

    // MARK: - Subviews

    internal lazy var titleLabel: AdyenLabel = {
        let label = makeLabel(
            text: title,
            style: theme.elements.labels.title,
            postfix: "titleLabel"
        )
        label.accessibilityTraits = .header
        return label
    }()

    internal lazy var descriptionLabel: AdyenLabel = makeLabel(
        text: descriptionText,
        style: theme.elements.labels.body.color(theme.colors.textSecondary),
        postfix: "descriptionLabel"
    )

    internal lazy var errorLabel: AdyenLabel = {
        let label = makeLabel(
            text: errorMessage,
            style: theme.elements.labels.body.color(theme.colors.destructive),
            postfix: "errorLabel"
        )
        label.isHidden = true
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel, errorLabel])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.setCustomSpacing(Layout.titleToDescriptionSpacing, after: titleLabel)
        stackView.setCustomSpacing(Layout.descriptionToErrorSpacing, after: descriptionLabel)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    // MARK: - Properties

    private let title: String
    private let descriptionText: String
    private let errorMessage: String
    private let theme: CheckoutTheme
    private let identifierScope: String

    // MARK: - Initializers

    /// Initializes the header view.
    ///
    /// - Parameters:
    ///   - title: The title of the header.
    ///   - description: The description shown below the title.
    ///   - errorMessage: The message shown when ``showsError`` is `true`.
    ///   - theme: The theme to use for styling.
    ///   - identifierScope: The scope used to build the accessibility identifiers.
    internal init(
        title: String,
        description: String,
        errorMessage: String,
        theme: CheckoutTheme,
        identifierScope: String
    ) {
        self.title = title
        self.descriptionText = description
        self.errorMessage = errorMessage
        self.theme = theme
        self.identifierScope = identifierScope
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
        stackView.adyen.anchor(inside: layoutMarginsGuide)
    }

    private func makeLabel(text: String, style: AdyenLabelStyle, postfix: String) -> AdyenLabel {
        let label = AdyenLabel()
        label.text = text
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        label.apply(style)
        label.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: identifierScope, postfix: postfix)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
}
