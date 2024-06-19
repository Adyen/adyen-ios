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
internal final class DelegatedAuthenticationView: UIView {
    private let logoStyle: ImageStyle
    private let headerTextStyle: TextStyle
    private let descriptionTextStyle: TextStyle
    
    private let amountTextStyle: TextStyle
    private let cardNumberTextStyle: TextStyle
    private let cardImageStyle: ImageStyle

    private let infoImageStyle: ImageStyle
    private let additionalInformationTextStyle: TextStyle

    private let firstButtonStyle: ButtonStyle
    private let secondButtonStyle: ButtonStyle

    internal weak var delegate: DelegatedAuthenticationViewDelegate?
    
    internal lazy var image: UIImageView = {
        let imageView = UIImageView(style: logoStyle)
        imageView.image = .biometricImage?.withRenderingMode(.alwaysTemplate)
        imageView.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "image")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
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
        let stackView = UIStackView(arrangedSubviews: [image, titleLabel, descriptionLabel])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 12
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
        stackView.spacing = 12
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    internal lazy var cardAndAmountDetailsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [amount, cardNumberStackView])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 20
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 30, trailing: 20)

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
        imageView.contentMode = .scaleAspectFit
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
        imageView.contentMode = .scaleAspectFit
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
        imageView.contentMode = .scaleAspectFit
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
        stackView.distribution = .fill
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

    internal lazy var secondButton: SubmitButton = {
        let button = SubmitButton(style: secondButtonStyle)
        button.addTarget(self, action: #selector(secondButtonTapped), for: .touchUpInside)
        button.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "secondaryButton")
        button.preservesSuperviewLayoutMargins = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    internal lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [firstButton, secondButton])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    internal lazy var informationStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cardAndAmountDetailsStackView, additionalInformationStackView])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    internal lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [tileAndSubtitleStackView, informationStackView])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    // MARK: - initializers
    
    internal init(style: DelegatedAuthenticationComponentStyle) {
        self.logoStyle = style.imageStyle
        self.headerTextStyle = style.headerTextStyle
        self.descriptionTextStyle = style.descriptionTextStyle
        self.amountTextStyle = style.amountTextStyle
        self.infoImageStyle = style.infoImageStyle
        self.additionalInformationTextStyle = style.additionalInformationTextStyle
        self.firstButtonStyle = style.primaryButton
        self.secondButtonStyle = style.secondaryButton
        self.cardImageStyle = style.cardImageStyle
        self.cardNumberTextStyle = style.cardNumberTextStyle
        super.init(frame: .zero)
        configureViews()
    }
    
    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration
        
    private func configureViews() {
        addSubview(contentStackView)
        addSubview(buttonsStackView)
        
        NSLayoutConstraint.activate([
//            image.widthAnchor.constraint(equalToConstant: 40),
//            image.heightAnchor.constraint(equalToConstant: 40),

//            cardImage.widthAnchor.constraint(equalToConstant: 40),
//            cardImage.heightAnchor.constraint(equalToConstant: 26),
                        
            contentStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 30),
            contentStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 15.0),
            contentStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -15.0),

//            buttonsStackView.topAnchor.constraint(greaterThanOrEqualTo: contentStackView.bottomAnchor, constant: 24),
            buttonsStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 15.0),
            buttonsStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -15.0),
            buttonsStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    @objc private func firstButtonTapped() {
        delegate?.firstButtonTapped()
    }
    
    @objc private func secondButtonTapped() {
        delegate?.secondButtonTapped()
    }
    
    internal override func layoutSubviews() {
        super.layoutSubviews()
        updateAxisBasedOnOrientation()
    }
    
    private func updateAxisBasedOnOrientation() {
        contentStackView.axis = UIDevice.current.orientation.isLandscape ? .horizontal : .vertical
        buttonsStackView.axis = UIDevice.current.orientation.isLandscape ? .horizontal : .vertical
        contentStackView.distribution = UIDevice.current.orientation.isLandscape ?  .fillEqually : .fill
    }
}

@available(iOS 16.0, *)
extension UIImage {
    static var biometricImage: UIImage? {
        let authContext = LAContext()
        _ = authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        switch authContext.biometryType {
        case .none:
            return nil
        case .touchID:
            return UIImage(systemName: "touchid")
        case .faceID:
            return UIImage(systemName: "faceid")
        case .opticID:
            return UIImage(systemName: "opticid")
        @unknown default:
            return nil
        }
    }
}
