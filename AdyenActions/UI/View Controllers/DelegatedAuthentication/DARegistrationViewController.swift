//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

internal final class DARegistrationViewController: UIViewController {
    
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
    // TODO: pass this from the public interface.
    private let style: DelegatedAuthenticationComponentStyle = .init()
    private var timeoutTimer: ExpirationTimer?
    internal typealias Handler = () -> Void
    
    // TODO: pass this from the Configuration
    public var localizationParameters: LocalizationParameters?

    internal init(enableCheckoutHandler: @escaping Handler, notNowHandler: @escaping Handler) {
        self.enableCheckoutHandler = enableCheckoutHandler
        self.notNowHandler = notNowHandler
        super.init(nibName: nil, bundle: Bundle(for: DARegistrationViewController.self))
        self.registrationView.delegate = self
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
        configureProgress()
        configureDelegateAuthenticationView()
    }
    
    private func configureDelegateAuthenticationView() {
        registrationView.titleLabel.text = localizedString(.threeds2DARegTitle, localizationParameters)
        registrationView.descriptionLabel.text = localizedString(.threeds2DARegDescription, localizationParameters)
        registrationView.firstButton.setTitle(localizedString(.threeds2DARegPositiveButton, localizationParameters), for: .normal)
        registrationView.secondButton.setTitle(localizedString(.threeds2DARegNegativeButton, localizationParameters), for: .normal)
        configureProgress()
    }

    private func configureProgress() {
        let timeout: TimeInterval = 90.0
        registrationView.progressText.text = timeLeft(timeInterval: timeout)
        timeoutTimer = ExpirationTimer(
            expirationTimeout: timeout,
            onTick: { [weak self] in
                self?.registrationView.progressView.progress = Float($0 / timeout)
                self?.registrationView.progressText.text = self?.timeLeft(timeInterval: $0)
            },
            onExpiration: { [weak self] in
                self?.timeoutTimer?.stopTimer()
                self?.enableCheckoutHandler()
            }
        )
        timeoutTimer?.startTimer()
    }

    private func timeLeft(timeInterval: TimeInterval) -> String {
        String(format: localizedString(.threeds2DARegTimeLeft, localizationParameters), timeInterval.adyen.timeLeftString() ?? "0")
    }
    
    private func buildUI() {
        containerView.addSubview(registrationView)
        view.addSubview(containerView)

        containerView.translatesAutoresizingMaskIntoConstraints = false
        registrationView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.adyen.anchor(inside: view.safeAreaLayoutGuide)

        let constraints = [
            registrationView.topAnchor.constraint(equalTo: containerView.topAnchor),
            registrationView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            registrationView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            registrationView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    // TODO: Why is this needed?
    override internal var preferredContentSize: CGSize {
        get {
            containerView.frame.size
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
    func firstButtonTapped() {
        enableCheckoutHandler()
    }
    
    func secondButtonTapped() {
        notNowHandler()
    }
}
