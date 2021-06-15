//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

internal protocol QRCodeViewDelegate: AnyObject {

    func copyToPasteboard()
}

internal final class QRCodeView: UIView, Localizable, Observer {
    
    private let model: Model
    
    /// The delegate of the view
    internal weak var delegate: QRCodeViewDelegate?
    
    /// :nodoc:
    public var localizationParameters: LocalizationParameters?
    
    internal init(model: Model) {
        self.model = model
        super.init(frame: .zero)
        buildUI()
        backgroundColor = model.style.backgroundColor
        
        accessibilityIdentifier = "adyen.QRCode"
    }
    
    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildUI() {
        addLogo()
        addInstructionLabel()
        addProgressView()
        addExpirationLabel()
        addCopyButton()
    }
    
    override internal func layoutSubviews() {
        super.layoutSubviews()
        
        copyButton.adyen.round(using: model.style.copyButton.cornerRounding)
    }
    
    private func addLogo() {
        addSubview(logo)
        logo.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logo.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            logo.centerXAnchor.constraint(equalTo: layoutMarginsGuide.centerXAnchor)
        ])
    }
    
    private func addInstructionLabel() {
        addSubview(instructionLabel)
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            instructionLabel.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: 20),
            instructionLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: 37),
            instructionLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: -37.0)
        ])
    }
    
    private func addProgressView() {
        addSubview(progressView)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 24.0),
            progressView.centerXAnchor.constraint(equalTo: layoutMarginsGuide.centerXAnchor)
        ])
    }
    
    private func addExpirationLabel() {
        addSubview(expirationLabel)
        expirationLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            expirationLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 13.0),
            expirationLabel.centerXAnchor.constraint(equalTo: layoutMarginsGuide.centerXAnchor)
        ])
    }
    
    private func addCopyButton() {
        addSubview(copyButton)
        copyButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            copyButton.heightAnchor.constraint(equalToConstant: 50.0),
            copyButton.topAnchor.constraint(equalTo: expirationLabel.bottomAnchor, constant: 34),
            copyButton.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: 16),
            copyButton.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: -16),
            copyButton.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ])
    }
    
    private lazy var copyButton: SubmitButton = {
        let button = SubmitButton(style: model.style.copyButton)
        button.title = localizedString(.pixCopyButton, localizationParameters)
        button.addTarget(self, action: #selector(copyCode), for: .touchUpInside)
        button.accessibilityIdentifier = "copyButton"
        
        return button
    }()
    
    private lazy var logo: NetworkImageView = {
        let logo = NetworkImageView()
        let logoSize = CGSize(width: 74.0, height: 48.0)
        logo.adyen.round(using: model.style.logoCornerRounding)
        logo.clipsToBounds = true
        logo.widthAnchor.constraint(equalToConstant: logoSize.width).isActive = true
        logo.heightAnchor.constraint(equalToConstant: logoSize.height).isActive = true
        logo.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "logo")
        
        logo.imageURL = model.logoUrl
        
        return logo
    }()
    
    private lazy var instructionLabel: UILabel = {
        let instructionLabel = UILabel(style: model.style.instructionLabel)
        instructionLabel.text = model.instruction
        instructionLabel.numberOfLines = 0
        instructionLabel.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "instructionLabel")
        
        return instructionLabel
    }()
    
    private lazy var progressView: UIProgressView = {
        let progressViewSize = CGSize(width: 120, height: 4)
        let progressView = UIProgressView(style: model.style.progressView)
        progressView.observedProgress = model.observedProgress
        progressView.widthAnchor.constraint(equalToConstant: progressViewSize.width).isActive = true
        progressView.heightAnchor.constraint(equalToConstant: progressViewSize.height).isActive = true
        progressView.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "progressView")
        
        return progressView
    }()
    
    private lazy var expirationLabel: UILabel = {
        let expirationLabel = UILabel(style: model.style.expirationLabel)
        expirationLabel.numberOfLines = 1
        expirationLabel.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "expirationLabel")

        bind(model.expiration, to: expirationLabel, at: \.text)
        
        return expirationLabel
    }()
        
    @objc private func copyCode() {
        delegate?.copyToPasteboard()
    }

}
