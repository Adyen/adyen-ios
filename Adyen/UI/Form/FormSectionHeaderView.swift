//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import UIKit

/// :nodoc:
public class FormSectionHeaderView: UIView {
    public init() {
        super.init(frame: .zero)
        
        addSubview(titleLabel)
        addSubview(separatorView)
        
        configureConstraints()
        
        isAccessibilityElement = true
        accessibilityTraits = UIAccessibilityTraits.header
    }
    
    public required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    
    public var title: String? {
        didSet {
            guard let title = title else {
                return
            }
            
            let attributedTitle = NSAttributedString(string: title, attributes: Appearance.shared.formAttributes.sectionTitleAttributes)
            titleLabel.attributedText = attributedTitle
            dynamicTypeController.observeDynamicType(for: titleLabel, withTextAttributes: Appearance.shared.formAttributes.sectionTitleAttributes, textStyle: .body)
            accessibilityLabel = title
        }
    }
    
    // MARK: - Private
    
    private let dynamicTypeController = DynamicTypeController()
    
    private func configureConstraints() {
        let separatorHeight = 1.0 / UIScreen.main.scale
        
        let constraints = [
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            separatorView.heightAnchor.constraint(equalToConstant: separatorHeight),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -20),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 40),
            separatorView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.isAccessibilityElement = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return titleLabel
    }()
    
    private lazy var separatorView: UIView = {
        let separator = UIView(frame: .zero)
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = Appearance.shared.formAttributes.separatorColor
        
        return separator
    }()
}
