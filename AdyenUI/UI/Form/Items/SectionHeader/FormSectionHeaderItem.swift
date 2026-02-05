//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

package final class FormSectionHeaderItem<ContentItem: FormItem>: FormItem {

    package var isHidden: AdyenObservable<Bool> = AdyenObservable(false)
    package var subitems: [FormItem] {
        [content]
    }

    package var identifier: String?
    package let title: String
    package let subtitle: String?
    package let content: ContentItem

    package init(
        title: String,
        subtitle: String? = nil,
        content: ContentItem,
        identifier: String? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.content = content
        self.identifier = identifier
    }

    package func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        let contentView = content.build(with: builder)
        let view = FormSectionHeaderItemView(
            title: title,
            subtitle: subtitle,
            contentView: contentView,
            theme: builder.theme
        )
        view.accessibilityIdentifier = identifier
        return view
    }
}

// MARK: - FormSectionHeaderItemView

internal final class FormSectionHeaderItemView: UIView, AnyFormItemView {

    internal var childItemViews: [AnyFormItemView] = []
    private let theme: AdyenTheme

    // MARK: - Subviews

    private lazy var headerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = AdyenUIConstants.stackViewSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.apply(theme.elements.labels.subtitle)
        label.numberOfLines = 0
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.apply(theme.elements.labels.subheadline)
        label.textColor = theme.colors.textSecondary
        label.numberOfLines = 0
        return label
    }()

    private lazy var contentContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Initialization

    internal init(
        title: String,
        subtitle: String?,
        contentView: AnyFormItemView,
        theme: AdyenTheme
    ) {
        self.theme = theme
        super.init(frame: .zero)

        setupView(title: title, subtitle: subtitle, contentView: contentView)
    }

    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupView(title: String, subtitle: String?, contentView: AnyFormItemView) {
        configureContent(title: title, subtitle: subtitle, contentView: contentView)
        setupConstraints()
    }

    private func configureContent(title: String, subtitle: String?, contentView: AnyFormItemView) {
        preservesSuperviewLayoutMargins = true

        titleLabel.text = title
        subtitleLabel.text = subtitle
        subtitleLabel.isHidden = subtitle == nil

        contentContainer.addSubview(contentView)
        (contentView as UIView).adyen.anchor(inside: contentContainer)
        childItemViews = [contentView]

        addSubview(headerStackView)
        addSubview(contentContainer)
    }

    private func setupConstraints() {
        // Header aligned with form margins
        NSLayoutConstraint.activate([
            headerStackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            headerStackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            headerStackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor)
        ])

        // Content extends full width (wrapped content handles its own margins)
        NSLayoutConstraint.activate([
            contentContainer.topAnchor.constraint(
                equalTo: headerStackView.bottomAnchor, constant: AdyenUIConstants.stackViewSpacing
            ),
            contentContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    // MARK: - AnyFormItemView

    internal func reset() {
        childItemViews.forEach { $0.reset() }
    }
}

// MARK: - Convenience Extension

extension FormItem {

    package func withSectionHeader(title: String, subtitle: String? = nil) -> FormSectionHeaderItem<Self> {
        FormSectionHeaderItem(title: title, subtitle: subtitle, content: self, identifier: nil)
    }
}
