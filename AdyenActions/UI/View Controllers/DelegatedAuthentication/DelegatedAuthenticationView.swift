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
    private let style: DelegatedAuthenticationComponentStyle
    
    internal weak var delegate: DelegatedAuthenticationViewDelegate?
        
    // MARK: Header & Description

    internal lazy var logoImage: UIImageView = {
        let imageView = UIImageView(style: style.imageStyle)
        imageView.image = UIImage(systemName: "lock",
                                  withConfiguration: UIImage.SymbolConfiguration(weight: .ultraLight))?
            .withRenderingMode(.alwaysTemplate)
        
        imageView.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "image")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    internal lazy var titleLabel: UILabel = .make(style: style.headerTextStyle, accessibilityPostfix: "titleLabel")
    
    internal lazy var descriptionLabel: UILabel = .make(style: style.descriptionTextStyle,
                                                        accessibilityPostfix: "descriptionLabel",
                                                        multiline: true)
    
    internal lazy var tileAndSubtitleStackView: UIStackView = .make(arrangedSubviews: [logoImage, titleLabel, descriptionLabel],
                                                                    spacing: 8,
                                                                    view: self)
    
    // MARK: Payment Information
    
    internal lazy var amount: UILabel = .make(style: style.amountTextStyle, accessibilityPostfix: "amountLabel")
    
    internal lazy var cardImage: UIImageView = {
        let imageView = UIImageView(style: style.cardImageStyle)
        imageView.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "cardImage")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        
        NSLayoutConstraint.activate(
            [imageView.widthAnchor.constraint(equalToConstant: 40),
             imageView.heightAnchor.constraint(equalToConstant: 26)]
        )

        return imageView
    }()

    internal lazy var cardNumberLabel: UILabel = .make(style: style.cardNumberTextStyle, accessibilityPostfix: "cardNumber")
    
    internal lazy var cardNumberStackView: UIStackView = .make(arrangedSubviews: [cardImage, cardNumberLabel],
                                                               axis: .horizontal,
                                                               distribution: .equalSpacing,
                                                               alignment: .center,
                                                               spacing: 12,
                                                               view: self)
    
    internal lazy var cardAndAmountDetailsStackView: UIStackView = {
        let stackView = UIStackView.make(arrangedSubviews: [amount, cardNumberStackView],
                                         distribution: .fill,
                                         alignment: .center,
                                         spacing: 8,
                                         view: self,
                                         withBackground: true)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 20, trailing: 16)
        return stackView
    }()
    
    // MARK: Additional Information
    
    internal lazy var firstInfoImage: UIImageView = {
        let imageView = UIImageView(style: style.infoImageStyle)
        imageView.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "infoImage")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        
        NSLayoutConstraint.activate(
            [imageView.widthAnchor.constraint(equalToConstant: 16),
             imageView.heightAnchor.constraint(equalToConstant: 16)]
        )

        return imageView
    }()
    
    internal lazy var firstInfoLabel: UILabel = .make(style: style.additionalInformationTextStyle,
                                                      accessibilityPostfix: "additionalInformationLabel")

    internal lazy var firstInfoStackView: UIStackView = .make(arrangedSubviews: [firstInfoImage, firstInfoLabel],
                                                              axis: .horizontal,
                                                              alignment: .center,
                                                              spacing: 12,
                                                              view: self)
    internal lazy var secondInfoImage: UIImageView = {
        let imageView = UIImageView(style: style.infoImageStyle)
        imageView.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "infoImage")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        
        NSLayoutConstraint.activate(
            [imageView.widthAnchor.constraint(equalToConstant: 16),
             imageView.heightAnchor.constraint(equalToConstant: 16)]
        )

        return imageView
    }()
    
    internal lazy var secondInfoLabel: UILabel = .make(style: style.additionalInformationTextStyle,
                                                       accessibilityPostfix: "additionalInformationLabel")
    
    internal lazy var secondInfoStackView: UIStackView = .make(arrangedSubviews: [secondInfoImage, secondInfoLabel],
                                                               axis: .horizontal,
                                                               alignment: .center,
                                                               spacing: 12,
                                                               view: self)
    
    internal lazy var thirdInfoImage: UIImageView = {
        let imageView = UIImageView(style: style.infoImageStyle)
        imageView.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "infoImage")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        
        NSLayoutConstraint.activate(
            [imageView.widthAnchor.constraint(equalToConstant: 16),
             imageView.heightAnchor.constraint(equalToConstant: 16)]
        )

        return imageView
    }()
    
    internal lazy var thirdInfoLabel: UILabel = {
        .make(style: style.additionalInformationTextStyle, accessibilityPostfix: "additionalInformationLabel")
    }()

    internal lazy var thirdInfoStackView: UIStackView = {
        .make(arrangedSubviews: [thirdInfoImage, thirdInfoLabel],
              axis: .horizontal,
              alignment: .center,
              spacing: 12,
              view: self)
    }()

    internal lazy var additionalInformationStackView: UIStackView = {
        let stackView = UIStackView.make(arrangedSubviews: [firstInfoStackView,
                                                            secondInfoStackView,
                                                            thirdInfoStackView],
                                         distribution: .fill,
                                         alignment: .leading,
                                         spacing: 8,
                                         view: self,
                                         withBackground: true)
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

    internal lazy var buttonsStackView: UIStackView = .make(arrangedSubviews: [firstButton,
                                                                               secondButton],
                                                            distribution: .fillEqually,
                                                            spacing: 8,
                                                            view: self)

    // MARK: Container views
    
    internal lazy var scrollView = UIScrollView(frame: .zero)

    internal lazy var contentStackView: UIStackView = .make(arrangedSubviews: [tileAndSubtitleStackView,
                                                                               cardAndAmountDetailsStackView,
                                                                               additionalInformationStackView],
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
            logoImage.heightAnchor.constraint(equalToConstant: 40),
                        
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 30),
            scrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 15.0),
            scrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -15.0),
            scrollView.bottomAnchor.constraint(equalTo: buttonsStackView.topAnchor, constant: -8),
            
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor),
            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 10),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            
            buttonsStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 15.0),
            buttonsStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -15.0),
            buttonsStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -15.0)
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
        let workItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            if #available(iOS 17.0, *) {
                logoImage.addSymbolEffect(.bounce, options: .repeat(2))
            }
            
            if let replacementImage = UIImage(systemName: named,
                                              withConfiguration: UIImage.SymbolConfiguration(weight: .ultraLight)) {
                if #available(iOS 17.0, *) {
                    logoImage.setSymbolImage(replacementImage, contentTransition: .replace)
                } else {
                    UIView.transition(with: logoImage,
                                      duration: 0.5,
                                      options: .transitionCrossDissolve,
                                      animations: { self.logoImage.image = replacementImage },
                                      completion: nil)
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: workItem)
    }
}

