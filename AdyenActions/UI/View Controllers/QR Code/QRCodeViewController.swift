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
    
    private enum ViewIdentifier {
        static let view = "adyen.QRCode"
        static let logo = "logo"
        static let instructionLabel = "instructionLabel"
        static let amountToPayLabel = "amountToPayLabel"
        static let progressView = "progressView"
        static let expirationLabel = "expirationLabel"
        static let copyCodeButton = "copyCodeButton"
        static let saveAsImageButton = "saveAsImageButton"
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
    
    private let qrCodeContentView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        return stackView
    }()
    
    private let actionContentView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        return stackView
    }()
    
    internal lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.adyen.round(using: style.logoCornerRounding)
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.accessibilityIdentifier = ViewIdentifierBuilder.build(
            scopeInstance: self,
            postfix: ViewIdentifier.logo
        )
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var instructionLabel: UILabel = {
        let instructionLabel = UILabel(style: style.instructionLabel)
        instructionLabel.text = viewModel.instructionText
        instructionLabel.numberOfLines = 0
        instructionLabel.accessibilityIdentifier = ViewIdentifierBuilder.build(
            scopeInstance: self,
            postfix: ViewIdentifier.instructionLabel
        )
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        return instructionLabel
    }()
    
    private lazy var qrCodeImageView: UIImageView = {
        let size = CGSize(width: Layout.qrCodeImageWidth, height: Layout.qrCodeImageWidth)
        let qrCodeImage = viewModel.qrCodeData.generateQRCode(size: size)
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
        amountToPayLabel.text = viewModel.amountText
        amountToPayLabel.accessibilityIdentifier = ViewIdentifierBuilder.build(
            scopeInstance: self,
            postfix: ViewIdentifier.amountToPayLabel
        )
        amountToPayLabel.translatesAutoresizingMaskIntoConstraints = false
        return amountToPayLabel
    }()
    
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView(style: style.progressView)
        progressView.observedProgress = viewModel.observedProgress
        progressView.accessibilityIdentifier = ViewIdentifierBuilder.build(
            scopeInstance: self,
            postfix: ViewIdentifier.progressView
        )
        progressView.translatesAutoresizingMaskIntoConstraints = false
        return progressView
    }()
    
    private lazy var expirationLabel: UILabel = {
        let expirationLabel = UILabel(style: style.expirationLabel)
        expirationLabel.numberOfLines = 0
        expirationLabel.accessibilityIdentifier = ViewIdentifierBuilder.build(
            scopeInstance: self,
            postfix: ViewIdentifier.expirationLabel
        )
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
            let button = CopyButton(
                title: viewModel.actionButtonTitle,
                copyTitle: "Code copied",
                value: viewModel.qrCodeData,
                style: style.copyCodeButton
            )
            button.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: ViewIdentifier.copyCodeButton)
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        case .saveAsImage:
            let button = SubmitButton(style: style.saveAsImageButton)
            button.title = viewModel.actionButtonTitle
            button.addTarget(self, action: #selector(saveQRCodeImage), for: .touchUpInside)
            button.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: ViewIdentifier.saveAsImageButton)
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }
    }()
    
    private lazy var codeTextView: UIView? = {
        guard case .copyCode = viewModel.flowType else { return nil }
        
        let textStyle = TextStyle(font: .systemFont(ofSize: 20, weight: .semibold), color: .black)
        let copyLabelView = CopyLabelView(
            text: viewModel.qrCodeData,
            style: textStyle
        )
        return copyLabelView
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
        viewModel.saveQRCode(image: image, sourceView: view)
    }
    
    // MARK: - Private
    
    private var style: QRCodeViewStyle {
        viewModel.style
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
        
        setupLayout()
    }
    
    private func setupLayout() {
        scrollView.adyen.anchor(inside: view.safeAreaLayoutGuide)
        contentView.adyen.anchor(inside: scrollView.contentLayoutGuide)
        
        NSLayoutConstraint.activate([
            
            // MARK: - ContentView

            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.frameLayoutGuide.heightAnchor),
            
            // MARK: - Logo

            logoImageView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor, constant: 8),
            logoImageView.centerXAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: Layout.logoSize.width),
            logoImageView.heightAnchor.constraint(equalToConstant: Layout.logoSize.height),
            
            // MARK: - QR Code Image

            qrCodeImageView.widthAnchor.constraint(equalToConstant: Layout.qrCodeImageWidth),
            qrCodeImageView.heightAnchor.constraint(equalTo: qrCodeImageView.widthAnchor),
            
            // MARK: - Progress View

            progressView.widthAnchor.constraint(equalToConstant: Layout.progressViewSize.width),
            progressView.heightAnchor.constraint(equalToConstant: Layout.progressViewSize.height),
            expirationLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 12),
            
            // MARK: - Instruction Label

            instructionLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 28),
            instructionLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            instructionLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            
            // MARK: - QR Code Content Stack

            qrCodeContentView.topAnchor.constraint(greaterThanOrEqualTo: instructionLabel.bottomAnchor, constant: 20),
            qrCodeContentView.centerXAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerXAnchor),
            qrCodeContentView.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor),
            
            // MARK: - Action Content Stack

            actionContentView.topAnchor.constraint(greaterThanOrEqualTo: qrCodeContentView.bottomAnchor, constant: 20),
            actionContentView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            actionContentView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            actionContentView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            actionButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func setupViews() {
        view.accessibilityIdentifier = ViewIdentifier.view
        view.backgroundColor = viewModel.style.backgroundColor
    }
}
