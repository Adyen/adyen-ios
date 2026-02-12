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
    func troubleshootingButtonTapped()
}

@available(iOS 16.0, *)
internal final class DelegatedAuthenticationErrorView: UIView {

    private enum Constants {
        static let topMargin = 30.0
        static let leadingMargin = 15.0
        static let trailingMargin = 15.0
        static let bottomMargin = 25.0
    }
    
    private let style: DelegatedAuthenticationComponentStyle

    internal weak var delegate: DelegatedAuthenticationErrorViewDelegate?
    
    // MARK: Header & Description

    internal lazy var image: UIImageView = {
        let imageView = UIImageView(style: style.errorImageStyle)
        imageView.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "image")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    internal lazy var titleLabel: UILabel = .init(
        style: style.errorTitleStyle,
        accessibilityPostfix: "titleLabel",
        multiline: true,
        textAlignment: .center,
        scopeInstance: self
    )
    
    internal lazy var descriptionLabel: UILabel = .init(
        style: style.errorDescription,
        accessibilityPostfix: "descriptionLabel",
        multiline: true,
        textAlignment: .center,
        scopeInstance: self
    )
    
    internal lazy var troubleshootingTitle: UILabel = .init(
        style: style.troubleshootingTitleStyle,
        accessibilityPostfix: "troubleshootingTitle",
        multiline: false,
        textAlignment: .center,
        scopeInstance: self
    )
    
    internal lazy var troubleshootingDescription: UILabel = .init(
        style: style.troubleshootingDescriptionStyle,
        accessibilityPostfix: "troubleshootingDescription",
        multiline: true,
        textAlignment: .center,
        scopeInstance: self
    )
    
    internal lazy var troubleshootingButton: SubmitButton = {
        let button = SubmitButton(style: self.style.troubleshootingButtonStyle)
        button.addTarget(self, action: #selector(troubleshootingButtonTapped), for: .touchUpInside)
        button.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "troubleshootingButton")
        button.preservesSuperviewLayoutMargins = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    internal lazy var troubleshootingStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                troubleshootingTitle,
                troubleshootingDescription,
                troubleshootingButton
            ],
            distribution: .fill,
            alignment: .center,
            spacing: 8,
            view: self,
            withBackground: true
        )
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        return stackView
    }()
    
    internal lazy var tileAndSubtitleStackView: UIStackView = .init(
        arrangedSubviews: [image, titleLabel, descriptionLabel],
        spacing: 16,
        view: self
    )
                    
    // MARK: Buttons

    internal lazy var firstButton: SubmitButton = {
        let button = SubmitButton(style: style.errorButton)

        button.addTarget(self, action: #selector(firstButtonTapped), for: .touchUpInside)
        button.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "primaryButton")
        button.preservesSuperviewLayoutMargins = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    internal lazy var buttonsStackView: UIStackView = .init(
        arrangedSubviews: [firstButton],
        distribution: .fillEqually,
        spacing: 5,
        view: self
    )
    
    // MARK: - Container Views
    
    internal lazy var scrollView = UIScrollView(frame: .zero)
    internal lazy var contentStackView: UIStackView = .init(
        arrangedSubviews: [
            tileAndSubtitleStackView,
            troubleshootingStackView,
            buttonsStackView
        ],
        spacing: 16,
        view: self
    )

    // MARK: - initializers
    
    internal init(style: DelegatedAuthenticationComponentStyle) {
        self.style = style
        super.init(frame: .zero)
        configureViews()
    }
    
    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration
    
    private func configureViews() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStackView)
        addSubview(scrollView)
        addSubview(buttonsStackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: Constants.topMargin),
            scrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: Constants.leadingMargin),
            scrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -Constants.trailingMargin),
            scrollView.bottomAnchor.constraint(equalTo: buttonsStackView.topAnchor, constant: -8),
            
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor),
            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 10),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            
            buttonsStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: Constants.leadingMargin),
            buttonsStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -Constants.trailingMargin),
            buttonsStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -Constants.bottomMargin)
        ])
    }

    @objc private func firstButtonTapped() {
        delegate?.firstButtonTapped()
    }
    
    @objc private func troubleshootingButtonTapped() {
        delegate?.troubleshootingButtonTapped()
    }
}