// MARK: - view creation helpers

@available(iOS 16.0, *)
extension UIStackView {
    internal static func make(arrangedSubviews: [UIView],
                              axis: NSLayoutConstraint.Axis = .vertical,
                              distribution: UIStackView.Distribution = .fill,
                              alignment: UIStackView.Alignment = .fill,
                              spacing: CGFloat,
                              view: UIView,
                              withBackground: Bool = false) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.axis = axis
        stackView.alignment = alignment
        stackView.spacing = spacing
        stackView.distribution = distribution
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        if withBackground {
            let subView = UIView(frame: view.bounds)
            subView.backgroundColor = UIColor.secondarySystemBackground
            subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            stackView.insertSubview(subView, at: 0)
            subView.layer.cornerRadius = 10.0
            subView.layer.masksToBounds = true
            subView.clipsToBounds = true
        }
        return stackView
    }
}

@available(iOS 16.0, *)
extension UILabel {
    internal static func make(style: TextStyle, accessibilityPostfix: String, multiline: Bool = false) -> UILabel {
        let label = UILabel(style: style)
        label.isAccessibilityElement = false
        label.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: accessibilityPostfix)
        label.translatesAutoresizingMaskIntoConstraints = false
        if multiline {
            label.numberOfLines = 0
        }
        return label
    }
}
