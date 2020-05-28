//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

internal final class ListHeaderView: UIView {
    
    /// The list section header style.
    internal let style: ListSectionHeaderStyle
    
    internal init(title: String, style: ListSectionHeaderStyle) {
        self.title = title
        self.style = style
        
        super.init(frame: .zero)
        
        backgroundColor = style.backgroundColor
        addSubview(titleLabel)
        
        configureConstraints()
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    private func configureConstraints() {
        layoutMargins = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 6.0, right: 16.0)
        
        let constraints = [
            titleLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: - Title Label
    
    private let title: String
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = title.uppercased()
        titleLabel.textColor = style.title.color
        titleLabel.font = style.title.font
        titleLabel.textAlignment = style.title.textAlignment
        titleLabel.backgroundColor = style.title.backgroundColor
        titleLabel.accessibilityTraits = .header
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: "Adyen.ListHeaderView.\(title)",
                                                                         postfix: "titleLabel")
        
        return titleLabel
    }()
    
}
