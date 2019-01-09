//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import UIKit

internal final class ListHeaderView: UIView {
    
    internal init(title: String, attributes: [NSAttributedString.Key: Any]) {
        super.init(frame: .zero)
        
        titleLabel.attributedText = NSAttributedString(string: title, attributes: attributes)
        addSubview(titleLabel)
        
        dynamicTypeController.observeDynamicType(for: titleLabel, withTextAttributes: attributes, textStyle: .headline)
        
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
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return titleLabel
    }()
    
    // MARK: - Other
    
    private lazy var dynamicTypeController = DynamicTypeController()
    
}
