//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

internal final class VoucherView: UIView, Localizable {
    
    // :nodoc:
    private let model: Model
    
    internal init(model: Model) {
        self.model = model

        super.init(frame: .zero)
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
    
    private func buildUI() {
        let firstSpacer = UIView()
        firstSpacer.translatesAutoresizingMaskIntoConstraints = false
        firstSpacer.backgroundColor = .red
        let secondSpacer = UIView()
        secondSpacer.translatesAutoresizingMaskIntoConstraints = false
        secondSpacer.backgroundColor = .blue
        
        addSubview(logo)
        addSubview(firstSpacer)
        addSubview(amountLabel)
        addSubview(secondSpacer)
        addSubview(currencyLabel)
        addSubview(mainButton)
        addSubview(secondaryButton)

        NSLayoutConstraint.activate([
            logo.topAnchor.constraint(equalTo: topAnchor),
            logo.centerXAnchor.constraint(equalTo: centerXAnchor),
            firstSpacer.topAnchor.constraint(equalTo: logo.topAnchor),
            firstSpacer.heightAnchor.constraint(equalToConstant: 80.0),
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
            mainButton.topAnchor.constraint(equalTo: secondSpacer.bottomAnchor),
            mainButton.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            mainButton.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            secondaryButton.centerXAnchor.constraint(equalTo: mainButton.centerXAnchor),
            secondaryButton.topAnchor.constraint(equalTo: mainButton.bottomAnchor),
            secondaryButton.widthAnchor.constraint(equalTo: mainButton.widthAnchor),
            secondaryButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private lazy var logo: NetworkImageView = {
        let logo = NetworkImageView()
        let logoSize = CGSize(width: 97.0, height: 56.0)
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
        amountLabel.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "instructionLabel")
        
        return amountLabel
    }()
    
    private lazy var currencyLabel: UILabel = {
        let currencyLabel = UILabel(style: model.style.currencyLabel)
        currencyLabel.text = model.currency
        currencyLabel.setContentHuggingPriority(.required, for: .horizontal)
        currencyLabel.setContentHuggingPriority(.required, for: .vertical)
        currencyLabel.numberOfLines = 1
        currencyLabel.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "instructionLabel")
        
        return currencyLabel
    }()
    
    private lazy var mainButton: SubmitButton = {
        let button = SubmitButton(style: model.style.actionButton)
        button.title = model.primaryButtonTitle
        button.addTarget(self, action: #selector(onMainButtonTap), for: .touchUpInside)
        button.accessibilityIdentifier = "mainButton"
        button.preservesSuperviewLayoutMargins = true
        
        return button
    }()
    
    private lazy var secondaryButton: SubmitButton = {
        let button = SubmitButton(style: model.style.closeButton)
        button.title = model.secondaryButtonTitle
        button.addTarget(self, action: #selector(onSecondaryButtonTap), for: .touchUpInside)
        button.accessibilityIdentifier = "secondaryButton"
        button.preservesSuperviewLayoutMargins = true
        
        return button
    }()
    
    @objc private func onMainButtonTap() {
        
    }
    
    @objc private func onSecondaryButtonTap() {
        
    }
    
}
