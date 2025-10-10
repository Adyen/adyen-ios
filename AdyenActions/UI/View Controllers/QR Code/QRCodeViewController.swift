//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation
import UIKit

/// A `UIViewController` that shows the QRcode action UI.
internal final class QRCodeViewController: UIViewController {
    
    private enum Layout {
        static let logoSize = CGSize(width: 74.0, height: 48.0)
    }
    
    private enum ViewIdentifier {
        static let view = "adyen.QRCode"
        static let logo = "logo"
        static let instructionLabel = "instructionLabel"
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
        
    private let actionContentView: UIStackView = {
        let stackView = UIStackView()
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
        return instructionLabel
    }()
    
    private lazy var qrCodeView = QRCodeView(viewModel: viewModel, style: style)
    
    private lazy var actionButton: SubmitButton = {
        switch viewModel.flowType {
        case .copyCode:
            let button = SubmitButton(style: style.copyCodeButton)
            button.title = viewModel.actionButtonTitle
            button.addTarget(self, action: #selector(copyCode), for: .touchUpInside)
            button.accessibilityIdentifier = ViewIdentifierBuilder.build(
                scopeInstance: self,
                postfix: ViewIdentifier.copyCodeButton
            )
            return button
        case .saveAsImage:
            let button = SubmitButton(style: style.saveAsImageButton)
            button.title = viewModel.actionButtonTitle
            button.addTarget(self, action: #selector(saveQRCodeImage), for: .touchUpInside)
            button.accessibilityIdentifier = ViewIdentifierBuilder.build(
                scopeInstance: self,
                postfix: ViewIdentifier.saveAsImageButton
            )
            return button
        }
    }()
    
    private lazy var copyCodeLabel: CopyLabelView? = {
        guard case .copyCode = viewModel.flowType else { return nil }
        
        let textStyle = TextStyle(
            font: .systemFont(ofSize: 20, weight: .semibold),
            color: UIColor.Adyen.componentLabel
        )
        let copyLabelView = CopyLabelView(
            text: viewModel.qrCodeData,
            style: textStyle
        )
        copyLabelView.adyen.round(using: style.logoCornerRounding)
        copyLabelView.layoutMargins = .init(top: 8, left: 32, bottom: 8, right: 32)
        
        return copyLabelView
    }()
    
    // MARK: - Properties
    
    private let viewModel: QRCodeViewModelProtocol
    private let style: QRCodeViewStyle
    
    // MARK: - Initializers
    
    internal init(viewModel: QRCodeViewModelProtocol, style: QRCodeViewStyle) {
        self.viewModel = viewModel
        self.style = style
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View lifecycle
    
    override internal func viewDidLoad() {
        super.viewDidLoad()
        buildViewHierarchy()
        setupLayoutConstraints()
        configureAppearance()
        
        loadLogoImage()
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
    
    @objc private func saveQRCodeImage() {
        let image = qrCodeView.imageView.adyen.snapshot()
        viewModel.saveQRCode(image: image, sourceView: view)
    }
    
    @objc private func copyCode() {
        viewModel.copyCode()
        animateCopyButton()
    }
    
    private func animateCopyButton() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
                
        UIView.transition(with: actionButton, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.actionButton.title = self.viewModel.onCopyButtonTitle
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            UIView.transition(with: self.actionButton, duration: 0.25, options: .transitionCrossDissolve, animations: {
                self.actionButton.title = self.viewModel.actionButtonTitle
            })
        }
    }
        
    // MARK: - Private
    
    private func loadLogoImage() {
        viewModel.loadLogoImage { [weak self] image in
            self?.logoImageView.image = image
        }
    }
        
    private func buildViewHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [copyCodeLabel, actionButton]
            .compactMap { $0 }
            .forEach(actionContentView.addArrangedSubview)

        [logoImageView, instructionLabel, qrCodeView, actionContentView]
            .forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
                contentView.addSubview($0)
            }
    }
    
    private func setupLayoutConstraints() {
        scrollView.adyen.anchor(inside: view.safeAreaLayoutGuide)
        contentView.adyen.anchor(inside: scrollView.contentLayoutGuide)
        
        let margins = contentView.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            
            // MARK: - ContentView
            
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.frameLayoutGuide.heightAnchor),
            
            // MARK: - Logo
            
            logoImageView.topAnchor.constraint(equalTo: margins.topAnchor, constant: 8),
            logoImageView.centerXAnchor.constraint(equalTo: margins.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: Layout.logoSize.width),
            logoImageView.heightAnchor.constraint(equalToConstant: Layout.logoSize.height),
            
            // MARK: - Instruction Label
            
            instructionLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 28),
            instructionLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            instructionLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            
            // MARK: - QRCode View
            
            qrCodeView.topAnchor.constraint(greaterThanOrEqualTo: instructionLabel.bottomAnchor, constant: 20),
            qrCodeView.centerXAnchor.constraint(equalTo: margins.centerXAnchor),
            qrCodeView.centerYAnchor.constraint(equalTo: margins.centerYAnchor),
            
            // MARK: - Action Content Stack
            
            actionContentView.topAnchor.constraint(greaterThanOrEqualTo: qrCodeView.bottomAnchor, constant: 20),
            actionContentView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            actionContentView.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            actionContentView.bottomAnchor.constraint(equalTo: margins.bottomAnchor),
            actionButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func configureAppearance() {
        view.accessibilityIdentifier = ViewIdentifier.view
        view.backgroundColor = style.backgroundColor
    }
}
