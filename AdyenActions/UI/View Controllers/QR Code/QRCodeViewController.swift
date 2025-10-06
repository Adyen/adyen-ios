//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation
import UIKit

/// A `UIViewController` that shows the QRcode action UI.
internal final class QRCodeViewController: UIViewController, AdyenObserver {
    
    private enum Layout {
        static let logoSize = CGSize(width: 74.0, height: 48.0)
        static let progressViewSize = CGSize(width: 120, height: 4)
        static let qrCodeImageWidth: CGFloat = 170
    }
    
    // MARK: - View elements
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        return view
    }()
    
    internal lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.adyen.round(using: style.logoCornerRounding)
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "logo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var instructionLabel: UILabel = {
        let instructionLabel = UILabel(style: style.instructionLabel)
        instructionLabel.text = viewModel.instruction
        instructionLabel.numberOfLines = 0
        instructionLabel.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "instructionLabel")
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        return instructionLabel
    }()
    
    private lazy var qrCodeImageView: UIImageView = {
        let size = CGSize(width: Layout.qrCodeImageWidth, height: Layout.qrCodeImageWidth)
        let qrCodeImage = viewModel.action.qrCodeData.generateQRCode(size: size)
        let qrCodeView = UIImageView(image: qrCodeImage)
        qrCodeView.translatesAutoresizingMaskIntoConstraints = false
        qrCodeView.contentMode = .scaleAspectFit
        qrCodeView.clipsToBounds = true
        return qrCodeView
    }()
    
    private lazy var amountToPayLabel: UILabel = {
        let amountToPayLabel = UILabel(style: style.amountToPayLabel)
        amountToPayLabel.numberOfLines = 0
        amountToPayLabel.font = UIFont.preferredFont(forTextStyle: .callout).adyen.font(with: .bold)
        if let currencyCode = viewModel.payment?.amount.currencyCode {
            amountToPayLabel.text = viewModel.payment?.amount.formatted
        }
        amountToPayLabel.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "amountToPayLabel")
        amountToPayLabel.translatesAutoresizingMaskIntoConstraints = false
        return amountToPayLabel
    }()
    
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView(style: style.progressView)
        progressView.observedProgress = viewModel.observedProgress
        progressView.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "progressView")
        progressView.translatesAutoresizingMaskIntoConstraints = false
        return progressView
    }()
    
    private lazy var expirationLabel: UILabel = {
        let expirationLabel = UILabel(style: style.expirationLabel)
        expirationLabel.numberOfLines = 0
        expirationLabel.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "expirationLabel")
        bind(viewModel.expiration, to: expirationLabel, at: \.text) { string in
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
        switch viewModel.flowType {
        case .copyCode:
            let title = localizedString(.pixCopyButton, localizationParameters)
            let button = CopyButton(
                title: title,
                copyTitle: "PIX code copied",
                value: viewModel.action.qrCodeData,
                style: style.copyCodeButton
            )
            button.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "copyCodeButton")
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        case .saveAsImage:
            let button = SubmitButton(style: style.saveAsImageButton)
            button.title = localizedString(.voucherSaveImage, localizationParameters)
            button.addTarget(self, action: #selector(saveQRCodeImage), for: .touchUpInside)
            button.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "saveAsImageButton")
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }
    }()
    
    private lazy var codeTextView: UIView? = {
        guard case .copyCode = viewModel.flowType else { return nil }
        let textView = UITextView()
        textView.text = "This is a very long text that needs truncation \(viewModel.action.qrCodeData)"
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
    
    private let actionContentView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fillProportionally
        return stackView
    }()
    
    private let qrCodeContentView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        return stackView
    }()
    
    // MARK: - Properties
    
    private let viewModel: QRCodeViewModel
    
    // MARK: - Initializers
    
    internal init(viewModel: QRCodeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View lifecycle
    
    override internal func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        setupViews()
        
        viewModel.loadLogoImage { [weak self] image in
            self?.logoImageView.image = image
        }
    }
    
    override internal var preferredContentSize: CGSize {
        get {
            .init(
                width: CGFloat.greatestFiniteMagnitude,
                height: .greatestFiniteMagnitude
            )
        }
        
        // swiftlint:disable:next unused_setter_value
        set { AdyenAssertion.assertionFailure(message: """
        PreferredContentSize is overridden for this view controller.
        getter - returns minimum possible content size.
        setter - no implemented.
        """) }
    }
    
    // MARK: - Actions
    
    @objc internal func saveQRCodeImage() {
        let image = qrCodeImageView.adyen.snapshot()
        viewModel.saveQRCode(image: image, sourceView: actionButton)
    }
    
    // MARK: - Private
    
    private var style: QRCodeViewStyle {
        viewModel.style
    }
    
    private var localizationParameters: LocalizationParameters? {
        viewModel.localizationParameters
    }
    
    private func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [
            qrCodeImageView,
            amountToPayLabel,
            progressView,
            expirationLabel
        ].forEach(qrCodeContentView.addArrangedSubview)
        
        [
            codeTextView,
            actionButton
        ]
        .compactMap { $0 }
        .forEach(actionContentView.addArrangedSubview)
        
        [
            logoImageView,
            instructionLabel,
            qrCodeContentView,
            actionContentView
        ]
        .forEach(contentView.addSubview)
        
        setupQRCodeContentLayout()
        setupLayout()
    }
    
    private func setupQRCodeContentLayout() {
        NSLayoutConstraint.activate([
            // QRCode Image View
            qrCodeImageView.widthAnchor.constraint(equalToConstant: Layout.qrCodeImageWidth),
            qrCodeImageView.heightAnchor.constraint(equalTo: qrCodeImageView.widthAnchor),
            
            // Progress View
            progressView.topAnchor.constraint(equalTo: amountToPayLabel.bottomAnchor, constant: 20),
            progressView.centerXAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.centerXAnchor),
            progressView.widthAnchor.constraint(equalToConstant: Layout.progressViewSize.width),
            progressView.heightAnchor.constraint(equalToConstant: Layout.progressViewSize.height),
            
            // Expiration label
            expirationLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 12)
        ])
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.frameLayoutGuide.heightAnchor),
            
            // Logo Image View
            logoImageView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor, constant: 8),
            logoImageView.centerXAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: Layout.logoSize.width),
            logoImageView.heightAnchor.constraint(equalToConstant: Layout.logoSize.height),
            
            // Instruction Label
            instructionLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 28),
            instructionLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            instructionLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            
            // QR Code Content View
            qrCodeContentView.topAnchor.constraint(greaterThanOrEqualTo: instructionLabel.bottomAnchor, constant: 20),
            qrCodeContentView.centerXAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerXAnchor),
            qrCodeContentView.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor),
            
            // Action Content View
            actionContentView.topAnchor.constraint(greaterThanOrEqualTo: qrCodeContentView.bottomAnchor, constant: 20),
            actionContentView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            actionContentView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            actionContentView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            
            // Button height
            actionButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupViews() {
        view.accessibilityIdentifier = "adyen.QRCode"
        view.backgroundColor = viewModel.style.backgroundColor
    }
}
