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
    
    private var imageLoadingTask: AdyenCancellable? {
        willSet { imageLoadingTask?.cancel() }
    }
    
    internal init(model: Model) {
        self.model = model
        super.init(frame: .zero)
        
        backgroundColor = model.style.backgroundColor
        accessibilityIdentifier = "adyen.QRCode"
        
        setupUI()
    }
    
    @available(*, unavailable)
    internal required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Views
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    internal lazy var logo: UIImageView = {
        let logo = UIImageView()
        logo.adyen.round(using: model.style.logoCornerRounding)
        logo.clipsToBounds = true
        logo.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "logo")
        logo.translatesAutoresizingMaskIntoConstraints = false
        return logo
    }()
    
    private lazy var instructionLabel: UILabel = {
        let instructionLabel = UILabel(style: model.style.instructionLabel)
        instructionLabel.text = model.instruction
        instructionLabel.numberOfLines = 0
        instructionLabel.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "instructionLabel")
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        return instructionLabel
    }()
    
    private lazy var qrCodeImageView: UIImageView = {
        let qrCode = model.action.qrCodeData.generateQRCode()
        let qrCodeView = UIImageView(image: qrCode)
        qrCodeView.translatesAutoresizingMaskIntoConstraints = false
        return qrCodeView
    }()

    private lazy var amountToPayLabel: UILabel = {
        let amountToPayLabel = UILabel(style: model.style.amountToPayLabel)
        amountToPayLabel.numberOfLines = 0
        amountToPayLabel.font = UIFont.preferredFont(forTextStyle: .callout).adyen.font(with: .bold)
        if let currencyCode = model.payment?.amount.currencyCode {
            amountToPayLabel.text = model.payment?.amount.formatted
        }
        amountToPayLabel.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "amountToPayLabel")
        amountToPayLabel.translatesAutoresizingMaskIntoConstraints = false
        return amountToPayLabel
    }()
    
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView(style: model.style.progressView)
        progressView.observedProgress = model.observedProgress
        progressView.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "progressView")
        progressView.translatesAutoresizingMaskIntoConstraints = false
        return progressView
    }()
    
    internal lazy var expirationLabel: UILabel = {
        let expirationLabel = UILabel(style: model.style.expirationLabel)
        expirationLabel.numberOfLines = 0
        expirationLabel.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "expirationLabel")
        bind(model.expiration, to: expirationLabel, at: \.text) { string in
            let expirationString: String
            if let string, !string.isEmpty {
                expirationLabel.alpha = 1
                expirationString = string
            } else {
                expirationLabel.alpha = 0
                expirationString = " "
            }
            return expirationString
        }
        expirationLabel.translatesAutoresizingMaskIntoConstraints = false
        return expirationLabel
    }()
    
    private lazy var actionButton: SubmitButton = {
        switch model.actionButtonType {
        case .copyCode:
            let button = SubmitButton(style: model.style.copyCodeButton)
            button.title = localizedString(.pixCopyButton, localizationParameters)
            button.addTarget(self, action: #selector(copyCode), for: .touchUpInside)
            button.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "copyCodeButton")
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        case .saveAsImage:
            let button = SubmitButton(style: model.style.saveAsImageButton)
            button.title = localizedString(.voucherSaveImage, localizationParameters)
            button.addTarget(self, action: #selector(saveQRCodeAsImage), for: .touchUpInside)
            button.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "saveAsImageButton")
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }
    }()
    
    // MARK: Action Handling

    @objc private func saveQRCodeAsImage() {
        delegate?.saveAsImage(qrCodeImage: qrCodeImageView.adyen.snapshot(), sourceView: actionButton)
    }

    @objc private func copyCode() {
        delegate?.copyToPasteboard(with: model.action)
    }
    
    // MARK: UI Handling
    
    override public func didMoveToWindow() {
        super.didMoveToWindow()
        updateIcon()
    }
    
    private func updateIcon() {
        if window != nil {
            imageLoadingTask = logo.load(url: model.logoUrl, using: model.imageLoader)
        } else {
            imageLoadingTask = nil
        }
    }
}

// MARK: - Setup

private extension QRCodeView {
    
    func setupUI() {
        let wrapperStackView = UIStackView()
        wrapperStackView.axis = .vertical
        wrapperStackView.addArrangedSubview(scrollView)
        wrapperStackView.addArrangedSubview(actionButton)
        addSubview(wrapperStackView)
        wrapperStackView.adyen.anchor(
            inside: self.safeAreaLayoutGuide,
            with: .init(top: 0, left: 0, bottom: -8, right: 0)
        )
        
        scrollView.addSubview(stackView)
        
        stackView.addArrangedSubview(logo)
        stackView.addArrangedSubview(instructionLabel)
        stackView.addArrangedSubview(qrCodeImageView)
        stackView.addArrangedSubview(amountToPayLabel)
        stackView.addArrangedSubview(progressView)
        stackView.addArrangedSubview(expirationLabel)
        
        let logoSize = CGSize(width: 74.0, height: 48.0)
        let progressViewSize = CGSize(width: 120, height: 4)
        
        NSLayoutConstraint.activate([ // Action Button
            actionButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            actionButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),
            actionButton.heightAnchor.constraint(equalToConstant: 50.0),
            // Stack View
            stackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            // Logo
            logo.widthAnchor.constraint(equalToConstant: logoSize.width),
            logo.heightAnchor.constraint(equalToConstant: logoSize.height),
            // Instruction Label
            instructionLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.9),
            // QR Code
            qrCodeImageView.widthAnchor.constraint(equalToConstant: 170),
            qrCodeImageView.heightAnchor.constraint(equalTo: qrCodeImageView.widthAnchor),
            // Progress View
            progressView.widthAnchor.constraint(equalToConstant: progressViewSize.width),
            progressView.heightAnchor.constraint(equalToConstant: progressViewSize.height)
        ])
    }
}
