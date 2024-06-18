//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation
import UIKit

internal protocol DelegatedAuthenticationErrorViewDelegate: AnyObject {
    func firstButtonTapped()
}

@available(iOS 16.0, *)
internal final class DelegatedAuthenticationErrorView: UIView {
    private let logoStyle: ImageStyle
    private let headerTextStyle: TextStyle
    private let descriptionTextStyle: TextStyle
    private let progressTextStyle: TextStyle
    private let firstButtonStyle: ButtonStyle

    internal weak var delegate: DelegatedAuthenticationErrorViewDelegate?
    
    internal lazy var image: UIImageView = {
        let imageView = UIImageView(style: logoStyle)
        imageView.image = .biometricImage?.withRenderingMode(.alwaysTemplate)
        imageView.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "image")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()

    internal lazy var titleLabel: UILabel = {
        let label = UILabel(style: headerTextStyle)
        label.isAccessibilityElement = false
        label.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "titleLabel")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    internal lazy var descriptionLabel: UILabel = {
        let label = UILabel(style: descriptionTextStyle)
        label.isAccessibilityElement = false
        label.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "descriptionLabel")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    internal lazy var tileAndSubtitleStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    internal lazy var progressText: UILabel = {
        let label = UILabel(style: progressTextStyle)
        label.isAccessibilityElement = false
        label.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "progressText")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
                
    // MARK: Buttons

    internal lazy var firstButton: SubmitButton = {
        let button = SubmitButton(style: firstButtonStyle)

        button.addTarget(self, action: #selector(firstButtonTapped), for: .touchUpInside)
        button.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "primaryButton")
        button.preservesSuperviewLayoutMargins = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    internal lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [firstButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    // MARK: - initializers
    
    internal init(logoStyle: ImageStyle,
                  headerTextStyle: TextStyle,
                  descriptionTextStyle: TextStyle,
                  progressTextStyle: TextStyle,
                  firstButtonStyle: ButtonStyle) {
        self.logoStyle = logoStyle
        self.headerTextStyle = headerTextStyle
        self.descriptionTextStyle = descriptionTextStyle
        self.firstButtonStyle = firstButtonStyle
        self.progressTextStyle = progressTextStyle
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
        addSubview(tileAndSubtitleStackView)
        addSubview(buttonsStackView)
        addSubview(progressText)
        
        NSLayoutConstraint.activate([
            image.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: 20),
            image.centerXAnchor.constraint(equalTo: layoutMarginsGuide.centerXAnchor),
            image.widthAnchor.constraint(equalToConstant: 40),
            image.heightAnchor.constraint(equalToConstant: 40),

            tileAndSubtitleStackView.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 24),
            tileAndSubtitleStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            tileAndSubtitleStackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: 15.0),
            tileAndSubtitleStackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: -15.0),

            progressText.topAnchor.constraint(equalTo: tileAndSubtitleStackView.bottomAnchor, constant: 24),
            progressText.centerXAnchor.constraint(equalTo: layoutMarginsGuide.centerXAnchor),

            firstButton.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            firstButton.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),

            buttonsStackView.topAnchor.constraint(greaterThanOrEqualTo: progressText.bottomAnchor, constant: 24),
            buttonsStackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            buttonsStackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            buttonsStackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ])
    }

    @objc private func firstButtonTapped() {
        delegate?.firstButtonTapped()
    }
}
