//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// A rounded button for use in forms.
package final class FormButton: UIControl {
    private enum Constants {
        static let leadingImageWidth: CGFloat = 24
        static let leadingImageHeight: CGFloat = 24
        static let activityIndicatorSize: CGFloat = 24
        static let horizontalPadding: CGFloat = 20
    }

    private var style: ButtonStyle
    private var buttonStyle: AdyenButtonStyle = .primary(for: .default)
    private let titleStyle: AdyenLabelStyle

    /// Initializes the form button.
    ///
    /// - Parameter style: The `FormButton` UI style.
    package init(style: ButtonStyle) {
        self.titleStyle = AdyenLabelStyle(
            font: AdyenFonts.default.bodyEmphasized,
            color: style.title.color,
            textAlignment: .center
        )
        self.style = style
        super.init(frame: .zero)
        
        isAccessibilityElement = true
        accessibilityTraits = .button
        
        addSubview(backgroundView)
        addSubview(contentStackView)

        backgroundColor = style.backgroundColor
        self.adyen.round(using: style.cornerRounding)

        configureConstraints()
    }

    /// Initializes the form button.
    /// - Parameter buttonStyle: The  new `FormButton` UI style.
    /// - Parameter style: The  old `FormButton` UI style.
    package init(
        theme: CheckoutTheme,
        style: ButtonStyle = .init(title: .init(font: .preferredFont(forTextStyle: .body), color: .red))
    ) {
        self.buttonStyle = theme.elements.buttons.primary
        self.titleStyle = theme.elements.labels.bodyEmphasized.color(theme.elements.buttons.primary.textColor)
        self.style = style
        super.init(frame: .zero)

        isAccessibilityElement = true
        accessibilityTraits = .button

        addSubview(backgroundView)
        addSubview(contentStackView)

        backgroundColor = buttonStyle.backgroundColor
        self.adyen.round(using: buttonStyle.cornerRadius ?? .fixed(AdyenUIConstants.defaultCornerRadius))

        configureConstraints()
    }

    /// Initializes the form button with AdyenButtonStyle.
    package init(buttonStyle: AdyenButtonStyle, titleStyle: AdyenLabelStyle) {
        self.buttonStyle = buttonStyle
        self.titleStyle = titleStyle.color(buttonStyle.textColor)
        self.style = .init(title: .init(font: .preferredFont(forTextStyle: .body), color: .red))
        super.init(frame: .zero)

        isAccessibilityElement = true
        accessibilityTraits = .button

        addSubview(backgroundView)
        addSubview(contentStackView)

        backgroundColor = buttonStyle.backgroundColor
        self.adyen.round(using: buttonStyle.cornerRadius ?? .fixed(AdyenUIConstants.defaultCornerRadius))

        configureConstraints()
    }

    @available(*, unavailable)
    package required init?(coder aDecoder: NSCoder) {
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
    package var title: String? {
        didSet {
            titleLabel.text = title
            accessibilityLabel = title
        }
    }
    
    internal lazy var titleLabel: UILabel = {
        let titleLabel = AdyenLabel()
        titleLabel.apply(titleStyle)
        titleLabel.isAccessibilityElement = false
        
        return titleLabel
    }()
    
    // MARK: - Leading Image
    
    /// The optional leading image displayed to the left of the title.
    package var leadingImage: UIImage? {
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
        let stackView = UIStackView(arrangedSubviews: [activityIndicatorView, leadingImageView, titleLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 12
        stackView.isUserInteractionEnabled = false
        return stackView
    }()
    
    override package var accessibilityIdentifier: String? {
        didSet {
            titleLabel.accessibilityIdentifier = accessibilityIdentifier.map {
                ViewIdentifierBuilder.build(scopeInstance: $0, postfix: "titleLabel")
            }
        }
    }
    
    // MARK: - Activity Indicator View
    
    /// Boolean value indicating whether an activity indicator should be shown.
    package var showsActivityIndicator: Bool {
        get {
            activityIndicatorView.isAnimating
        }
        
        set {
            if newValue {
                activityIndicatorView.startAnimating()
            } else {
                activityIndicatorView.stopAnimating()
            }
            isEnabled = !newValue
            updateAppearance()
        }
    }

    override package var isEnabled: Bool {
        didSet {
            updateAppearance()
        }
    }

    private func updateAppearance() {
        let backgroundColor: UIColor
        let contentColor: UIColor
        if showsActivityIndicator {
            backgroundColor = buttonStyle.loadingBackgroundColor
            contentColor = buttonStyle.loadingTextColor
        } else if !isEnabled {
            backgroundColor = buttonStyle.disabledBackgroundColor
            contentColor = buttonStyle.disabledTextColor
        } else {
            backgroundColor = buttonStyle.backgroundColor
            contentColor = buttonStyle.textColor
        }

        backgroundView.baseColor = backgroundColor
        self.backgroundColor = backgroundColor
        titleLabel.textColor = contentColor
        leadingImageView.tintColor = contentColor
        activityIndicatorView.color = contentColor
    }
    
    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: activityIndicatorStyle)
        activityIndicatorView.color = titleLabel.textColor
        activityIndicatorView.backgroundColor = .clear
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        // `.medium` is 20pt; scale it to the 24pt design value.
        activityIndicatorView.transform = CGAffineTransform(
            scaleX: Constants.activityIndicatorSize / 20,
            y: Constants.activityIndicatorSize / 20
        )
        activityIndicatorView.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "activityIndicator")
        return activityIndicatorView
    }()
    
    private var activityIndicatorStyle: UIActivityIndicatorView.Style {
        .medium
    }
    
    // MARK: - Layout
    
    override package func layoutSubviews() {
        super.layoutSubviews()
        self.adyen.round(using: buttonStyle.cornerRadius ?? .fixed(AdyenUIConstants.defaultCornerRadius))
    }
    
    private func configureConstraints() {
        backgroundView.adyen.anchor(inside: self)
        
        let heightConstraint = heightAnchor.constraint(equalToConstant: AdyenUIConstants.submitButtonHeight)
        let contentConstraints = [
            contentStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            contentStackView.leadingAnchor.constraint(
                greaterThanOrEqualTo: leadingAnchor,
                constant: Constants.horizontalPadding
            ),
            contentStackView.trailingAnchor.constraint(
                lessThanOrEqualTo: trailingAnchor,
                constant: -Constants.horizontalPadding
            )
        ].map { $0.adyen.with(priority: .defaultHigh) }
        
        let imageConstraints = [
            leadingImageView.widthAnchor.constraint(equalToConstant: Constants.leadingImageWidth),
            leadingImageView.heightAnchor.constraint(equalToConstant: Constants.leadingImageHeight)
        ]
        
        let spinnerConstraints = [
            activityIndicatorView.widthAnchor.constraint(equalToConstant: Constants.activityIndicatorSize),
            activityIndicatorView.heightAnchor.constraint(equalToConstant: Constants.activityIndicatorSize)
        ]

        let allConstraints = contentConstraints + imageConstraints + spinnerConstraints + [heightConstraint]

        NSLayoutConstraint.activate(allConstraints)
    }
    
    // MARK: - State
    
    override package var isHighlighted: Bool {
        didSet {
            backgroundView.isHighlighted = isHighlighted
        }
    }
    
}

extension FormButton {
    
    internal final class BackgroundView: UIView {
        
        private var color: UIColor
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

        /// The unhighlighted background color of the button.
        fileprivate var baseColor: UIColor {
            get { color }
            set {
                color = newValue
                updateBackgroundColor()
            }
        }

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
