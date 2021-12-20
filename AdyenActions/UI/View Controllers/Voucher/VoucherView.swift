//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import PassKit
import UIKit

internal protocol VoucherViewDelegate: ActionViewDelegate {
    
    func addToAppleWallet(completion: @escaping () -> Void)
    
    func secondaryButtonTap(sourceView: UIView)
}

internal final class VoucherView: UIView, Localizable {
    
    internal let model: Model
    
    internal weak var delegate: VoucherViewDelegate?
    
    private lazy var containerView = UIView()
    
    private lazy var loadingView = LoadingView(contentView: containerView)
    
    internal init(model: Model) {
        self.model = model

        super.init(frame: .zero)
        self.accessibilityIdentifier = model.identifier
        self.translatesAutoresizingMaskIntoConstraints = false
        
        buildUI()
    }
    
    /// :nodoc:
    internal var localizationParameters: LocalizationParameters?
    
    /// :nodoc:
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal var spacerPortraitConstraint: NSLayoutConstraint?
    internal var spacerLandscapeConstraint: NSLayoutConstraint?

    private func buildUI() {
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(loadingView)
        loadingView.adyen.anchor(inside: self)
        
        let firstSpacer = UIView()
        firstSpacer.translatesAutoresizingMaskIntoConstraints = false
        let secondSpacer = UIView()
        secondSpacer.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(logo)
        containerView.addSubview(firstSpacer)
        containerView.addSubview(amountLabel)
        containerView.addSubview(secondSpacer)
        containerView.addSubview(currencyLabel)
        containerView.addSubview(buttonsStackView)
        
        spacerLandscapeConstraint = firstSpacer.heightAnchor.constraint(greaterThanOrEqualToConstant: 30.0)
        spacerPortraitConstraint = firstSpacer.heightAnchor.constraint(equalToConstant: 80.0)

        NSLayoutConstraint.activate([
            logo.topAnchor.constraint(equalTo: topAnchor, constant: -22),
            logo.centerXAnchor.constraint(equalTo: centerXAnchor),
            firstSpacer.topAnchor.constraint(equalTo: logo.bottomAnchor),
            firstSpacer.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            firstSpacer.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            amountLabel.topAnchor.constraint(equalTo: firstSpacer.bottomAnchor),
            amountLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            currencyLabel.trailingAnchor.constraint(equalTo: amountLabel.leadingAnchor, constant: -4.0),
            currencyLabel.centerYAnchor.constraint(equalTo: amountLabel.centerYAnchor),
            secondSpacer.topAnchor.constraint(equalTo: amountLabel.bottomAnchor),
            secondSpacer.heightAnchor.constraint(equalTo: firstSpacer.heightAnchor),
            secondSpacer.widthAnchor.constraint(equalTo: firstSpacer.widthAnchor),
            secondSpacer.centerXAnchor.constraint(equalTo: firstSpacer.centerXAnchor),
            buttonsStackView.topAnchor.constraint(equalTo: secondSpacer.bottomAnchor),
            buttonsStackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            buttonsStackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            buttonsStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
        
        updateSpacerConstraints()
    }
    
    override internal func layoutSubviews() {
        super.layoutSubviews()
        
        updateSpacerConstraints()
    }
    
    private func updateSpacerConstraints() {
        spacerPortraitConstraint?.isActive = UIApplication.shared.statusBarOrientation.isPortrait
        spacerLandscapeConstraint?.isActive = UIApplication.shared.statusBarOrientation.isPortrait == false
    }
    
    private func mainButton(for type: Model.Button) -> UIControl {
        switch type {
        case .addToAppleWallet: return appleWalletButton
        case .save: return mainButton
        }
    }
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [mainButton(for: model.mainButtonType), secondaryButton]
        )
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 10
        stackView.preservesSuperviewLayoutMargins = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    internal lazy var logo: NetworkImageView = {
        let logo = NetworkImageView()
        let logoSize = CGSize(width: 77.0, height: 50.0)
        logo.contentMode = .scaleAspectFit
        logo.clipsToBounds = true
        logo.adyen.round(using: model.style.logoCornerRounding)
        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.widthAnchor.constraint(equalToConstant: logoSize.width).isActive = true
        logo.heightAnchor.constraint(equalToConstant: logoSize.height).isActive = true
        logo.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "logo")
        
        logo.imageURL = model.logoUrl
        
        return logo
    }()
    
