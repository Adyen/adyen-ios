//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
#if canImport(AdyenUI)
    @_spi(AdyenInternal) import AdyenUI
#endif
import UIKit

/// A view representing a FormCoBadged card Item.
internal final class FormCoBadgedCardItemView: FormItemView<FormCoBadgedCardItem> {

    private enum Constants {
        static let viewHeight: CGFloat = 220
    }

    /// The card brand selection title label item.
    internal lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(style: item.style.title)
        titleLabel.text = item.title
        titleLabel.accessibilityLabel = ViewIdentifierBuilder.build(
            scopeInstance: self,
            postfix: ViewIdentifierBuilder.build(scopeInstance: self, postfix: "cardBadgedCardSelectionTitleLabelItem")
        )
        return titleLabel
    }()

    ///  The card brand selection subtitle label item.
    internal lazy var subtitleLabel: UILabel = {
        let subtitleLabel = UILabel(style: item.style.subtitle)
        subtitleLabel.text = item.subtitle
        subtitleLabel.numberOfLines = 0
        subtitleLabel.lineBreakMode = .byWordWrapping
        subtitleLabel.accessibilityLabel = ViewIdentifierBuilder.build(
            scopeInstance: self,
            postfix: ViewIdentifierBuilder.build(scopeInstance: self, postfix: "cardBadgedCardSelectionSubtitleLabelItem")
        )
        return subtitleLabel
    }()

    /// The brand type list item view
    internal lazy var brandsListView: [SelectableFormItemView] = {
        item.selectableFormItems.map { item in
            SelectableFormItemView(item: item)
        }
    }()

    /// Initializes the CoBadged card Item view.
    internal required init(item: FormCoBadgedCardItem) {
        super.init(item: item)
        backgroundColor = item.style.backgroundColor
        addSubview(contentStackView)

        accessibilityIdentifier = item.identifier
        accessibilityLabel = item.accessibilityLabel
        isAccessibilityElement = true

        preservesSuperviewLayoutMargins = true

        observe(item.$selectableFormItems) { [weak self] selectableItem in
            guard let self else { return }

            self.removeBrandsListFromView()

            self.brandsListView = selectableItem.map { item in SelectableFormItemView(item: item) }
            self.brandsListView.forEach { self.contentStackView.addArrangedSubview($0) }
            self.configureConstraints()
        }
    }

    // MARK: - Content StackView

    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        brandsListView.forEach { stackView.addArrangedSubview($0) }
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.preservesSuperviewLayoutMargins = true
        stackView.layoutMargins = .init(top: 14, left: 0, bottom: 16, right: 0)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.setContentHuggingPriority(.required, for: .vertical)
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fillProportionally

        return stackView
    }()

    private func removeBrandsListFromView() {
        brandsListView.forEach { view in
            contentStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }

    // MARK: - Layout

    private func configureConstraints() {
        let constraints = [
            contentStackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            contentStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            subtitleLabel.heightAnchor.constraint(equalToConstant: 48),
            heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.viewHeight)
        ]
        NSLayoutConstraint.activate(constraints)
        brandsListView.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        for view in brandsListView {
            NSLayoutConstraint.activate([
                view.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor)
            ])
        }
    }
}
