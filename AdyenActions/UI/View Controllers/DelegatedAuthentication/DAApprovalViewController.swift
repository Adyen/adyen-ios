//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

@available(iOS 16.0, *)
internal final class DAApprovalViewController: UIViewController {
    private let context: AdyenContext
    private let cardNumber: String
    private let cardType: CardType
    private let biometricName: String
    private let amount: String?
    private let useBiometricsHandler: Handler
    private let approveDifferentlyHandler: Handler
    private let removeCredentialsHandler: Handler
    
    private lazy var alert: UIAlertController = {
        let alertController = UIAlertController(title: localizedString(.threeds2DAApprovalRemoveAlertTitle, localizationParameters),
                                                message: localizedString(.threeds2DAApprovalRemoveAlertDescription, localizationParameters),
                                                preferredStyle: .alert)
        let removeAction = UIAlertAction(title: localizedString(.threeds2DAApprovalRemoveAlertPositiveButton, localizationParameters),
                                         style: .cancel,
                                         handler: { [weak self] _ in
                                             self?.removeCredentialsHandler()
                                         })
        let cancelAction = UIAlertAction(title: localizedString(.threeds2DAApprovalRemoveAlertNegativeButton, localizationParameters),
                                         style: .default,
                                         handler: { [weak self] _ in
            
                                         })
        alertController.addAction(cancelAction)
        alertController.addAction(removeAction)
        return alertController
    }()
    
    private lazy var actionSheet: UIAlertController = {
        let alertController = UIAlertController(title: localizedString(.threeds2DAApprovalActionSheetTitle, localizationParameters),
                                                message: nil,
                                                preferredStyle: .actionSheet)
        let removeAction = UIAlertAction(title: localizedString(.threeds2DAApprovalActionSheetRemove, localizationParameters),
                                         style: .destructive,
                                         handler: { [weak self] _ in
                                             guard let self else { return }
                                             present(alert, animated: true)
                                         })
        let fallbackAction = UIAlertAction(title: localizedString(.threeds2DAApprovalActionSheetFallback, localizationParameters),
                                           style: .default,
                                           handler: { [weak self] _ in
                                               self?.approveDifferentlyHandler()
                                           })
        let cancelAction = UIAlertAction(title: localizedString(.threeds2DAApprovalRemoveAlertNegativeButton, localizationParameters),
                                         style: .cancel)

        alertController.addAction(cancelAction)
        alertController.addAction(fallbackAction)
        alertController.addAction(removeAction)
        return alertController
    }()

    private lazy var containerView = UIView(frame: .zero)
    private lazy var approvalView: DelegatedAuthenticationView = .init(
        logoStyle: style.imageStyle,
        headerTextStyle: style.headerTextStyle,
        descriptionTextStyle: style.descriptionTextStyle,
        amountTextStyle: style.amountTextStyle,
        cardImageStyle: style.cardImageStyle,
        cardNumberTextStyle: style.cardNumberTextStyle,
        infoImageStyle: style.infoImageStyle,
        additionalInformationTextStyle: style.additionalInformationTextStyle,
        firstButtonStyle: style.primaryButton,
        secondButtonStyle: style.secondaryButton
    )
    
    private let style: DelegatedAuthenticationComponentStyle
    private let localizationParameters: LocalizationParameters?
    
    internal typealias Handler = () -> Void
    
    internal init(context: AdyenContext,
                  style: DelegatedAuthenticationComponentStyle,
                  localizationParameters: LocalizationParameters?,
                  biometricName: String,
                  amount: String?,
                  cardNumber: String,
                  cardType: CardType,
                  useBiometricsHandler: @escaping Handler,
                  approveDifferentlyHandler: @escaping Handler,
                  removeCredentialsHandler: @escaping Handler) {
        self.style = style
        self.useBiometricsHandler = useBiometricsHandler
        self.approveDifferentlyHandler = approveDifferentlyHandler
        self.removeCredentialsHandler = removeCredentialsHandler
        self.localizationParameters = localizationParameters
        self.amount = amount
        self.biometricName = biometricName
        self.cardType = cardType
        self.cardNumber = cardNumber
        self.context = context
        super.init(nibName: nil, bundle: Bundle(for: DAApprovalViewController.self))
        approvalView.delegate = self
    }
    
    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override internal func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = style.backgroundColor
        configureDelegateAuthenticationView()
        buildUI()
    }
    
    private func configureDelegateAuthenticationView() {
        approvalView.titleLabel.text = localizedString(.threeds2DAApprovalTitle, localizationParameters)
        approvalView.descriptionLabel.text = localizedString(.threeds2DAApprovalDescription, localizationParameters, biometricName)
        approvalView.firstButton.title = localizedString(.threeds2DAApprovalPositiveButton, localizationParameters)
        approvalView.secondButton.title = localizedString(.threeds2DAApprovalNegativeButton, localizationParameters)
        approvalView.cardNumberLabel.text = cardNumber
        approvalView.additionalInformationStackView.isHidden = true
        approvalView.amount.text = amount
        let cardTypeURL = LogoURLProvider.logoURL(withName: cardType.rawValue, environment: context.apiContext.environment)
        ImageLoaderProvider.imageLoader().load(url: cardTypeURL) { [weak self] image in
            guard let self else { return }
            approvalView.cardImage.image = image
        }
    }
    
    private func buildUI() {
        containerView.addSubview(approvalView)
        view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        approvalView.translatesAutoresizingMaskIntoConstraints = false
        containerView.adyen.anchor(inside: view.safeAreaLayoutGuide)
        approvalView.adyen.anchor(inside: containerView)
    }
    
    override internal var preferredContentSize: CGSize {
        get {
            containerView.adyen.minimalSize
        }
        
        // swiftlint:disable:next unused_setter_value
        set { AdyenAssertion.assertionFailure(message: """
        PreferredContentSize is overridden for this view controller.
        getter - returns minimum possible content size.
        setter - not implemented.
        """) }
    }
    
    private func deleteCredentialSelected(index: Int) {
        removeCredential()
    }
}

@available(iOS 16.0, *)
extension DAApprovalViewController: DelegatedAuthenticationViewDelegate {
    internal func removeCredential() {
        present(alert, animated: true)
    }
    
    internal func firstButtonTapped() {
        useBiometricsHandler()
    }
    
    internal func secondButtonTapped() {
        present(actionSheet, animated: true)
    }
}
