//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// A rounded submit button used to submit details.
/// :nodoc:
public final class SubmitButton: UIControl {
    
    /// :nodoc:
    private let style: ButtonStyle
    
    /// Initializes the submit button.
    ///
    /// - Parameter style: The `SubmitButton` UI style.
    public init(style: ButtonStyle) {
        self.style = style
        super.init(frame: .zero)
        
        isAccessibilityElement = true
        accessibilityTraits = .button
        
        addSubview(backgroundView)
        addSubview(activityIndicatorView)
        addSubview(titleLabel)
        
        layer.cornerRadius = style.cornerRadius
        
        backgroundColor = style.backgroundColor
        
        configureConstraints()
    }
    
    /// :nodoc:
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Background View
    
    private lazy var backgroundView: BackgroundView = {
        let backgroundView = BackgroundView(cornerRadius: style.cornerRadius, color: style.backgroundColor)
        backgroundView.backgroundColor = style.backgroundColor
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        return backgroundView
    }()
    
    // MARK: - Title Label
    
    /// The title of the submit button.
    public var title: String? {
        didSet {
            titleLabel.text = title
            accessibilityLabel = title
        }
    }
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = style.title.font
        titleLabel.textColor = style.title.color
        titleLabel.backgroundColor = style.title.backgroundColor
        titleLabel.textAlignment = style.title.textAlignment
        titleLabel.isAccessibilityElement = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return titleLabel
    }()
    
    /// :nodoc:
    public override var accessibilityIdentifier: String? {
        didSet {
            titleLabel.accessibilityIdentifier = accessibilityIdentifier.map {
                ViewIdentifierBuilder.build(scopeInstance: $0, postfix: "titleLabel")
            }
        }
    }
    
    // MARK: - Activity Indicator View
    
    /// Boolean value indicating whether an activity indicator should be shown.
    public var showsActivityIndicator: Bool {
        get {
            return activityIndicatorView.isAnimating
        }
        
        set {
            if newValue {
                activityIndicatorView.startAnimating()
                titleLabel.alpha = 0.0
                isEnabled = false
            } else {
                activityIndicatorView.stopAnimating()
                titleLabel.alpha = 1.0
                isEnabled = true
            }
        }
    }
    
    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .white)
        activityIndicatorView.color = titleLabel.textColor
        activityIndicatorView.backgroundColor = .clear
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        return activityIndicatorView
    }()
    
    // MARK: - Layout
    
    private func configureConstraints() {
        let constraints = [
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            titleLabel.topAnchor.constraint(greaterThanOrEqualTo: layoutMarginsGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: layoutMarginsGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.trailingAnchor),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.bottomAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            heightAnchor.constraint(greaterThanOrEqualToConstant: 50.0)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: - State
    
    /// :nodoc:
    public override var isHighlighted: Bool {
        didSet {
            backgroundView.isHighlighted = isHighlighted
        }
    }
    
}

private extension SubmitButton {
    
    class BackgroundView: UIView {
        
        private let color: UIColor
        
        fileprivate init(cornerRadius: CGFloat, color: UIColor) {
            self.color = color
            super.init(frame: .zero)
            
            backgroundColor = color
            isUserInteractionEnabled = false
            
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = true
        }
        
        fileprivate required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // MARK: - Background Color
        
        fileprivate var isHighlighted = false {
            didSet {
                updateBackgroundColor()
                
                if !isHighlighted {
                    performTransition()
                }
            }
        }
        
        private func updateBackgroundColor() {
            var backgroundColor = color
            
            if isHighlighted {
                backgroundColor = color.withBrightnessMultiple(0.75)
            }
            
            self.backgroundColor = backgroundColor
        }
        
        private func performTransition() {
            let transition = CATransition()
            transition.duration = 0.2
            transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            layer.add(transition, forKey: nil)
        }
        
    }
    
}
