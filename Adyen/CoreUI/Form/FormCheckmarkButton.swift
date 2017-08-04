//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Provides a checkmark to be used in a `FormView`.
internal class FormCheckmarkButton: UIControl {
    
    internal init() {
        super.init(frame: .zero)
        
        addSubview(titleLabel)
        addSubview(imageView)
        
        configureConstraints()
        
        isAccessibilityElement = true
        accessibilityTraits = UIAccessibilityTraitButton
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    private func configureConstraints() {
        let constraints = [
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
            
            imageView.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 20.0),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 20.0),
            imageView.heightAnchor.constraint(equalToConstant: 20.0)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: - Title Label
    
    internal var title: String? {
        didSet {
            titleLabel.text = title
            
            accessibilityLabel = title
        }
    }
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 13.0)
        titleLabel.textColor = UIColor.checkoutGray
        titleLabel.numberOfLines = 0
        titleLabel.isAccessibilityElement = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return titleLabel
    }()
    
    // MARK: - Image View
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = self.image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private let image = UIImage.bundleImage("checkbox_inactive")
    
    private let selectedImage = UIImage.bundleImage("checkbox_active")
    
    // MARK: - Interaction
    
    override var isHighlighted: Bool {
        didSet {
            imageView.alpha = isHighlighted ? 0.5 : 1.0
        }
    }
    
    override var isSelected: Bool {
        didSet {
            imageView.image = isSelected ? selectedImage : image
            
            if isSelected {
                accessibilityTraits = UIAccessibilityTraitButton | UIAccessibilityTraitSelected
            } else {
                accessibilityTraits = UIAccessibilityTraitButton
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isSelected = !isSelected
        
        super.touchesEnded(touches, with: event)
    }
    
}
