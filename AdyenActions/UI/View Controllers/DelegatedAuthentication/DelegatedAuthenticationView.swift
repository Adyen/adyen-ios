//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation
import LocalAuthentication
import UIKit

internal protocol DelegatedAuthenticationViewDelegate: AnyObject {
    func firstButtonTapped()
    func secondButtonTapped()
}

@available(iOS 16.0, *)
// swiftlint:disable:next type_body_length
internal final class DelegatedAuthenticationView: UIView {
    
    private enum Constants {
        static let topMargin = 30.0
        static let leadingMargin = 15.0
        static let trailingMargin = 15.0
        static let bottomMargin = 15.0
    }
    
    private let style: DelegatedAuthenticationComponentStyle
    
    internal weak var delegate: DelegatedAuthenticationViewDelegate?
        
    // MARK: Header & Description

    internal lazy var logoImage: UIImageView = {
        let imageView = UIImageView(style: style.imageStyle)
        imageView.image = UIImage(
            systemName: "lock",
            withConfiguration: UIImage.SymbolConfiguration(weight: .ultraLight)
        )?
            .withRenderingMode(.alwaysTemplate)
        
        imageView.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "image")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    internal lazy var titleLabel: UILabel = .init(
        style: style.headerTextStyle,
        accessibilityPostfix: "titleLabel",
        multiline: true,
        textAlignment: .center,
        scopeInstance: self
    )
    
    internal lazy var descriptionLabel: UILabel = .init(
        style: style.descriptionTextStyle,
        accessibilityPostfix: "descriptionLabel",
        multiline: true,
        textAlignment: .center,
        scopeInstance: self
    )
    
    internal lazy var tileAndSubtitleStackView: UIStackView = .init(
        arrangedSubviews: [logoImage, titleLabel, descriptionLabel],
        spacing: 8,
        view: self
    )
    
    // MARK: Payment Information
    
    internal lazy var amount: UILabel = .init(
        style: style.amountTextStyle,
        accessibilityPostfix: "amountLabel",
        textAlignment: .center,
        scopeInstance: self
    )
    
    internal lazy var cardImage: UIImageView = {
        let imageView = UIImageView(style: style.cardImageStyle)
        imageView.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "cardImage")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        
        NSLayoutConstraint.activate(
            [
                imageView.widthAnchor.constraint(equalToConstant: 40),
                imageView.heightAnchor.constraint(equalToConstant: 26)
            ]
        )

        return imageView
    }()

    internal lazy var cardNumberLabel: UILabel = .init(
        style: style.cardNumberTextStyle,
        accessibilityPostfix: "cardNumber",
        textAlignment: .center,
        scopeInstance: self
    )
    
    internal lazy var cardNumberStackView: UIStackView = .init(
        arrangedSubviews: [cardImage, cardNumberLabel],
        axis: .horizontal,
        distribution: .equalSpacing,
        alignment: .center,
        spacing: 12,
        view: self
    )
    
    internal lazy var cardAndAmountDetailsStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [amount, cardNumberStackView],
            distribution: .fill,
            alignment: .center,
            spacing: 8,
            view: self,
            withBackground: true
        )
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 20, trailing: 16)
        return stackView
    }()
    
    // MARK: Additional Information
    
    internal lazy var firstInfoImage: UIImageView = .init(infoImageStyle: style.infoImageStyle)
    
    internal lazy var firstInfoLabel: UILabel = .init(
        style: style.additionalInformationTextStyle,
        accessibilityPostfix: "additionalInformationLabel",
        multiline: true,
        textAlignment: .left,
        scopeInstance: self
    )

    internal lazy var firstInfoStackView: UIStackView = .init(
        arrangedSubviews: [firstInfoImage, firstInfoLabel],
        axis: .horizontal,
        alignment: .center,
        spacing: 12,
        view: self
    )
    internal lazy var secondInfoImage: UIImageView = .init(infoImageStyle: style.infoImageStyle)
    
    internal lazy var secondInfoLabel: UILabel = .init(
        style: style.additionalInformationTextStyle,
        accessibilityPostfix: "additionalInformationLabel",
        multiline: true,
        textAlignment: .left,
        scopeInstance: self
    )
    
    internal lazy var secondInfoStackView: UIStackView = .init(
        arrangedSubviews: [secondInfoImage, secondInfoLabel],
        axis: .horizontal,
        alignment: .center,
        spacing: 12,
        view: self
    )
    
    internal lazy var thirdInfoImage: UIImageView = .init(infoImageStyle: style.infoImageStyle)
    
    internal lazy var thirdInfoLabel: UILabel = .init(
        style: style.additionalInformationTextStyle,
        accessibilityPostfix: "additionalInformationLabel",
        multiline: true,
        textAlignment: .left,
        scopeInstance: self
    )

    internal lazy var thirdInfoStackView: UIStackView = .init(
        arrangedSubviews: [thirdInfoImage, thirdInfoLabel],
        axis: .horizontal,
        alignment: .center,
        spacing: 12,
        view: self
    )

    internal lazy var additionalInformationStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                firstInfoStackView,
                secondInfoStackView,
                thirdInfoStackView
            ],
            distribution: .fill,
            alignment: .leading,
            spacing: 8,
            view: self,
            withBackground: true
        )
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        return stackView
    }()
    
    // MARK: Buttons

    internal lazy var firstButton: SubmitButton = {
        let button = SubmitButton(style: style.primaryButton)

        button.addTarget(self, action: #selector(firstButtonTapped), for: .touchUpInside)
        button.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "primaryButton")
        button.preservesSuperviewLayoutMargins = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    internal lazy var secondButton: SubmitButton = {
        let button = SubmitButton(style: style.secondaryButton)
        button.addTarget(self, action: #selector(secondButtonTapped), for: .touchUpInside)
        button.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "secondaryButton")
        button.preservesSuperviewLayoutMargins = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    internal lazy var buttonsStackView: UIStackView = .init(
        arrangedSubviews: [
            firstButton,
            secondButton
        ],
        distribution: .fillEqually,
        spacing: 8,
        view: self
    )

    // MARK: Container views
    
    internal lazy var scrollView = UIScrollView(frame: .zero)

    internal lazy var contentStackView: UIStackView = .init(
        arrangedSubviews: [
            tileAndSubtitleStackView,
            cardAndAmountDetailsStackView,
            additionalInformationStackView
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
            logoImage.heightAnchor.constraint(equalToConstant: 40),
            
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
    
    @objc private func secondButtonTapped() {
        delegate?.secondButtonTapped()
    }
    
    override internal func layoutSubviews() {
        super.layoutSubviews()
        updateAxisBasedOnOrientation()
    }
    
    private func updateAxisBasedOnOrientation() {
        buttonsStackView.axis = UIDevice.current.orientation.isLandscape ? .horizontal : .vertical
    }
    
    internal func animateImageTransitionToSystemImage(named: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self else { return }
            
            if let replacementImage = UIImage(
                systemName: named,
                withConfiguration: UIImage.SymbolConfiguration(weight: .ultraLight)
            ) {
                
                UIView.transition(
                    with: self.logoImage,
                    duration: 0.5,
                    options: .transitionCrossDissolve,
                    animations: { self.logoImage.image = replacementImage },
                    completion: nil
                )
            }
        }
    }
}
