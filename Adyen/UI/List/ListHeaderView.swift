//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

internal final class ListHeaderView: UITableViewHeaderFooterView {
    
    internal static let reuseIdentifier = String(describing: ListHeaderView.self)
    
    internal var onTrailingButtonTap: (() -> Void)?
    
    override internal init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        contentView.addSubview(stackView)
        let backgroundView = UIView()
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundView = backgroundView
        
        configureConstraints()
    }
    
    @available(*, unavailable)
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal var headerItem: ListSectionHeader? {
        didSet {
            updateItem()
        }
    }
    
    private func updateItem() {
        guard let item = headerItem else { return }
        backgroundView?.backgroundColor = item.style.backgroundColor
        contentView.backgroundColor = item.style.backgroundColor
        titleLabel.adyen.apply(item.style.title)
        titleLabel.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: "Adyen.ListHeaderView.\(item.title)",
                                                                         postfix: "titleLabel")
        titleLabel.text = item.title.uppercased()
        
        trailingButton.adyen.apply(item.style.trailingButton)
        
        updateTrailingButtonTitle(with: item)
    }
    
    internal var isEditing: Bool = false {
        didSet {
            updateTrailingButtonTitle(with: headerItem)
        }
    }
    
    private func updateTrailingButtonTitle(with item: ListSectionHeader?) {
        guard let item = headerItem else { return }
        let localizedEdit = Bundle.Adyen.localizedEditCopy
        let localizedDone = Bundle.Adyen.localizedDoneCopy
        let localizedTitle = isEditing ? localizedDone : localizedEdit
        switch item.editingStyle {
        case .delete:
            trailingButton.setTitle(localizedTitle, for: .normal)
            trailingButton.isHidden = false
        case .none:
            trailingButton.isHidden = true
        }
    }
    
    // MARK: - Layout
    
    private func configureConstraints() {
        layoutMargins = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 6.0, right: 16.0)
        stackView.adyen.anchor(inside: self.layoutMarginsGuide)
        backgroundView?.adyen.anchor(inside: self)
    }
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, trailingButton])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 8.0

        return stackView
    }()
    
    // MARK: - Trailing Button
    
    internal lazy var trailingButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(didTapTrailingButton), for: .touchUpInside)
        button.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "trailingButton")
        button.preservesSuperviewLayoutMargins = true
        
        return button
    }()
    
    @objc private func didTapTrailingButton() {
        onTrailingButtonTap?()
    }
    
    // MARK: - Title Label
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.accessibilityTraits = .header
        
        return titleLabel
    }()
    
}
