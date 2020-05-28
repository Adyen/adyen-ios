//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// A view representing a header item.
internal final class FormHeaderItemView: FormItemView<FormHeaderItem> {
    
    /// Initializes the header item view.
    ///
    /// - Parameter item: The item represented by the view.
    internal required init(item: FormHeaderItem) {
        super.init(item: item)
        
        addSubview(titleLabel)
        
        layoutMargins.bottom = 18.0
        
        backgroundColor = item.style.backgroundColor
        
        configureConstraints()
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Title Label
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = item.style.title.font
        titleLabel.textColor = item.style.title.color
        titleLabel.textAlignment = item.style.title.textAlignment
        titleLabel.backgroundColor = item.style.title.backgroundColor
        titleLabel.text = item.title
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.accessibilityIdentifier = item.identifier.map { ViewIdentifierBuilder.build(scopeInstance: $0, postfix: "titleLabel") }
        
        return titleLabel
    }()
    
    // MARK: - Layout
    
    private func configureConstraints() {
        let constraints = [
            titleLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: layoutMarginsGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
}
