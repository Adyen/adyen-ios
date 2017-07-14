//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// The CheckoutButton class provides a large, tinted button to complete a checkout.
@IBDesignable
internal class CheckoutButton: UIControl {
    
    internal override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        layer.cornerRadius = 4.0
        
        accessibilityTraits = UIAccessibilityTraitButton
        
        addSubview(titleLabel)
        addSubview(activityIndicatorView)
        
        configureConstraints()
        updateAppearance()
        
        isAccessibilityElement = true
        accessibilityTraits = UIAccessibilityTraitButton
    }
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        
        backgroundColor = tintColor
    }
    
    // MARK: Layout
    
    private func configureConstraints() {
        let constraints = [
            titleLabelTopAnchorConstraint,
            titleLabelBottomAnchorConstraint,
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private lazy var titleLabelTopAnchorConstraint: NSLayoutConstraint = {
        self.titleLabel.topAnchor.constraint(equalTo: self.topAnchor)
    }()
    
    private lazy var titleLabelBottomAnchorConstraint: NSLayoutConstraint = {
        self.titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor)
    }()
    
    // MARK: Appearance Configuration
    
    internal var appearanceConfiguration: AppearanceConfiguration = .default {
        didSet {
            updateAppearance()
        }
    }
    
    private func updateAppearance() {
        tintColor = appearanceConfiguration.tintColor
        
        let cornerRadius = appearanceConfiguration.checkoutButtonCornerRadius
        clipsToBounds = cornerRadius > 0.0
        layer.cornerRadius = cornerRadius
        
        let titleLabelEdgeInsets = appearanceConfiguration.checkoutButtonTitleEdgeInsets ?? .zero
        titleLabelTopAnchorConstraint.constant = titleLabelEdgeInsets.top
        titleLabelBottomAnchorConstraint.constant = -titleLabelEdgeInsets.bottom
        
        updateTitle()
    }
    
    // MARK: Title Label
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.isUserInteractionEnabled = false
        titleLabel.isAccessibilityElement = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return titleLabel
    }()
    
    @IBInspectable
    internal var title: String? {
        didSet {
            updateTitle()
            
            accessibilityLabel = title
        }
    }
    
    private func updateTitle() {
        let attributedTitle = NSAttributedString(string: title ?? "",
                                                 attributes: appearanceConfiguration.checkoutButtonTitleTextAttributes)
        titleLabel.attributedText = attributedTitle
    }
    
    // MARK: Enabled State
    
    override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1.0 : 0.5
            
            if isEnabled {
                accessibilityTraits = UIAccessibilityTraitButton
            } else {
                accessibilityTraits = UIAccessibilityTraitButton | UIAccessibilityTraitNotEnabled
            }
        }
    }
    
    // MARK: Highlighted State
    
    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? 0.75 : 1.0
        }
    }
    
    // MARK: Loading State
    
    /// Boolean value indicating whether the button should display an activity indicator.
    internal var isLoading: Bool = false {
        didSet {
            titleLabel.isHidden = isLoading
            
            if isLoading {
                activityIndicatorView.startAnimating()
            } else {
                activityIndicatorView.stopAnimating()
            }
            
            isUserInteractionEnabled = !isLoading
        }
    }
    
    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .white)
        activityIndicatorView.isUserInteractionEnabled = false
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        return activityIndicatorView
    }()
    
}
