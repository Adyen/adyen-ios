//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

internal protocol QRCodeViewDelegate: AnyObject {
    
    func saveAsImage(qrCodeImage: UIImage?, sourceView: UIView)

    func copyToPasteboard(with action: QRCodeAction)
}

internal final class QRCodeView: UIView, Localizable, AdyenObserver {
    
    private let model: Model
    
    /// The delegate of the view
    internal weak var delegate: QRCodeViewDelegate?
    
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
        addQRCodeImage()
        addAmountToPay()
        addProgressView()
        addExpirationLabel()
        switch model.actionButtonType {
        case .copyCode:
            addCopyCodeButton()
        case .saveAsImage:
            addSaveAsImageButton()
        }
    }
    
    override internal func layoutSubviews() {
        super.layoutSubviews()
        
        saveAsImageButton.adyen.round(using: model.style.saveAsImageButton.cornerRounding)
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

    private func addQRCodeImage() {
        addSubview(qrCodeImageView)
        qrCodeImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            qrCodeImageView.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 45),
            qrCodeImageView.widthAnchor.constraint(equalToConstant: 145.0),
            qrCodeImageView.heightAnchor.constraint(equalToConstant: 144.0),
            qrCodeImageView.centerXAnchor.constraint(equalTo: layoutMarginsGuide.centerXAnchor)
        ])
    }

    private func addAmountToPay() {
        addSubview(amountToPayLabel)
        amountToPayLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            amountToPayLabel.topAnchor.constraint(equalTo: qrCodeImageView.bottomAnchor, constant: 22.0),
            amountToPayLabel.centerXAnchor.constraint(equalTo: layoutMarginsGuide.centerXAnchor)
        ])
    }

    private func addProgressView() {
        addSubview(progressView)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: amountToPayLabel.bottomAnchor, constant: 24.0),
            progressView.centerXAnchor.constraint(equalTo: layoutMarginsGuide.centerXAnchor)
        ])
    }
    
    private func addExpirationLabel() {
        addSubview(expirationLabel)
        expirationLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            expirationLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 13.0),
            expirationLabel.heightAnchor.constraint(equalToConstant: 20.0),
            expirationLabel.centerXAnchor.constraint(equalTo: layoutMarginsGuide.centerXAnchor)
        ])
    }
    
    private func addSaveAsImageButton() {
        addSubview(saveAsImageButton)
        saveAsImageButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            saveAsImageButton.heightAnchor.constraint(equalToConstant: 50.0),
            saveAsImageButton.topAnchor.constraint(equalTo: expirationLabel.bottomAnchor, constant: 40),
            saveAsImageButton.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: 16),
            saveAsImageButton.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: -16),
            saveAsImageButton.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ])
    }

    private func addCopyCodeButton() {
        addSubview(copyCodeButton)
        copyCodeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            copyCodeButton.heightAnchor.constraint(equalToConstant: 50.0),
            copyCodeButton.topAnchor.constraint(equalTo: expirationLabel.bottomAnchor, constant: 34),
            copyCodeButton.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: 16),
            copyCodeButton.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: -16),
            copyCodeButton.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ])
    }

    private lazy var saveAsImageButton: SubmitButton = {
        let button = SubmitButton(style: model.style.saveAsImageButton)
        button.title = localizedString(.voucherSaveImage, localizationParameters)
        button.addTarget(self, action: #selector(saveQRCodeAsImage), for: .touchUpInside)
        button.accessibilityIdentifier = "saveAsImageButton"

        return button
    }()

    private lazy var copyCodeButton: SubmitButton = {
        let button = SubmitButton(style: model.style.copyCodeButton)
        button.title = localizedString(.pixCopyButton, localizationParameters)
        button.addTarget(self, action: #selector(copyCode), for: .touchUpInside)
        button.accessibilityIdentifier = "copyCodeButton"
        
        return button
    }()

    internal lazy var logo: NetworkImageView = {
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
    
    private lazy var qrCodeImageView: UIImageView = {
        let data = model.action.qrCodeData.data(using: String.Encoding.ascii)
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            return UIImageView()
        }
        filter.setValue(data, forKey: "inputMessage")
        let transform = CGAffineTransform(scaleX: 3, y: 3)

        guard let output = filter.outputImage?.transformed(by: transform) else {
            return UIImageView()
        }
        return UIImageView(image: UIImage(ciImage: output))
    }()

    private lazy var amountToPayLabel: UILabel = {
        let amountToPayLabel = UILabel(style: model.style.amountToPayLabel)
        amountToPayLabel.numberOfLines = 0
        amountToPayLabel.font = UIFont.preferredFont(forTextStyle: .callout).adyen.font(with: .bold)
        if let currencyCode = model.payment?.amount.currencyCode {
            amountToPayLabel.text = model.payment?.amount.formatted
        }
        amountToPayLabel.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "amountToPayLabel")
        
        return amountToPayLabel
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
    
    internal lazy var expirationLabel: UILabel = {
        let expirationLabel = UILabel(style: model.style.expirationLabel)
        expirationLabel.numberOfLines = 0
        expirationLabel.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "expirationLabel")
        
        bind(model.expiration, to: expirationLabel, at: \.text)
        
        return expirationLabel
    }()

    @objc private func saveQRCodeAsImage() {
        delegate?.saveAsImage(qrCodeImage: qrCodeImageView.adyen.snapShot(), sourceView: saveAsImageButton)
    }

    @objc private func copyCode() {
        delegate?.copyToPasteboard(with: model.action)
    }

}
