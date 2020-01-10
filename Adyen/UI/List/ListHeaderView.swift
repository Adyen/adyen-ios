//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// Indicates the `ListHeaderView` UI style.
public struct ListHeaderViewStyle: ViewStyle {
    
    /// Indicates the title text UI style.
    public var title: TextStyle = TextStyle(font: .systemFont(ofSize: 13.0, weight: .medium),
                                            color: .componentSecondaryLabel,
                                            textAlignment: .natural)
    
    /// :nodoc:
    public var backgroundColor: UIColor = .componentBackground
    
    /// Initializes the list header style
    ///
    /// - Parameter title: The list header title text style.
    public init(title: TextStyle) {
        self.title = title
    }
    
    /// Initializes the list header style with default style.
    public init() {}
    
}

internal final class ListHeaderView: UIView {
    
    /// Indicates the `ListHeaderView` UI styling.
    internal let style: ListHeaderViewStyle
    
    internal init(title: String, style: ListHeaderViewStyle) {
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
