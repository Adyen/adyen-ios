//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

internal final class PaymentMethodSectionView: UIView {
    
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
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .natural
        label.accessibilityTraits = .header
        return label
    }()
    
    private lazy var itemsContainerView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12
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
        addSubview(containerStackView)
        
        containerStackView.addArrangedSubview(headerLabel)
        containerStackView.addArrangedSubview(itemsContainerView)
        containerStackView.setCustomSpacing(16, after: headerLabel)

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

        if let headerTitle = section.headerTitle {
            configureHeader(with: headerTitle)
            headerLabel.isHidden = false
        } else {
            headerLabel.isHidden = true
        }

        populateItems(section.items)
    }

    private func configureHeader(with title: String) {
        headerLabel.text = title.localizedCapitalized
        headerLabel.accessibilityLabel = title
        headerLabel.accessibilityIdentifier = "Adyen.PaymentMethodList.sectionHeader.\(title)"
    }
    
    private func clearItems() {
        itemsContainerView.arrangedSubviews.forEach { view in
            itemsContainerView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
    
    private func populateItems(_ items: [PaymentMethodItem]) {
        items.forEach { item in
            let itemView = PaymentMethodItemView(item: item)
            itemsContainerView.addArrangedSubview(itemView)
        }
    }
}