    private lazy var amountLabel: UILabel = {
        let amountLabel = UILabel(style: model.style.amountLabel)
        amountLabel.text = model.amount
        amountLabel.numberOfLines = 1
        amountLabel.setContentHuggingPriority(.required, for: .horizontal)
        amountLabel.setContentHuggingPriority(.required, for: .vertical)
        amountLabel.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "amountLabel")
        
        return amountLabel
    }()
    
    private lazy var currencyLabel: UILabel = {
        let currencyLabel = UILabel(style: model.style.currencyLabel)
        currencyLabel.text = model.currency
        currencyLabel.setContentHuggingPriority(.required, for: .horizontal)
        currencyLabel.setContentHuggingPriority(.required, for: .vertical)
        currencyLabel.numberOfLines = 1
        currencyLabel.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "currencyLabel")
        
        return currencyLabel
    }()
    
    private lazy var mainButton: SubmitButton = {
        let button = SubmitButton(style: model.style.mainButton)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.title = model.mainButton
        button.addTarget(self, action: #selector(onMainButtonTap), for: .touchUpInside)
        button.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "mainButton")
        button.preservesSuperviewLayoutMargins = true
        button.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        return button
    }()
    
    private lazy var secondaryButton: UIButton = {
        let button = UIButton(style: model.style.secondaryButton)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(model.secondaryButtonTitle, for: .normal)
        button.addTarget(self, action: #selector(onSecondaryButtonTap), for: .touchUpInside)
        button.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "secondaryButton")
        button.preservesSuperviewLayoutMargins = true
        button.setContentHuggingPriority(.required, for: .vertical)
        
        return button
    }()
    
    private lazy var appleWalletButton: PKAddPassButton = {
        let button = PKAddPassButton(addPassButtonStyle: .blackOutline)
        button.addTarget(self, action: #selector(self.appleWalletButtonPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: "adyen.voucher", postfix: "appleWalletButton")
        button.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        return button
    }()
    
    @objc private func onMainButtonTap() {
        delegate?.mainButtonTap(sourceView: mainButton)
    }
    
    @objc private func onSecondaryButtonTap() {
        delegate?.secondaryButtonTap(sourceView: secondaryButton)
    }
    
    @objc private func appleWalletButtonPressed() {
        loadingView.showsActivityIndicator = true
        delegate?.addToAppleWallet { [weak self] in
            self?.loadingView.showsActivityIndicator = false
        }
    }
    
    internal func showCopyCodeConfirmation() {
        UIView.transition(
            with: secondaryButton,
            duration: 0.5,
            options: .transitionCrossDissolve,
            animations: {
                self.secondaryButton.setTitle(self.model.codeConfirmationTitle, for: .normal)
                self.secondaryButton.setTitleColor(
                    self.model.style.codeConfirmationColor,
                    for: .normal
                )
            }, completion: { _ in
                DispatchQueue.main.asyncAfter(
                    deadline: .now() + .seconds(4)
                ) {
                    self.returnSecondaryButtonToNormalState()
                }
            }
        )
    }
    
    private func returnSecondaryButtonToNormalState() {
        UIView.transition(
            with: secondaryButton,
            duration: 0.5,
            options: .transitionCrossDissolve,
            animations: {
                self.secondaryButton.setTitle(
                    self.model.secondaryButtonTitle,
                    for: .normal
                )
                self.secondaryButton.setTitleColor(
                    self.model.style.secondaryButton.title.color,
                    for: .normal
                )
            }
        )
    }
    
}
