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
    
    private lazy var containerView = UIView(frame: .zero)
    private lazy var approvalView: DelegatedAuthenticationView = .init(logoStyle: style.imageStyle,
                                                                       headerTextStyle: style.headerTextStyle,
                                                                       descriptionTextStyle: style.descriptionTextStyle,
                                                                       progressViewStyle: style.progressViewStyle,
                                                                       progressTextStyle: style.remainingTimeTextStyle,
                                                                       firstButtonStyle: style.primaryButton,
                                                                       secondButtonStyle: style.secondaryButton,
                                                                       textViewStyle: style.textViewStyle)
    
    // TODO: pass this from the public interface.
    private let style: DelegatedAuthenticationComponentStyle = .init()
    private var timeoutTimer: ExpirationTimer?
    // TODO: pass this from the Configuration
    public var localizationParameters: LocalizationParameters?

    internal typealias Handler = () -> Void
    
    internal init(useBiometricsHandler: @escaping Handler,
                  approveDifferentlyHandler: @escaping Handler,
                  removeCredentialsHandler: @escaping Handler) {
        self.useBiometricsHandler = useBiometricsHandler
        self.approveDifferentlyHandler = approveDifferentlyHandler
        self.removeCredentialsHandler = removeCredentialsHandler
        super.init(nibName: nil, bundle: Bundle(for: DARegistrationViewController.self))
        self.approvalView.delegate = self
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
        let range = NSString(string: string).range(of: localizedString(.threeds2DAApprRemoveCredentialsText, localizationParameters))
        let attributedString = NSMutableAttributedString(string: string)
        attributedString.addAttribute(.link, value: "removeCredential://", range: range)
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
                self?.useBiometricsHandler()
            }
        )
        timeoutTimer?.startTimer()
    }
    
    private func timeLeft(timeInterval: TimeInterval) -> String {
        String(format: localizedString(.threeds2DAApprTimeLeft, localizationParameters), timeInterval.adyen.timeLeftString() ?? "0")
        // "You have \(timeInterval.adyen.timeLeftString() ?? "0") to approve"
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
            print("approvalView.adyen.minimalSize: \(approvalView.adyen.minimalSize)")
            print("containerView.adyen.minimalSize: \(containerView.adyen.minimalSize)")

            // TODO: This isn't computing properly - would need help on this one.
            return CGSize(width: .max, height: 700)
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
        let alertController = UIAlertController(title: localizedString(.threeds2DAAppAlertRemoveAlertTitle, localizationParameters),
                                                message: localizedString(.threeds2DAAppAlertRemoveAlertDescription, localizationParameters),
                                                preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: localizedString(.threeds2DAAppAlertRemoveAlertPositiveButton, localizationParameters), style: .cancel, handler: { [weak self] _ in
            self?.timeoutTimer?.resumeTimer()
        }))

        alertController.addAction(UIAlertAction(title: localizedString(.threeds2DAAppAlertRemoveAlertNegativeButton, localizationParameters), style: .default, handler: { [weak self] _ in
            self?.removeCredentialsHandler()
        }))
        
        self.present(alertController, animated: true)
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
