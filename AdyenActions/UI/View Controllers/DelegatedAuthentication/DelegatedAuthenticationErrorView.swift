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

    internal lazy var titleLabel: UILabel = .make(style: style.errorTitleStyle, accessibilityPostfix: "titleLabel")
    
    internal lazy var descriptionLabel: UILabel = .make(style: style.errorDescription,
                                                        accessibilityPostfix: "descriptionLabel",
                                                        multiline: true)
    
    internal lazy var tileAndSubtitleStackView: UIStackView = .make(arrangedSubviews: [image, titleLabel, descriptionLabel],
                                                                    spacing: 16,
                                                                    view: self)
                    
    // MARK: Buttons

    internal lazy var firstButton: SubmitButton = {
        let button = SubmitButton(style: style.errorButton)

        button.addTarget(self, action: #selector(firstButtonTapped), for: .touchUpInside)
        button.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "primaryButton")
        button.preservesSuperviewLayoutMargins = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    internal lazy var buttonsStackView: UIStackView = .make(arrangedSubviews: [firstButton],
                                                            distribution: .fillEqually,
                                                            spacing: 5,
                                                            view: self)
    
    // MARK: - Container Views
    
    internal lazy var scrollView = UIScrollView(frame: .zero)
    internal lazy var contentStackView: UIStackView = .make(arrangedSubviews: [tileAndSubtitleStackView, buttonsStackView],
                                                            spacing: 16,
                                                            view: self)

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
}
