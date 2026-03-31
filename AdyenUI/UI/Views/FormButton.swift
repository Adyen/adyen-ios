//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

/// A rounded button for use in forms.
@_spi(AdyenInternal)
public final class FormButton: UIControl {
    private enum Constants {
        static let leadingImageWidth: CGFloat = 24
        static let leadingImageHeight: CGFloat = 24
    }

    private var style: ButtonStyle
    private var buttonStyle: AdyenButtonStyle = .primary(for: .default)

    /// Initializes the form button.
    ///
    /// - Parameter style: The `FormButton` UI style.
    public init(style: ButtonStyle) {
        self.style = style
        super.init(frame: .zero)
        
        isAccessibilityElement = true
        accessibilityTraits = .button
        
        addSubview(backgroundView)
        addSubview(activityIndicatorView)
        addSubview(contentStackView)

        backgroundColor = style.backgroundColor
        self.adyen.round(using: style.cornerRounding)

        configureConstraints()
    }

    /// Initializes the form button.
    /// - Parameter buttonStyle: The  new `FormButton` UI style.
    /// - Parameter style: The  old `FormButton` UI style.
    public init(
        theme: CheckoutTheme,
        style: ButtonStyle = .init(title: .init(font: .preferredFont(forTextStyle: .body), color: .red))
    ) {
        self.buttonStyle = theme.elements.buttons.primary
        self.style = style
        super.init(frame: .zero)

        isAccessibilityElement = true
        accessibilityTraits = .button

        addSubview(backgroundView)
        addSubview(activityIndicatorView)
        addSubview(contentStackView)

        backgroundColor = buttonStyle.backgroundColor
        self.adyen.round(using: buttonStyle.cornerRadius ?? .fixed(AdyenUIConstants.defaultCornerRadius))

        configureConstraints()
    }

    /// Initializes the form button with AdyenButtonStyle.
    package init(buttonStyle: AdyenButtonStyle) {
        self.buttonStyle = buttonStyle
        self.style = .init(title: .init(font: .preferredFont(forTextStyle: .body), color: .red))
        super.init(frame: .zero)

        isAccessibilityElement = true
        accessibilityTraits = .button

        addSubview(backgroundView)
        addSubview(activityIndicatorView)
        addSubview(contentStackView)

        backgroundColor = buttonStyle.backgroundColor
        self.adyen.round(using: buttonStyle.cornerRadius ?? .fixed(AdyenUIConstants.defaultCornerRadius))

        configureConstraints()
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Background View
    
    internal lazy var backgroundView: BackgroundView = {
        let backgroundView = BackgroundView(
            cornerRounding: buttonStyle.cornerRadius ?? .fixed(AdyenUIConstants.defaultCornerRadius),
            color: buttonStyle.backgroundColor
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
        let titleLabel = UILabel(style: TextStyle(
            font: AdyenFonts.default.bodyEmphasized,
            color: buttonStyle.textColor
        ))
        titleLabel.isAccessibilityElement = false
        
        return titleLabel
    }()
    
    // MARK: - Leading Image
    
    /// The optional leading image displayed to the left of the title.
    public var leadingImage: UIImage? {
        didSet {
            leadingImageView.image = leadingImage
            leadingImageView.isHidden = leadingImage == nil
        }
    }
    
    private lazy var leadingImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = buttonStyle.textColor
        imageView.isHidden = true
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        return imageView
    }()
    
    internal lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [leadingImageView, titleLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.isUserInteractionEnabled = false
        return stackView
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
                contentStackView.alpha = 0.0
                isEnabled = false
            } else {
                activityIndicatorView.stopAnimating()
                contentStackView.alpha = 1.0
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
        .medium
    }
    
    // MARK: - Layout
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        self.adyen.round(using: buttonStyle.cornerRadius ?? .fixed(AdyenUIConstants.defaultCornerRadius))
    }
    
    private func configureConstraints() {
        backgroundView.adyen.anchor(inside: self)
        
        let heightConstraint = heightAnchor.constraint(equalToConstant: AdyenUIConstants.submitButtonHeight)
        let contentConstraints = [
            contentStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            contentStackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            contentStackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
        ].map { $0.adyen.with(priority: .defaultHigh) }
        
        let imageConstraints = [
            leadingImageView.widthAnchor.constraint(equalToConstant: Constants.leadingImageWidth),
            leadingImageView.heightAnchor.constraint(equalToConstant: Constants.leadingImageHeight)
        ]
        
        let spinnerConstraints = [
            activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ]

        let allConstraints = contentConstraints + imageConstraints + spinnerConstraints + [heightConstraint]

        NSLayoutConstraint.activate(allConstraints)
    }
    
    // MARK: - State
    
    override public var isHighlighted: Bool {
        didSet {
            backgroundView.isHighlighted = isHighlighted
        }
    }
    
}

extension FormButton {
    
    internal final class BackgroundView: UIView {
        
        private let color: UIColor
        private let rounding: CornerRounding

        fileprivate init(
            cornerRounding: CornerRounding,
            color: UIColor
        ) {
            self.color = color
            self.rounding = cornerRounding
            super.init(frame: .zero)
            
            backgroundColor = color
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
