//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

#if canImport(AdyenUI)
    import AdyenUI
#endif
import UIKit

internal final class PaymentMethodSectionView: UIView {

    private enum Layout {
        static let headerLabelBottomMargin: CGFloat = 16
    }

    // MARK: - UI Elements
    
    private lazy var containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 0
        return stackView
    }()
    
    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.apply(section.theme.elements.labels.subheadlineEmphasized)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.adjustsFontForContentSizeCategory = true
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.accessibilityTraits = .header
        return label
    }()

    private lazy var trailingHeaderButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = section.theme.elements.labels.body.font
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.setTitleColor(section.theme.colors.highlight, for: .normal)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.addTarget(self, action: #selector(didTapTrailingHeaderButton), for: .touchUpInside)
        return button
    }()

    private lazy var headerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [headerLabel, trailingHeaderButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        return stackView
    }()

    private lazy var itemsContainerView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()

    // MARK: - Properties

    private let section: PaymentMethodSection

    // MARK: - Initializers
    
    internal init(section: PaymentMethodSection) {
        self.section = section
        super.init(frame: .zero)
        setupView()
        configure()
    }
    
    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private

    private func setupView() {
        accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "sectionView")
        addSubview(containerStackView)
        
        containerStackView.addArrangedSubview(headerStackView)
        containerStackView.addArrangedSubview(itemsContainerView)
        containerStackView.setCustomSpacing(Layout.headerLabelBottomMargin, after: headerStackView)

        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: topAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func configure() {
        clearItems()

        guard !section.items.isEmpty else {
            isHidden = true
            return
        }

        isHidden = false
        configureHeaderLabel(with: section.headerTitle)
        configureTrailingHeaderButton(with: section.headerTrailingButton)
        headerStackView.isHidden = headerLabel.isHidden && trailingHeaderButton.isHidden
        populateSection(with: section.items)
    }

    private func configureHeaderLabel(with title: String?) {
        headerLabel.isHidden = title == nil
        headerLabel.text = title?.localizedCapitalized
        headerLabel.accessibilityLabel = title
        headerLabel.accessibilityIdentifier = title.map {
            ViewIdentifierBuilder.build(scopeInstance: self, postfix: $0)
        }
    }

    private func configureTrailingHeaderButton(with configuration: PaymentMethodSection.HeaderTrailingButton?) {
        trailingHeaderButton.isHidden = configuration == nil
        trailingHeaderButton.setTitle(configuration?.title, for: .normal)
        trailingHeaderButton.accessibilityIdentifier = configuration.map { _ in
            ViewIdentifierBuilder.build(scopeInstance: self, postfix: "headerTrailingButton")
        }
    }

    @objc private func didTapTrailingHeaderButton() {
        section.headerTrailingButton?.handler()
    }

    private func clearItems() {
        itemsContainerView.arrangedSubviews.forEach { view in
            itemsContainerView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
    
    private func populateSection(with items: [PaymentMethodItem]) {
        items.forEach { item in
            let itemView = PaymentMethodItemView(item: item)
            itemsContainerView.addArrangedSubview(itemView)
        }
    }
}
