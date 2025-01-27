//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit
@_spi(AdyenInternal) import Adyen

extension PayByBankUSComponent {
    
    internal class ConfirmationViewController: UIViewController {
        
        private enum Constants {
            static let topPadding: CGFloat = 16
            static let bottomPadding: CGFloat = 8
            static let subtitleLabelSpacing: CGFloat = 10
            static let supportedBankLogosSpacing: CGFloat = 26
        }
        
        private let model: Model
        
        // MARK: Views
        
        internal lazy var headerImageView = UIImageView()
        internal let supportedBankLogosView: SupportedPaymentMethodLogosView
        internal lazy var titleLabel = Self.defaultLabel
        internal lazy var subtitleLabel = Self.defaultLabel
        internal lazy var messageLabel = Self.defaultLabel
        internal let submitButton: SubmitButton
        
        // MARK: UIViewController
        
        public init(model: Model) {
            self.model = model
            
            supportedBankLogosView = SupportedPaymentMethodLogosView(
                imageUrls: model.supportedBankLogoURLs,
                trailingText: model.supportedBanksMoreText
            )
           
            self.submitButton = SubmitButton(style: model.style.submitButton)
            
            super.init(nibName: nil, bundle: nil)
        }
        
        override public func viewDidLoad() {
            super.viewDidLoad()
            setupViews()
        }
        
        @available(*, unavailable)
        public required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override public var preferredContentSize: CGSize {
            get {
                view.adyen.minimalSize
            }

            // swiftlint:disable:next unused_setter_value
            set { AdyenAssertion.assertionFailure(message: """
            PreferredContentSize is overridden for this view controller.
            getter - returns minimum possible content size.
            setter - no implemented.
            """) }
        }
        
        override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
            super.traitCollectionDidChange(previousTraitCollection)
            headerImageView.layer.borderColor = model.style.headerImage.borderColor?.cgColor ?? UIColor.Adyen.componentSeparator.cgColor
        }
    }
}

extension PayByBankUSComponent.ConfirmationViewController {

    static var defaultLabel: UILabel {
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        return titleLabel
    }
    
    @objc internal func submitTapped() {
        submitButton.showsActivityIndicator = true
        model.continueHandler()
    }
    
    private func setupViews() {
        headerImageView.adyen.apply(model.style.headerImage)
        
        titleLabel.text = model.title
        titleLabel.adyen.apply(model.style.title)
        
        subtitleLabel.text = model.subtitle
        subtitleLabel.adyen.apply(model.style.subtitle)
        
        messageLabel.text = model.message
        messageLabel.adyen.apply(model.style.message)
        
        submitButton.title = model.submitTitle
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        
        let contentStack = UIStackView(arrangedSubviews: [
            headerImageView,
            titleLabel,
            supportedBankLogosView,
            subtitleLabel,
            messageLabel
        ])
        contentStack.spacing = 0
        contentStack.axis = .vertical
        contentStack.alignment = .center
        contentStack.setCustomSpacing(Constants.subtitleLabelSpacing, after: subtitleLabel)
        contentStack.setCustomSpacing(Constants.supportedBankLogosSpacing, after: supportedBankLogosView)
        
        let contentButtonStack = UIStackView(arrangedSubviews: [
            contentStack,
            submitButton
        ])
        contentButtonStack.spacing = 32
        contentButtonStack.axis = .vertical
        contentButtonStack.alignment = .fill
        
        view.addSubview(contentButtonStack)
        contentButtonStack.adyen.anchor(
            inside: view.layoutMarginsGuide,
            with: .init(
                top: Constants.topPadding,
                left: 0,
                bottom: Constants.bottomPadding,
                right: 0
            )
        )
        
        model.loadHeaderImage(for: headerImageView)
        
        configureConstraints()
    }
    
    private func configureConstraints() {
        
        let constraints = [
            headerImageView.widthAnchor.constraint(equalToConstant: model.headerImageViewSize.width),
            headerImageView.heightAnchor.constraint(equalToConstant: model.headerImageViewSize.height)
        ]

        headerImageView.setContentHuggingPriority(.required, for: .horizontal)
        
        NSLayoutConstraint.activate(constraints)
    }
}
