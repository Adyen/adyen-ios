//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import TwintSDK

public final class TwintComponent: PaymentComponent, PresentableComponent, PaymentAware {
    
    public static let RedirectNotificationErrorKey: String = "Error"
    
    struct TwintError: LocalizedError {
        var errorDescription: String?
    }
    
    /// The context object for this component.
    @_spi(AdyenInternal)
    public var context: AdyenContext

    /// The payment method object for this component.
    public var paymentMethod: PaymentMethod { twintPayPaymentMethod }

    private let twintPayPaymentMethod: TwintPaymentMethod

    public var requiresModalPresentation: Bool = true
    
    public var delegate: PaymentComponentDelegate? // TODO: Do we have to do anything special here -> see CashAppPayComponent
    
    /// Component's configuration
    public var configuration: Configuration
    
    public var viewController: UIViewController { formViewController }
    
    private lazy var formViewController: FormViewController = {
        let formViewController = FormViewController(
            style: configuration.style,
            localizationParameters: configuration.localizationParameters
        )
        formViewController.delegate = self
        formViewController.title = paymentMethod.displayInformation(using: configuration.localizationParameters).title
    
        formViewController.append(FormSpacerItem(numberOfSpaces: 2))
        formViewController.append(submitButtonItem)

        return formViewController
    }()
    
    private lazy var submitButtonItem: FormButtonItem = {
        let item = FormButtonItem(style: configuration.style.mainButtonItem)
        item.title = localizedSubmitButtonTitle(with: context.payment?.amount,
                                                style: .immediate,
                                                configuration.localizationParameters)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "submitButton")

        item.buttonSelectionHandler = { [weak self] in
            self?.startTwintFlow()
        }
        return item
    }()
    
    /// Initializes the Twint component.
    ///
    /// - Parameter paymentMethod: The Twint  payment method.
    /// - Parameter context: The context object for this component.
    /// - Parameter configuration: The configuration for the component.
    public init(
        paymentMethod: TwintPaymentMethod,
        context: AdyenContext,
        configuration: Configuration
    ) {
        self.twintPayPaymentMethod = paymentMethod
        self.context = context
        self.configuration = configuration
    }
    
    private func didSelectSubmitButton() {
        guard formViewController.validate() else { return }
    
        startLoading()
        startTwintFlow()
    }

    private func startLoading() {
        submitButtonItem.showsActivityIndicator = true
        formViewController.view.isUserInteractionEnabled = false
    }

    public func stopLoading() {
        submitButtonItem.showsActivityIndicator = false
        formViewController.view.isUserInteractionEnabled = true
    }
    
    private func startTwintFlow() {

        // We check if the user has any Twint app installed before we initiate the payment
        
        Twint.fetchInstalledAppConfigurations { [weak self] in
            guard let self else { return }
            let configurations = $0 ?? []
            
            guard !configurations.isEmpty else {
                handleNoAppInstalled()
                return
            }
            
            initiatePayment()
        }
    }
    
    private func initiatePayment() {
        
        let details = TwintDetails(
            paymentMethod: twintPayPaymentMethod,
            subType: "sdk"
        )
        
        let data = PaymentComponentData(
            paymentMethodDetails: details,
            amount: payment?.amount,
            order: order,
            storePaymentMethod: false // TODO: Pass correct value!
        )
        
        submit(data: data)
    }
    
    /// Invokes the pay method of the TwintSDK
    private func invokeTwintApp(
        with appConfiguration: TWAppConfiguration?,
        code: String
    ) {
        guard let appConfiguration else { return }
        
        startLoading()
        
        Twint.pay(
            withCode: code,
            appConfiguration: appConfiguration,
            callback: configuration.redirectURL.absoluteString
        )
    }
    
    private func handleNoAppInstalled() {
        // TODO: Implement Correctly
        let localizationParameters = configuration.localizationParameters
        let alertController = UIAlertController(title: "Error",
                                                message: "No Twint app installed",
                                                preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: localizedString(.dismissButton, localizationParameters), style: .cancel) { [weak self] _ in
            guard let self else { return }
            // TODO: Use a different error as it might be shown after the component closed
            self.delegate?.didFail(with: TwintError(errorDescription: "No app installed"), from: self)
        }
        alertController.addAction(cancelAction)
        
        self.viewController.presentViewController(alertController, animated: true)
    }
    
    @objc
    private func handleRedirect(notification: Notification) {
        NotificationCenter.default.removeObserver(self)
        
        if let error = notification.userInfo?[Self.RedirectNotificationErrorKey] as? String {
            handleError(TwintError(errorDescription: error))
            return
        }
        
        initiatePayment()
    }
    
    private func handleError(_ error: Error) {
        delegate?.didFail(with: error, from: self)
    }
}

// MARK: - Telemetry

@_spi(AdyenInternal)
extension TwintComponent: TrackableComponent {}

@_spi(AdyenInternal)
extension TwintComponent: ViewControllerDelegate {
    // MARK: - ViewControllerDelegate

    public func viewWillAppear(viewController: UIViewController) {
        sendTelemetryEvent()
    }
}
