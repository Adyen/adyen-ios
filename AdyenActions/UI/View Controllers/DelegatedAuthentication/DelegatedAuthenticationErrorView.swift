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
    
    private let amountTextStyle: TextStyle
    private let cardNumberTextStyle: TextStyle
    private let cardImageStyle: ImageStyle

    private let infoImageStyle: ImageStyle
    private let additionalInformationTextStyle: TextStyle

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
    
    // MARK: Payment Information
    
    internal lazy var amount: UILabel = {
        let label = UILabel(style: amountTextStyle)
        label.isAccessibilityElement = false
        label.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "titleLabel")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    internal lazy var cardImage: UIImageView = {
        let imageView = UIImageView(style: cardImageStyle)
        imageView.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "cardImage")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    internal lazy var cardNumberLabel: UILabel = {
        let label = UILabel(style: cardNumberTextStyle)
        label.isAccessibilityElement = false
        label.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "descriptionLabel")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    internal lazy var cardNumberStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cardImage, cardNumberLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    internal lazy var paymentDetailsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [amount, cardNumberStackView])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 15.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        
        let subView = UIView(frame: bounds)
        subView.backgroundColor = UIColor.secondarySystemBackground
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        stackView.insertSubview(subView, at: 0)
        subView.layer.cornerRadius = 10.0
        subView.layer.masksToBounds = true
        subView.clipsToBounds = true
        return stackView
    }()
    
    // MARK: Additional Information
    
    internal lazy var firstInfoImage: UIImageView = {
        let imageView = UIImageView(style: infoImageStyle)
        imageView.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "infoImage")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    internal lazy var firstInfoLabel: UILabel = {
        let label = UILabel(style: additionalInformationTextStyle)
        label.isAccessibilityElement = false
        label.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "additionalInformationLabel")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()

    internal lazy var firstInfoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [firstInfoImage, firstInfoLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    internal lazy var secondInfoImage: UIImageView = {
        let imageView = UIImageView(style: infoImageStyle)
        imageView.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "infoImage")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    internal lazy var secondInfoLabel: UILabel = {
        let label = UILabel(style: additionalInformationTextStyle)
        label.isAccessibilityElement = false
        label.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "additionalInformationLabel")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()

    internal lazy var secondInfoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [secondInfoImage, secondInfoLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    internal lazy var thirdInfoImage: UIImageView = {
        let imageView = UIImageView(style: infoImageStyle)
        imageView.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "infoImage")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    internal lazy var thirdInfoLabel: UILabel = {
        let label = UILabel(style: additionalInformationTextStyle)
        label.isAccessibilityElement = false
        label.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "additionalInformationLabel")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()

    internal lazy var thirdInfoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [thirdInfoImage, thirdInfoLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    internal lazy var additionalInformationStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [firstInfoStackView, secondInfoStackView, thirdInfoStackView])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 8.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        
        let subView = UIView(frame: bounds)
        subView.backgroundColor = UIColor.tertiarySystemGroupedBackground
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        stackView.insertSubview(subView, at: 0)
        subView.layer.cornerRadius = 10.0
        subView.layer.masksToBounds = true
        subView.clipsToBounds = true
        return stackView
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
                  amountTextStyle: TextStyle,
                  cardImageStyle: ImageStyle,
                  cardNumberTextStyle: TextStyle,
                  infoImageStyle: ImageStyle,
                  additionalInformationTextStyle: TextStyle,
                  firstButtonStyle: ButtonStyle) {
        self.logoStyle = logoStyle
        self.headerTextStyle = headerTextStyle
        self.descriptionTextStyle = descriptionTextStyle
        self.amountTextStyle = amountTextStyle
        self.cardNumberTextStyle = cardNumberTextStyle
        self.infoImageStyle = infoImageStyle
        self.additionalInformationTextStyle = additionalInformationTextStyle
        self.firstButtonStyle = firstButtonStyle
        self.cardImageStyle = cardImageStyle
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
        addSubview(paymentDetailsStackView)
        addSubview(additionalInformationStackView)
        addSubview(buttonsStackView)

        NSLayoutConstraint.activate([
            image.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: 20),
            image.centerXAnchor.constraint(equalTo: layoutMarginsGuide.centerXAnchor),
            image.widthAnchor.constraint(equalToConstant: 40),
            image.heightAnchor.constraint(equalToConstant: 40),

            cardImage.widthAnchor.constraint(equalToConstant: 40),
            cardImage.heightAnchor.constraint(equalToConstant: 26),

            tileAndSubtitleStackView.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 24),
            tileAndSubtitleStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            tileAndSubtitleStackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: 15.0),
            tileAndSubtitleStackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: -15.0),

            paymentDetailsStackView.topAnchor.constraint(equalTo: tileAndSubtitleStackView.bottomAnchor, constant: 24),
            paymentDetailsStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            paymentDetailsStackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: 15.0),
            paymentDetailsStackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: -15.0),

            additionalInformationStackView.topAnchor.constraint(equalTo: paymentDetailsStackView.bottomAnchor, constant: 24),
            additionalInformationStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            additionalInformationStackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: 15.0),
            additionalInformationStackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: -15.0),

            firstButton.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            firstButton.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),

            buttonsStackView.topAnchor.constraint(greaterThanOrEqualTo: additionalInformationStackView.bottomAnchor, constant: 24),
            buttonsStackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            buttonsStackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            buttonsStackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ])
    }

    @objc private func firstButtonTapped() {
        delegate?.firstButtonTapped()
    }
}
