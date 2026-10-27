//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// A rounded submit button used to submit details.
@_spi(AdyenInternal)
public final class SubmitButton: UIControl {
    private enum Constants {
        static let minimumHeight: CGFloat = 50
        static let verticalPadding: CGFloat = 12
        static let horizontalPadding: CGFloat = 16
    }
    
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
        
        backgroundColor = style.backgroundColor
        self.adyen.round(using: style.cornerRounding)
        
        configureConstraints()
    }
    
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Background View
    
    internal lazy var backgroundView: BackgroundView = {
        let backgroundView = BackgroundView(
            cornerRounding: style.cornerRounding,
            borderColor: style.borderColor,
            borderWidth: style.borderWidth,
            color: style.backgroundColor
        )
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
    
    internal lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(style: style.title)
        titleLabel.isAccessibilityElement = false
        titleLabel.numberOfLines = 0
        
        return titleLabel
    }()
    
    override public var accessibilityIdentifier: String? {
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
            activityIndicatorView.isAnimating
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
        let activityIndicatorView = UIActivityIndicatorView(style: activityIndicatorStyle)
        activityIndicatorView.color = titleLabel.textColor
        activityIndicatorView.backgroundColor = .clear
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "activityIndicator")
        return activityIndicatorView
    }()
    
    private var activityIndicatorStyle: UIActivityIndicatorView.Style {
        if #available(iOS 13.0, *) {
            return .medium
        } else {
            return .white
        }
    }
    
    // MARK: - Layout
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        self.adyen.round(using: style.cornerRounding)
    }

    override public var canBecomeFocused: Bool {
        isEnabled && isUserInteractionEnabled && !isHidden && alpha > 0
    }

    override public func accessibilityActivate() -> Bool {
        guard canBecomeFocused else { return false }
        sendActions(for: .touchUpInside)
        return true
    }

    override public func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        let selectionPresses = presses.filter { $0.type == .select }
        if !selectionPresses.isEmpty {
            accessibilityActivate()
        }
        let remainingPresses = presses.subtracting(selectionPresses)
        if !remainingPresses.isEmpty {
            super.pressesEnded(remainingPresses, with: event)
        }
    }
    
    private func configureConstraints() {
        backgroundView.adyen.anchor(inside: self)
        
        let heightConstraint = heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.minimumHeight)
        
        let labelConstraints = [
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.verticalPadding),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.horizontalPadding),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.horizontalPadding),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.verticalPadding)
        ]
        
        let spinnerConstraints = [
            activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ]
        
        let allConstraints = labelConstraints + spinnerConstraints + [heightConstraint]
        
        NSLayoutConstraint.activate(allConstraints)
    }
    
    // MARK: - State
    
    override public var isHighlighted: Bool {
        didSet {
            backgroundView.isHighlighted = isHighlighted
        }
    }
    
}

extension SubmitButton {
    
    internal final class BackgroundView: UIView {
        
        private let color: UIColor
        private let rounding: CornerRounding
        
        fileprivate init(
            cornerRounding: CornerRounding,
            borderColor: UIColor?,
            borderWidth: CGFloat,
            color: UIColor
        ) {
            self.color = color
            self.rounding = cornerRounding
            super.init(frame: .zero)
            
            backgroundColor = color
            layer.borderColor = borderColor?.cgColor
            layer.borderWidth = borderWidth
            isUserInteractionEnabled = false
            
            layer.masksToBounds = true
        }
        
        @available(*, unavailable)
        internal required init?(coder aDecoder: NSCoder) {
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
        
        override internal func layoutSubviews() {
            super.layoutSubviews()
            self.adyen.round(using: rounding)
        }
        
    }
    
}
