//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

internal final class ListHeaderView: UIView {
    
    /// The list section header style.
    internal let style: ListSectionHeaderStyle
    
    internal let trailingButtonTitle: String?
    
    internal var onTrailingButtonTap: (() -> Void)?
    
    internal init(title: String,
                  trailingButtonTitle: String? = nil,
                  style: ListSectionHeaderStyle) {
        self.title = title
        self.trailingButtonTitle = trailingButtonTitle
        self.style = style
        
        super.init(frame: .zero)
        
        backgroundColor = style.backgroundColor
        addSubview(stackView)
        
        configureConstraints()
    }
    
    @available(*, unavailable)
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    private func configureConstraints() {
        layoutMargins = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 6.0, right: 16.0)
        stackView.adyen.anchor(inside: self.layoutMarginsGuide)
    }
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, trailingButton].compactMap { $0 })
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 8.0

        return stackView
    }()
    
    // MARK: - Trailing Button
    
    private lazy var trailingButton: UIButton? = {
        guard let title = trailingButtonTitle else { return nil }
        let button = UIButton(style: style.trailingButton)
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: #selector(didTapTrailingButton), for: .touchUpInside)
        button.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "trailingButton")
        button.preservesSuperviewLayoutMargins = true
        
        return button
    }()
    
    @objc private func didTapTrailingButton() {
        onTrailingButtonTap?()
    }
    
    // MARK: - Title Label
    
    private let title: String
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(style: style.title)
        titleLabel.text = title.uppercased()
        titleLabel.accessibilityTraits = .header
        titleLabel.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: "Adyen.ListHeaderView.\(title)",
                                                                         postfix: "titleLabel")
        
        return titleLabel
    }()
    
}
