//
// Copyright (c) 2020 Adyen N.V.
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
        static let contentViewMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        static let copyLabelViewMargins = UIEdgeInsets(top: 8, left: 32, bottom: 8, right: 32)
    }
    
    private enum ViewIdentifier {
        static let view = "adyen.QRCode"
        static let logo = "logo"
        static let instructionLabel = "instructionLabel"
        static let copyCodeButton = "copyCodeButton"
        static let saveAsImageButton = "saveAsImageButton"
    }
    
    // MARK: - View elements
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layoutMargins = Layout.contentViewMargins
        return view
    }()
        
    private lazy var actionContentView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        return stackView
    }()
    
    internal private(set) lazy var logoImageView: UIImageView = {
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
    
    internal private(set) lazy var instructionLabel: UILabel = {
        let instructionLabel = UILabel(style: style.instructionLabel)
        instructionLabel.text = viewModel.instructionText
        instructionLabel.numberOfLines = 0
        instructionLabel.accessibilityIdentifier = ViewIdentifierBuilder.build(
            scopeInstance: self,
            postfix: ViewIdentifier.instructionLabel
        )
        return instructionLabel
    }()
    
    internal private(set) lazy var qrCodeView = QRCodeView(viewModel: viewModel, style: style)
        
    internal private(set) lazy var actionButton: SubmitButton = {
        let button = SubmitButton(style: actionButtonStyle)
        
        button.title = viewModel.actionButtonTitle
        button.accessibilityIdentifier = ViewIdentifierBuilder.build(
            scopeInstance: self,
            postfix: actionButtonAccessibilityIdentifier
        )
        button.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        
        bindCopyInProgress()
        
        return button
    }()
    
    internal private(set) lazy var copyCodeLabel: CopyLabelView? = {
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
        copyLabelView.layoutMargins = Layout.copyLabelViewMargins
        
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
    
    private func bindCopyInProgress() {
        observe(viewModel.copyInProgress) { [weak self] copyInProgress in
            guard let self else { return }
            performCopyAnimation(inProgress: copyInProgress)
        }
    }
    
    private func performCopyAnimation(inProgress: Bool) {
        let title: String
        
        if inProgress {
            title = viewModel.onCopyButtonTitle
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        } else {
            title = viewModel.actionButtonTitle
        }
        
        UIView.transition(with: actionButton, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.actionButton.title = title
        })
    }
    
    @objc private func actionButtonTapped() {
        let qrCodeImage = qrCodeView.imageView.adyen.snapshot()
        viewModel.performAction(qrCodeImage: qrCodeImage, from: view)
    }
            
    // MARK: - Private
    
    private var actionButtonStyle: ButtonStyle {
        switch viewModel.flowType {
        case .copyCode:
            return style.copyCodeButton
        case .saveCodeAsImage:
            return style.saveAsImageButton
        }
    }
    
    private var actionButtonAccessibilityIdentifier: String {
        switch viewModel.flowType {
        case .copyCode:
            return ViewIdentifier.copyCodeButton
        case .saveCodeAsImage:
            return ViewIdentifier.saveAsImageButton
        }
    }
    
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
            qrCodeView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            qrCodeView.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
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
