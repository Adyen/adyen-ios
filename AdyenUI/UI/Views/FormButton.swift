//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import SwiftUI
import UIKit

/// A rounded button for use in forms.
/// Use `FormButtonView` to display this button in SwiftUI.
/// It has a template like [{Progress-indicator} | {image}] {Text}
/// The progress indicator for the button is a custom one implemented by `CircularProgressView` to show and remove progress we add and remove that view.
/// When progress is active it replaces the image.
package final class FormButton: UIControl {
    private enum Constants {
        static let leadingImageWidth: CGFloat = 24
        static let leadingImageHeight: CGFloat = 24
        static let progressViewSize: CGFloat = 20
        static let progressViewLineWidth: CGFloat = 2.5
        static let progressViewMargin: CGFloat = 0
    }

    private var style: ButtonStyle
    private var buttonStyle: AdyenButtonStyle = .primary(for: .default)

    /// Initializes the form button.
    ///
    /// - Parameter style: The `FormButton` UI style.
    package init(style: ButtonStyle) {
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
    package init(buttonStyle: AdyenButtonStyle) {
        self.buttonStyle = buttonStyle
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
            color: buttonStyle.backgroundColor,
            disabledColor: buttonStyle.disabledBackgroundColor
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
        let titleLabel = UILabel(style: TextStyle(
            font: AdyenFonts.default.bodyEmphasized,
            color: buttonStyle.textColor
        ))
        titleLabel.isAccessibilityElement = false
        
        return titleLabel
    }()
    
    // MARK: - Leading Accessory
    
    /// The content shown in the leading slot before the title. Only one accessory can be shown at a time.
    private enum LeadingAccessory {
        case none
        case image(UIImage)
        case progress
    }
    
    private var leadingAccessory: LeadingAccessory = .none {
        didSet {
            applyLeadingAccessory()
        }
    }
    
    /// The accessory to show when the button is not loading.
    private var idleLeadingAccessory: LeadingAccessory {
        leadingImage.map(LeadingAccessory.image) ?? .none
    }
    
    private func applyLeadingAccessory() {
        switch leadingAccessory {
        case .none:
            leadingImageView.isHidden = true
            hideProgressView()
        case let .image(image):
            leadingImageView.image = image
            leadingImageView.isHidden = false
            hideProgressView()
        case .progress:
            leadingImageView.isHidden = true
            showProgressView()
        }
    }
    
    // MARK: - Leading Image
    
    /// The optional leading image displayed to the left of the title.
    /// While loading, the progress view takes its place and the image comes back when loading ends.
    package var leadingImage: UIImage? {
        didSet {
            guard !showsActivityIndicator else { return }
            leadingAccessory = idleLeadingAccessory
        }
    }
    
    internal lazy var leadingImageView: UIImageView = {
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
        let stackView = UIStackView(arrangedSubviews: [progressContainerView, leadingImageView, titleLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8
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
    
    // MARK: - Progress View
    
    /// Boolean value indicating whether a progress view should be shown.
    package var showsActivityIndicator: Bool {
        get {
            if case .progress = leadingAccessory { return true }
            return false
        }
        
        set {
            isEnabled = !newValue
            leadingAccessory = newValue ? .progress : idleLeadingAccessory
        }
    }
    
    private var progressContentView: (UIView & UIContentView)?
    
    private lazy var progressContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.isHidden = true
        view.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "activityIndicator")
        return view
    }()
    
    private func makeProgressConfiguration() -> UIContentConfiguration {
        UIHostingConfiguration {
            CircularProgressView(
                arcColor: contentColor,
                trackColor: contentColor,
                size: Constants.progressViewSize,
                lineWidth: Constants.progressViewLineWidth
            )
        }
        .margins(.all, Constants.progressViewMargin)
    }
    
    private func showProgressView() {
        guard progressContentView == nil else { return }
        let contentView = makeProgressConfiguration().makeContentView()
        contentView.backgroundColor = .clear
        contentView.translatesAutoresizingMaskIntoConstraints = false
        progressContainerView.addSubview(contentView)
        (contentView as UIView).adyen.anchor(inside: progressContainerView)
        progressContentView = contentView
        progressContainerView.isHidden = false
    }
    
    private func hideProgressView() {
        progressContentView?.removeFromSuperview()
        progressContentView = nil
        progressContainerView.isHidden = true
    }
    
    private var contentColor: UIColor {
        isEnabled ? buttonStyle.textColor : buttonStyle.disabledTextColor
    }
    
    private func updateAppearance() {
        titleLabel.textColor = contentColor
        leadingImageView.tintColor = contentColor
        progressContentView?.configuration = makeProgressConfiguration()
        backgroundView.isEnabled = isEnabled
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
            contentStackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            contentStackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
        ].map { $0.adyen.with(priority: .defaultHigh) }
        
        let imageConstraints = [
            leadingImageView.widthAnchor.constraint(equalToConstant: Constants.leadingImageWidth),
            leadingImageView.heightAnchor.constraint(equalToConstant: Constants.leadingImageHeight)
        ]
        
        let progressConstraints = [
            progressContainerView.widthAnchor.constraint(equalToConstant: Constants.progressViewSize),
            progressContainerView.heightAnchor.constraint(equalToConstant: Constants.progressViewSize)
        ].map { $0.adyen.with(priority: .defaultHigh) }
        
        let allConstraints = contentConstraints + imageConstraints + progressConstraints + [heightConstraint]

        NSLayoutConstraint.activate(allConstraints)
    }
    
    // MARK: - State
    
    override package var isHighlighted: Bool {
        didSet {
            backgroundView.isHighlighted = isHighlighted
        }
    }
    
    override package var isEnabled: Bool {
        didSet {
            updateAppearance()
        }
    }
    
}

extension FormButton {
    
    internal final class BackgroundView: UIView {
        
        private let color: UIColor
        private let disabledColor: UIColor
        private let rounding: CornerRounding

        fileprivate init(
            cornerRounding: CornerRounding,
            color: UIColor,
            disabledColor: UIColor
        ) {
            self.color = color
            self.disabledColor = disabledColor
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
        
        fileprivate var isEnabled = true {
            didSet {
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
            var backgroundColor = isEnabled ? color : disabledColor
            
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
