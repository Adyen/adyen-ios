//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import TwintSDK

public final class TwintComponent: PaymentComponent, PresentableComponent, PaymentAware {
    
    public static let RedirectNotification: Notification.Name = Notification.Name("TwintRedirect")
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
    
    public lazy var viewController: UIViewController = SecuredViewController(
        child: formViewController,
        style: configuration.style
    )
    
    private lazy var formViewController: FormViewController = {
        let formViewController = FormViewController(
            style: configuration.style,
            localizationParameters: configuration.localizationParameters
        )
        formViewController.delegate = self
        formViewController.title = paymentMethod.displayInformation(using: configuration.localizationParameters).title
    
//        if configuration.showsStorePaymentMethodField {
//            formViewController.append(storeDetailsItem)
//        }
    
        formViewController.append(FormSpacerItem(numberOfSpaces: 2))
        formViewController.append(submitButtonItem)

        return formViewController
    }()
    
    private lazy var submitButtonItem: FormButtonItem = {
//        let component = self.defaultComponent
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
        
        // TODO: We need a code before - How to get it?
        
        Twint.fetchInstalledAppConfigurations { [weak self] configurations in
            guard let self else { return }
            
            defer { stopLoading() }
            
            if (configurations ?? []).isEmpty {
                // TODO: Show a better error + only dismiss the component, not the whole drop-in!
                // Can we fallback to web?! Especially if the merchant does not have space for all the url-schemes?
                self.delegate?.didFail(with: TwintError(errorDescription: "No Twint apps installed"), from: self)
                return
            }
            
            let controller = Twint.controller(for: configurations) { [weak self] appConfiguration in
                guard let self else { return }
                
                startLoading() // Wait for the deeplink
                Twint.pay(
                    withCode: "Random code that should have been fetched before",
                    appConfiguration: appConfiguration,
                    callback: configuration.redirectURL.absoluteString
                )
                
                NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(handleRedirect),
                    name: TwintComponent.RedirectNotification,
                    object: nil
                )
            } cancelHandler: {
                self.delegate?.didFail(with: ComponentError.cancelled, from: self)
            }
            
            guard let controller else {
                return
            }
            
            self.viewController.present(controller, animated: true)
        }
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
