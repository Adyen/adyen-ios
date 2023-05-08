//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

internal final class DAApprovalViewController: UIViewController {
    private let useBiometricsHandler: Handler
    private let approveDifferentlyHandler: Handler
    private let removeCredentialsHandler: Handler
    private lazy var alert: UIAlertController = {
        let alertController = UIAlertController(title: localizedString(.threeds2DAApprRemoveAlertTitle, localizationParameters),
                                                message: localizedString(.threeds2DAApprRemoveAlertDescription, localizationParameters),
                                                preferredStyle: .alert)
        let removeAction = UIAlertAction(title: localizedString(.threeds2DAApprRemoveAlertPositiveButton, localizationParameters),
                                         style: .cancel,
                                         handler: { [weak self] _ in
                                             self?.removeCredentialsHandler()
                                         })
        let cancelAction = UIAlertAction(title: localizedString(.threeds2DAApprRemoveAlertNegativeButton, localizationParameters),
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
                                                                       textViewStyle: style.textViewStyle)
    
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
        super.init(nibName: nil, bundle: Bundle(for: DARegistrationViewController.self))
        self.approvalView.delegate = self
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
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
        approvalView.titleLabel.text = localizedString(.threeds2DAApprTitle, localizationParameters)
        approvalView.descriptionLabel.text = localizedString(.threeds2DAApprDescription, localizationParameters)
        approvalView.firstButton.setTitle(localizedString(.threeds2DAApprPositiveButton, localizationParameters), for: .normal)
        approvalView.secondButton.setTitle(localizedString(.threeds2DAApprNegativeButton, localizationParameters), for: .normal)
        configureProgress()
        configureTextView()
    }
    
    private func configureTextView() {
        let string = localizedString(.threeds2DAApprRemoveCredentialsText, localizationParameters)
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        let attributedString = NSMutableAttributedString(string: string, attributes: [NSAttributedString.Key.paragraphStyle: style])
        if let range = string.adyen.linkRanges().first {
            attributedString.addAttribute(.link, value: "removeCredential://", range: range)
        }
        attributedString.mutableString.replaceOccurrences(of: "%#", with: "", range: NSRange(location: 0, length: attributedString.length))
        approvalView.textView.attributedText = attributedString
        approvalView.textView.delegate = self
    }

    private func configureProgress() {
        let timeout: TimeInterval = 90.0
        approvalView.progressText.text = timeLeft(timeInterval: timeout)
        timeoutTimer = ExpirationTimer(
            expirationTimeout: timeout,
            onTick: { [weak self] in
                self?.approvalView.progressView.progress = Float($0 / timeout)
                self?.approvalView.progressText.text = self?.timeLeft(timeInterval: $0)
            },
            onExpiration: { [weak self] in
                self?.timeoutTimer?.stopTimer()
                self?.useBiometricsHandler()
            }
        )
        timeoutTimer?.startTimer()
    }
    
    private func timeLeft(timeInterval: TimeInterval) -> String {
        String(format: localizedString(.threeds2DAApprTimeLeft, localizationParameters), timeInterval.adyen.timeLeftString() ?? "0")
    }

    private func buildUI() {
        containerView.addSubview(approvalView)
        view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        approvalView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.adyen.anchor(inside: view.safeAreaLayoutGuide)

        let constraints = [
            approvalView.topAnchor.constraint(equalTo: containerView.topAnchor),
            approvalView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            approvalView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            approvalView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    override internal var preferredContentSize: CGSize {
        get {
            containerView.frame.size
        }
        
        // swiftlint:disable:next unused_setter_value
        set { AdyenAssertion.assertionFailure(message: """
        PreferredContentSize is overridden for this view controller.
        getter - returns minimum possible content size.
        setter - not implemented.
        """) }
    }
}

extension DAApprovalViewController: DelegatedAuthenticationViewDelegate {
    func removeCredential() {
        timeoutTimer?.pauseTimer()
        self.present(alert, animated: true)
    }
    
    func firstButtonTapped() {
        useBiometricsHandler()
    }
    
    func secondButtonTapped() {
        approveDifferentlyHandler()
    }
}

extension DAApprovalViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if URL.absoluteString == "removeCredential://" {
            removeCredential()
        }
        return false
    }
}
