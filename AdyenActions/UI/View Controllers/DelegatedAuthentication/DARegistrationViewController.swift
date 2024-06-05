//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

internal final class DARegistrationViewController: UIViewController {
    private enum Constants {
        static let timeout: TimeInterval = 90.0
    }

    private let enableCheckoutHandler: Handler
    private let notNowHandler: Handler
    private lazy var containerView = UIView(frame: .zero)

    private lazy var scrollView = UIScrollView()
    private lazy var registrationView: DelegatedAuthenticationView = .init(logoStyle: style.imageStyle,
                                                                           headerTextStyle: style.headerTextStyle,
                                                                           descriptionTextStyle: style.descriptionTextStyle,
                                                                           progressViewStyle: style.progressViewStyle,
                                                                           progressTextStyle: style.remainingTimeTextStyle,
                                                                           firstButtonStyle: style.primaryButton,
                                                                           secondButtonStyle: style.secondaryButton,
                                                                           textViewStyle: style.textViewStyle)
    private let style: DelegatedAuthenticationComponentStyle
    private var timeoutTimer: ExpirationTimer?
    internal typealias Handler = () -> Void
    
    private let localizationParameters: LocalizationParameters?

    internal init(style: DelegatedAuthenticationComponentStyle,
                  localizationParameters: LocalizationParameters?,
                  enableCheckoutHandler: @escaping Handler,
                  notNowHandler: @escaping Handler) {
        self.style = style
        self.localizationParameters = localizationParameters
        self.enableCheckoutHandler = enableCheckoutHandler
        self.notNowHandler = notNowHandler
        super.init(nibName: nil, bundle: Bundle(for: DARegistrationViewController.self))
        registrationView.delegate = self
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
        buildUI()
        configureDelegateAuthenticationView()
        view.backgroundColor = style.backgroundColor
        configureDelegateAuthenticationView()
    }
    
    private func configureDelegateAuthenticationView() {
        registrationView.titleLabel.text = localizedString(.threeds2DARegistrationTitle, localizationParameters)
        registrationView.descriptionLabel.text = localizedString(.threeds2DARegistrationDescription, localizationParameters)
        registrationView.firstButton.title = localizedString(.threeds2DARegistrationPositiveButton, localizationParameters)
        registrationView.secondButton.title = localizedString(.threeds2DARegistrationNegativeButton, localizationParameters)
        configureProgress()
    }

    private func configureProgress() {
        let timeout = Constants.timeout
        registrationView.progressText.text = timeLeft(timeInterval: timeout)
        timeoutTimer = ExpirationTimer(
            expirationTimeout: timeout,
            onTick: { [weak self] in
                self?.registrationView.progressView.progress = Float($0 / timeout)
                self?.registrationView.progressText.text = self?.timeLeft(timeInterval: $0)
            },
            onExpiration: { [weak self] in
                self?.secondButtonTapped()
            }
        )
        timeoutTimer?.startTimer()
    }

    private func timeLeft(timeInterval: TimeInterval) -> String {
        String(format: localizedString(.threeds2DARegistrationTimeLeft, localizationParameters), timeInterval.adyen.timeLeftString() ?? "0")
    }
    
    private func buildUI() {
        containerView.addSubview(registrationView)
        view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        registrationView.translatesAutoresizingMaskIntoConstraints = false
        containerView.adyen.anchor(inside: view.safeAreaLayoutGuide)
        registrationView.adyen.anchor(inside: containerView)
    }

    override internal var preferredContentSize: CGSize {
        get {
            containerView.adyen.minimalSize
        }

        // swiftlint:disable:next unused_setter_value
        set { AdyenAssertion.assertionFailure(message: """
        PreferredContentSize is overridden for this view controller.
        getter - returns minimum possible content size.
        setter - no implemented.
        """) }
    }
}

extension DARegistrationViewController: DelegatedAuthenticationViewDelegate {
    internal func firstButtonTapped() {
        registrationView.firstButton.showsActivityIndicator = true
        timeoutTimer?.stopTimer()
        enableCheckoutHandler()
    }
    
    internal func secondButtonTapped() {
        timeoutTimer?.stopTimer()
        registrationView.secondButton.showsActivityIndicator = true
        notNowHandler()
    }
}
