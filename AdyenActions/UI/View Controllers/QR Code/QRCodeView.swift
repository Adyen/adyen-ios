//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

internal protocol QRCodeViewDelegate: class {

    func copyToPasteboard()
}

internal final class QRCodeView: UIView, Localizable {
    
    private let model: Model
    
    /// The delegate of the view
    internal weak var delegate: QRCodeViewDelegate?
    
    // :nodoc:
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
        addCopyButton()
    }
    
    internal override func layoutSubviews() {
        super.layoutSubviews()
        
        copyButton.adyen.round(using: model.style.copyButton.cornerRounding)
    }
    
    private func addInstructionLabel() {
        addSubview(instructionLabel)
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            instructionLabel.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: 24),
            instructionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 37),
            instructionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -37.0)
        ])
    }
    
    private func addLogo() {
        addSubview(logo)
        logo.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logo.bottomAnchor.constraint(equalTo: topAnchor, constant: 10),
            logo.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    private func addCopyButton() {
        addSubview(copyButton)
        copyButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            copyButton.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 29),
            copyButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            copyButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            copyButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -18)
        ])
    }
    
    private lazy var copyButton: SubmitButton = {
        let accessiblityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "copyButton")
        
        let button = SubmitButton(style: model.style.copyButton)
        button.title = ADYLocalizedString("adyen.button.copy", localizationParameters)
        button.addTarget(self, action: #selector(copyCode), for: .touchUpInside)
        button.accessibilityIdentifier = accessibilityIdentifier
        
        return button
    }()
    
    private lazy var logo: NetworkImageView = {
        let logo = NetworkImageView()
        let logoSize = CGSize(width: 74.0, height: 48.0)
        logo.widthAnchor.constraint(equalToConstant: logoSize.width).isActive = true
        logo.heightAnchor.constraint(equalToConstant: logoSize.height).isActive = true
        
        logo.imageURL = model.logoUrl
        
        return logo
    }()
    
    private lazy var instructionLabel: UILabel = {
        let instructionLabel = UILabel()
        let style = model.style.instructionLabel
        instructionLabel.font = style.font
        instructionLabel.adjustsFontForContentSizeCategory = true
        instructionLabel.textColor = style.color
        instructionLabel.textAlignment = .center
        instructionLabel.backgroundColor = style.backgroundColor
        instructionLabel.text = model.instruction
        instructionLabel.numberOfLines = 0
        
        return instructionLabel
    }()
        
    @objc private func copyCode() {
        delegate?.copyToPasteboard()
    }

}
