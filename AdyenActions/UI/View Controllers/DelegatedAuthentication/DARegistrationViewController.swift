//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

@available(iOS 16.0, *)
internal final class DARegistrationViewController: UIViewController {
    private let context: AdyenContext
    private let cardNumber: String
    private let cardType: CardType
    private let biometricName: String
    private let enableCheckoutHandler: Handler
    private let notNowHandler: Handler
    private lazy var containerView = UIView(frame: .zero)

    private lazy var scrollView = UIScrollView()
    
    private lazy var registrationView: DelegatedAuthenticationView = .init(
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
    internal typealias Handler = () -> Void
    
    private let localizationParameters: LocalizationParameters?

    internal init(context: AdyenContext,
                  style: DelegatedAuthenticationComponentStyle,
                  localizationParameters: LocalizationParameters?,
                  cardNumber: String,
                  cardType: CardType,
                  biometricName: String,
                  enableCheckoutHandler: @escaping Handler,
                  notNowHandler: @escaping Handler) {
        self.style = style
        self.localizationParameters = localizationParameters
        self.cardNumber = cardNumber
        self.cardType = cardType
        self.enableCheckoutHandler = enableCheckoutHandler
        self.context = context
        self.biometricName = biometricName
        self.notNowHandler = notNowHandler
        super.init(nibName: nil, bundle: Bundle(for: DARegistrationViewController.self))
        registrationView.delegate = self
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
        
        registrationView.descriptionLabel.text = localizedString(.threeds2DARegistrationDescription, localizationParameters, biometricName)
        registrationView.firstButton.title = localizedString(.threeds2DARegistrationPositiveButton, localizationParameters)
        registrationView.secondButton.title = localizedString(.threeds2DARegistrationNegativeButton, localizationParameters)
        registrationView.firstInfoImage.image = UIImage(systemName: "bolt")?.withRenderingMode(.alwaysTemplate)
        registrationView.firstInfoLabel.text = localizedString(.threeds2DARegistrationFirstInfo, localizationParameters)
        registrationView.secondInfoImage.image = .biometricImage?.withRenderingMode(.alwaysTemplate)
        
        registrationView.secondInfoLabel.text = localizedString(.threeds2DARegistrationSecondInfo, localizationParameters, biometricName)
        registrationView.thirdInfoImage.image = UIImage(systemName: "trash")?.withRenderingMode(.alwaysTemplate)
        registrationView.thirdInfoLabel.text = localizedString(.threeds2DARegistrationThirdInfo, localizationParameters)
        registrationView.cardNumberLabel.text = cardNumber
        
        let cardTypeURL = LogoURLProvider.logoURL(withName: cardType.rawValue, environment: context.apiContext.environment)
        ImageLoaderProvider.imageLoader().load(url: cardTypeURL) { [weak self] image in
            guard let self else { return }
            registrationView.cardImage.image = image
        }
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

@available(iOS 16.0, *)
extension DARegistrationViewController: DelegatedAuthenticationViewDelegate {
    internal func firstButtonTapped() {
        registrationView.firstButton.showsActivityIndicator = true
        enableCheckoutHandler()
    }
    
    internal func secondButtonTapped() {
        registrationView.secondButton.showsActivityIndicator = true
        notNowHandler()
    }
}
