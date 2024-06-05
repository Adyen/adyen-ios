//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

internal final class DAApprovalViewController: UIViewController {
    private enum Constants {
        static let timeout: TimeInterval = 90.0
    }

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
                                             self?.timeoutTimer?.resumeTimer()
                                         })
        alertController.addAction(cancelAction)
        alertController.addAction(removeAction)
        return alertController
    }()
    
    private lazy var containerView = UIView(frame: .zero)
    private lazy var approvalView: DelegatedAuthenticationView = .init(logoStyle: style.imageStyle,
                                                                       headerTextStyle: style.headerTextStyle,
                                                                       descriptionTextStyle: style.descriptionTextStyle,
                                                                       progressViewStyle: style.progressViewStyle,
                                                                       progressTextStyle: style.remainingTimeTextStyle,
                                                                       firstButtonStyle: style.primaryButton,
                                                                       secondButtonStyle: style.secondaryButton,
                                                                       textViewStyle: style.textViewStyle,
                                                                       linkSelectionHandler: deleteCredentialSelected)
    
    private let style: DelegatedAuthenticationComponentStyle
    private var timeoutTimer: ExpirationTimer?
    private let localizationParameters: LocalizationParameters?
    
    internal typealias Handler = () -> Void
    
    internal init(style: DelegatedAuthenticationComponentStyle,
                  localizationParameters: LocalizationParameters?,
                  useBiometricsHandler: @escaping Handler,
                  approveDifferentlyHandler: @escaping Handler,
                  removeCredentialsHandler: @escaping Handler) {
        self.style = style
        self.useBiometricsHandler = useBiometricsHandler
        self.approveDifferentlyHandler = approveDifferentlyHandler
        self.removeCredentialsHandler = removeCredentialsHandler
        self.localizationParameters = localizationParameters
        super.init(nibName: nil, bundle: Bundle(for: DAApprovalViewController.self))
        approvalView.delegate = self
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
        }
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
        approvalView.descriptionLabel.text = localizedString(.threeds2DAApprovalDescription, localizationParameters)
        approvalView.firstButton.title = localizedString(.threeds2DAApprovalPositiveButton, localizationParameters)
        approvalView.secondButton.title = localizedString(.threeds2DAApprovalNegativeButton, localizationParameters)
        configureProgress()
        approvalView.textView.update(text: localizedString(.threeds2DAApprovalRemoveCredentialsText, localizationParameters),
                                     style: style.textViewStyle)
    }
    
    private func configureProgress() {
        let timeout = Constants.timeout
        approvalView.progressText.text = timeLeft(timeInterval: timeout)
        timeoutTimer = ExpirationTimer(
            expirationTimeout: timeout,
            onTick: { [weak self] in
                self?.approvalView.progressView.progress = Float($0 / timeout)
                self?.approvalView.progressText.text = self?.timeLeft(timeInterval: $0)
            },
            onExpiration: { [weak self] in
                self?.secondButtonTapped()
            }
        )
        timeoutTimer?.startTimer()
    }
    
    private func timeLeft(timeInterval: TimeInterval) -> String {
        String(format: localizedString(.threeds2DAApprovalTimeLeft, localizationParameters), timeInterval.adyen.timeLeftString() ?? "0")
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

extension DAApprovalViewController: DelegatedAuthenticationViewDelegate {
    internal func removeCredential() {
        timeoutTimer?.pauseTimer()
        present(alert, animated: true)
    }
    
    internal func firstButtonTapped() {
        approvalView.firstButton.showsActivityIndicator = true
        timeoutTimer?.stopTimer()
        useBiometricsHandler()
    }
    
    internal func secondButtonTapped() {
        approvalView.secondButton.showsActivityIndicator = true
        timeoutTimer?.stopTimer()
        approveDifferentlyHandler()
    }
}
