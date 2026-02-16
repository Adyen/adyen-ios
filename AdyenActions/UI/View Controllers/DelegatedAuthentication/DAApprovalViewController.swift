//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

@available(iOS 16.0, *)
internal final class DAApprovalViewController: UIViewController {
    private let style: DelegatedAuthenticationComponentStyle
    private let localizationParameters: LocalizationParameters?
    private let cardNumber: String?
    private let cardType: CardType?
    private let amount: String?
    private let cardLogoURL: URL?
    private let useBiometricsHandler: VoidHandler
    private let approveDifferentlyHandler: VoidHandler
    private let removeCredentialsHandler: VoidHandler
    private let imageLoader: ImageLoading = ImageLoaderProvider.imageLoader()
    
    private lazy var removeCredentialAlert: UIAlertController = {
        let alertController = UIAlertController(
            title: localizedString(.threeds2DAApprovalRemoveAlertTitle, localizationParameters),
            message: localizedString(.threeds2DAApprovalRemoveAlertDescription, localizationParameters),
            preferredStyle: .alert
        )
        let removeAction = UIAlertAction(
            title: localizedString(.threeds2DAApprovalRemoveAlertPositiveButton, localizationParameters),
            style: .destructive,
            handler: { [weak self] _ in
                self?.removeCredentialsHandler()
            }
        )
        let cancelAction = UIAlertAction(
            title: localizedString(.threeds2DAApprovalRemoveAlertNegativeButton, localizationParameters),
            style: .cancel,
            handler: nil
        )
        alertController.addAction(cancelAction)
        alertController.addAction(removeAction)
        return alertController
    }()
    
    private lazy var actionSheet: UIAlertController = {
        let alertController = UIAlertController(
            title: localizedString(.threeds2DAApprovalActionSheetTitle, localizationParameters),
            message: nil,
            preferredStyle: .actionSheet
        )
        let removeAction = UIAlertAction(
            title: localizedString(.threeds2DAApprovalActionSheetRemove, localizationParameters),
            style: .destructive,
            handler: { [weak self] _ in
                guard let self else { return }
                self.present(self.removeCredentialAlert, animated: true)
            }
        )
        let fallbackAction = UIAlertAction(
            title: localizedString(.threeds2DAApprovalActionSheetFallback, localizationParameters),
            style: .default,
            handler: { [weak self] _ in
                self?.approveDifferentlyHandler()
            }
        )
        let cancelAction = UIAlertAction(
            title: localizedString(.threeds2DAApprovalRemoveAlertNegativeButton, localizationParameters),
            style: .cancel
        )
        alertController.addAction(cancelAction)
        alertController.addAction(fallbackAction)
        alertController.addAction(removeAction)
        return alertController
    }()

    private lazy var approvalView: DelegatedAuthenticationView = .init(style: style)
        
    // MARK: - init
    
    internal init(
        style: DelegatedAuthenticationComponentStyle,
        localizationParameters: LocalizationParameters?,
        logoProvider: LogoURLProvider,
        amount: String?,
        cardNumber: String?,
        cardType: CardType?,
        useBiometricsHandler: @escaping VoidHandler,
        approveDifferentlyHandler: @escaping VoidHandler,
        removeCredentialsHandler: @escaping VoidHandler
    ) {
        self.style = style
        self.useBiometricsHandler = useBiometricsHandler
        self.approveDifferentlyHandler = approveDifferentlyHandler
        self.removeCredentialsHandler = removeCredentialsHandler
        self.localizationParameters = localizationParameters
        self.amount = amount
        self.cardType = cardType
        self.cardNumber = cardNumber
        self.cardLogoURL = cardType.map(\.rawValue).map { logoProvider.logoURL(withName: $0) }
        super.init(nibName: nil, bundle: Bundle(for: DAApprovalViewController.self))
        approvalView.delegate = self
    }
    
    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    
    override internal func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = style.backgroundColor
        configureDelegateAuthenticationView()
        buildUI()
        approvalView.animateImageTransitionToSystemImage(named: "lock.open")
        isModalInPresentation = true
    }
    
    // MARK: - Configuration
    
    private func configureDelegateAuthenticationView() {
        approvalView.titleLabel.text = localizedString(.threeds2DAApprovalTitle, localizationParameters)
        approvalView.descriptionLabel.text = localizedString(.threeds2DAApprovalDescription, localizationParameters)
        approvalView.firstButton.title = localizedString(.threeds2DAApprovalPositiveButton, localizationParameters)
        approvalView.secondButton.title = localizedString(.threeds2DAApprovalNegativeButton, localizationParameters)
        approvalView.additionalInformationStackView.isHidden = true

        approvalView.cardAndAmountDetailsStackView.isHidden = true
        approvalView.cardNumberStackView.isHidden = true

        if let cardNumber, let cardLogoURL {
            approvalView.cardAndAmountDetailsStackView.isHidden = false
            approvalView.cardNumberStackView.isHidden = false
            approvalView.cardNumberLabel.text = cardNumber
            self.approvalView.cardImage.isHidden = true
            imageLoader.load(url: cardLogoURL) { [weak self] image in
                guard let self, let image else { return }
                self.approvalView.cardImage.isHidden = false
                self.approvalView.cardImage.image = image
            }
        }

        if let amount {
            approvalView.amount.text = amount
            approvalView.cardAndAmountDetailsStackView.isHidden = false
        }
    }
    
    private func buildUI() {
        view.addSubview(approvalView)
        approvalView.translatesAutoresizingMaskIntoConstraints = false
        approvalView.adyen.anchor(inside: view.safeAreaLayoutGuide)
    }
    
    override internal var preferredContentSize: CGSize {
        get {
            UIView.layoutFittingExpandedSize
        }
        
        // swiftlint:disable:next unused_setter_value
        set { AdyenAssertion.assertionFailure(message: """
        PreferredContentSize is overridden for this view controller.
        getter - returns minimum possible content size.
        setter - not implemented.
        """) }
    }
}

@available(iOS 16.0, *)
extension DAApprovalViewController: DelegatedAuthenticationViewDelegate {
    internal func firstButtonTapped() {
        useBiometricsHandler()
    }
    
    internal func secondButtonTapped() {
        actionSheet.popoverPresentationController?.sourceView = approvalView.secondButton
        present(actionSheet, animated: true)
    }
}
