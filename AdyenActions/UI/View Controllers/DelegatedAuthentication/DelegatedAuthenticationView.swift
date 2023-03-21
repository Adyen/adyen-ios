//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation
import UIKit

internal protocol DelegatedAuthenticationViewDelegate: AnyObject {
    func firstButtonTapped()
    func secondButtonTapped()
}

internal final class DelegatedAuthenticationView: UIView {
    private let logoStyle: ImageStyle
    private let headerTextStyle: TextStyle
    private let descriptionTextStyle: TextStyle
    private let progressViewStyle: ProgressViewStyle
    private let progressTextStyle: TextStyle
    private let firstButtonStyle: ButtonStyle
    private let secondButtonStyle: ButtonStyle
    private let textViewStyle: TextStyle
    
    internal weak var delegate: DelegatedAuthenticationViewDelegate?
    
    internal lazy var image: UIImageView = {
        let image = UIImage(named: "biometric", in: Bundle.actionsInternalResources, compatibleWith: nil)
        let imageView = UIImageView(style: logoStyle)
        imageView.image = image?.withRenderingMode(.alwaysTemplate)
        imageView.contentMode = .scaleToFill
        imageView.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "image")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()

    internal lazy var titleLabel: UILabel = {
        let label = UILabel(style: headerTextStyle)
        label.isAccessibilityElement = false
        label.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "titleLabel")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()

    internal lazy var descriptionLabel: UILabel = {
        let label = UILabel(style: descriptionTextStyle)
        label.isAccessibilityElement = false
        label.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "descriptionLabel")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        
        return label
    }()
    
    internal lazy var labelsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    internal lazy var progressView: UIProgressView = {
        let view = UIProgressView(style: progressViewStyle)
        view.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "progressView")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.progress = 1
        
        return view
    }()
    
    internal lazy var progressText: UILabel = {
        let label = UILabel(style: progressTextStyle)
        label.isAccessibilityElement = false
        label.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "progressText")
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    internal lazy var progressStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [progressView, progressText])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 16.0
        stackView.translatesAutoresizingMaskIntoConstraints = false

        return stackView
    }()

    internal lazy var firstButton: UIButton = {
        let button = UIButton(style: firstButtonStyle)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(firstButtonTapped), for: .touchUpInside)
        button.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "primaryButton")
        button.preservesSuperviewLayoutMargins = true
        button.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        return button
    }()

    internal lazy var secondButton: UIButton = {
        let button = UIButton(style: secondButtonStyle)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(secondButtonTapped), for: .touchUpInside)
        button.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "secondaryButton")
        button.preservesSuperviewLayoutMargins = true
        button.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        return button
    }()

    internal lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [firstButton, secondButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    internal lazy var textView: UITextView = {
        let textView = UITextView(style: textViewStyle)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = false
        return textView
    }()

    // MARK: - Initializaers
    
    internal init(logoStyle: ImageStyle,
                  headerTextStyle: TextStyle,
                  descriptionTextStyle: TextStyle,
                  progressViewStyle: ProgressViewStyle,
                  progressTextStyle: TextStyle,
                  firstButtonStyle: ButtonStyle,
                  secondButtonStyle: ButtonStyle,
                  textViewStyle: TextStyle) {
        self.logoStyle = logoStyle
        self.headerTextStyle = headerTextStyle
        self.descriptionTextStyle = descriptionTextStyle
        self.progressViewStyle = progressViewStyle
        self.progressTextStyle = progressTextStyle
        self.firstButtonStyle = firstButtonStyle
        self.secondButtonStyle = secondButtonStyle
        self.textViewStyle = textViewStyle

        super.init(frame: .zero)
        configureViews()
    }
    
    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration
    
    private func configureViews() {
        addSubview(image)
        addSubview(labelsStackView)
        addSubview(progressStackView)
        addSubview(buttonsStackView)
        addSubview(textView)

        NSLayoutConstraint.activate([
            image.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: 50),
            image.centerXAnchor.constraint(equalTo: layoutMarginsGuide.centerXAnchor),
            image.widthAnchor.constraint(equalToConstant: 30),
            image.heightAnchor.constraint(equalToConstant: 34),

            labelsStackView.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 24),
            labelsStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            labelsStackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: 15.0),
            labelsStackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: -15.0),

            progressView.widthAnchor.constraint(equalToConstant: 200),
            progressStackView.topAnchor.constraint(equalTo: labelsStackView.bottomAnchor, constant: 24),
            progressStackView.centerXAnchor.constraint(equalTo: layoutMarginsGuide.centerXAnchor),

            firstButton.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            firstButton.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),

            secondButton.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            secondButton.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),

            buttonsStackView.topAnchor.constraint(equalTo: progressStackView.bottomAnchor, constant: 24),
            buttonsStackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            buttonsStackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            
            textView.heightAnchor.constraint(equalToConstant: 50),
            textView.topAnchor.constraint(equalTo: buttonsStackView.bottomAnchor, constant: 24),
            textView.centerXAnchor.constraint(equalTo: layoutMarginsGuide.centerXAnchor)
        ])
        
    }
    
    @objc private func firstButtonTapped() {
        delegate?.firstButtonTapped()
    }
    
    @objc private func secondButtonTapped() {
        delegate?.secondButtonTapped()
    }
}
