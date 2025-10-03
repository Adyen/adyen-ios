//
// Copyright (c) 2025 Adyen N.V.
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
        
    // MARK: - Properties
    
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
        
        setupViews()
    }
    
    @available(*, unavailable)
    internal required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UI elements
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIStackView = {
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
        let qrCodeImage = model.action.qrCodeData.generateQRCode()
        let qrCodeView = UIImageView(image: qrCodeImage)
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
    
    internal lazy var progressView: UIProgressView = {
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
    
    private lazy var actionButton: UIView = {
        switch model.actionButtonType {
        case .copyCode:
            let title = localizedString(.pixCopyButton, localizationParameters)
            let button = CopyButton(
                title: title,
                copyTitle: "PIX code copied",
                value: model.action.qrCodeData,
                style: model.style.copyCodeButton
            )
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
    
    private lazy var codeTextView: UIView = {
        let textView = UITextView()
        textView.text = "This is a very long text that needs truncation \(model.action.qrCodeData)"
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.isSelectable = true
        textView.backgroundColor = .lightGray
        textView.layer.cornerRadius = 8
        textView.textContainer.lineBreakMode = .byTruncatingMiddle
        textView.textContainer.maximumNumberOfLines = 1
        textView.textContainerInset = .init(top: 4, left: 4, bottom: 4, right: 4)
        textView.textContainer.lineFragmentPadding = 0
        //        return textView
        
        let copyLabelView = CopyLabelView(
            text: textView.text,
            style: .init(font: .systemFont(ofSize: 16), color: .black)
        )
        return copyLabelView
    }()
    
    // MARK: Action Handling
    
    @objc private func saveQRCodeAsImage() {
        delegate?.saveAsImage(qrCodeImage: qrCodeImageView.adyen.snapshot(), sourceView: actionButton)
    }
    
    //    @objc private func copyCode() {
    //        delegate?.copyToPasteboard(with: model.action)
    //    }
    
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

// MARK: - Private

private extension QRCodeView {
    
    private enum Layout {
        static let logoSize = CGSize(width: 74.0, height: 48.0)
        static let progressViewSize = CGSize(width: 120, height: 4)
    }
        
    func setupViews() {
        addSubview(scrollView)
        
        contentView.addArrangedSubview(logo)
        contentView.addArrangedSubview(instructionLabel)
        contentView.addArrangedSubview(qrCodeImageView)
        contentView.addArrangedSubview(amountToPayLabel)
        contentView.addArrangedSubview(progressView)
        contentView.addArrangedSubview(expirationLabel)
        contentView.addArrangedSubview(codeTextView)
        
        scrollView.addSubview(contentView)
        scrollView.addSubview(actionButton)
        
        setupLayout()
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            // ScrollView edges
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            
            // ContentView inside scrollView
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            // Action button pinned to safe area
            actionButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            actionButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),
            actionButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16),
            actionButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            // Logo
            logo.widthAnchor.constraint(equalToConstant: Layout.logoSize.width),
            logo.heightAnchor.constraint(equalToConstant: Layout.logoSize.height),
            
            // Instruction label
            instructionLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9),
            
            // QR code image view
            qrCodeImageView.widthAnchor.constraint(equalToConstant: 170),
            qrCodeImageView.heightAnchor.constraint(equalTo: qrCodeImageView.widthAnchor),
            
            // Progress View
            progressView.widthAnchor.constraint(equalToConstant: Layout.progressViewSize.width),
            progressView.heightAnchor.constraint(equalToConstant: Layout.progressViewSize.height)
        ])
        
    }
}
