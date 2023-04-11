//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import PayKit
import UIKit

/// A component that handles a Cash App Pay payment.
@available(iOS 13.0, *)
public final class CashAppPayComponent: PaymentComponent,
    PaymentAware,
    PresentableComponent,
    LoadingComponent {
    
    /// The notification to post when returning back to your application from Cash App.
    public static let RedirectNotification = CashAppPay.RedirectNotification
    
    private enum ViewIdentifier {
        static let storeDetailsItem = "storeDetailsItem"
        static let payButtonItem = "payButtonItem"
    }

    /// The context object for this component.
    @_spi(AdyenInternal)
    public var context: AdyenContext

    /// The payment method object for this component.
    public var paymentMethod: PaymentMethod { cashAppPayPaymentMethod }

    /// The delegate of the component.
    public weak var delegate: PaymentComponentDelegate? {
        didSet {
            if let storePaymentMethodAware = delegate as? StorePaymentMethodFieldAware,
               storePaymentMethodAware.isSession {
                configuration.showsStorePaymentMethodField = storePaymentMethodAware.showStorePaymentMethodField ?? false
            }
        }
    }

    /// Component's configuration
    public var configuration: Configuration
    
    public lazy var viewController: UIViewController = SecuredViewController(child: formViewController,
                                                                             style: configuration.style)

    public var requiresModalPresentation: Bool = true
    
    private let cashAppPayPaymentMethod: CashAppPayPaymentMethod
    
    private var storePayment: Bool {
        configuration.showsStorePaymentMethodField ? storeDetailsItem.value : configuration.storePaymentMethod
    }

    private lazy var cashAppPay: CashAppPay = {
        let cashAppPayKit = CashAppPay(clientID: cashAppPayPaymentMethod.clientId, endpoint: cashAppPayEnvironment)
        cashAppPayKit.addObserver(self)
        return cashAppPayKit
    }()
    
    private var cashAppPayEnvironment: CashAppPay.Endpoint {
        guard let environment = context.apiContext.environment as? Environment else {
            return .sandbox
        }
        return environment.isLive ? .production : .sandbox
    }
    
    internal lazy var storeDetailsItem: FormToggleItem = {
        let storeDetailsItem = FormToggleItem(style: configuration.style.toggle)
        storeDetailsItem.title = localizedString(.cardStoreDetailsButton, configuration.localizationParameters)
        storeDetailsItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: ViewIdentifier.storeDetailsItem)
        
        return storeDetailsItem
    }()
    
    internal lazy var cashAppPayButton: FormButtonItem = {
        let item = FormButtonItem(style: configuration.style.mainButtonItem)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: ViewIdentifier.payButtonItem)
        // TODO: localized title
        item.title = "Continue to Cash App Pay"
        item.buttonSelectionHandler = { [weak self] in
            self?.didSelectSubmitButton()
        }
        return item
    }()

    // MARK: - Private
    
    private lazy var formViewController: FormViewController = {
        let formViewController = FormViewController(style: configuration.style)
        formViewController.delegate = self
        formViewController.localizationParameters = configuration.localizationParameters
        formViewController.title = paymentMethod.displayInformation(using: configuration.localizationParameters).title
        
        if configuration.showsStorePaymentMethodField {
            formViewController.append(storeDetailsItem)
        }
        
        formViewController.append(FormSpacerItem(numberOfSpaces: 2))
        formViewController.append(cashAppPayButton)

        return formViewController
    }()

    /// Initializes the Cash App Pay component.
    ///
    /// - Parameter paymentMethod: The Cash App Pay  payment method.
    /// - Parameter context: The context object for this component.
    /// - Parameter configuration: The configuration for the component.
    public init(paymentMethod: CashAppPayPaymentMethod,
                context: AdyenContext,
                configuration: Configuration) {
        self.cashAppPayPaymentMethod = paymentMethod
        self.context = context
        self.configuration = configuration
    }
    
    private func didSelectSubmitButton() {
        guard formViewController.validate() else { return }
        
        startLoading()
        startCashAppPayFlow()
    }
    
    private func startLoading() {
        cashAppPayButton.showsActivityIndicator = true
        formViewController.view.isUserInteractionEnabled = false
    }
    
    public func stopLoading() {
        cashAppPayButton.showsActivityIndicator = false
        formViewController.view.isUserInteractionEnabled = true
    }
    
    private func startCashAppPayFlow() {
        let actions = createPaymentActions()
        guard actions.isEmpty == false else {
            AdyenAssertion.assertionFailure(message: "At least one paymentAction is required to create a CashAppPay rquest")
            return
        }
        
        cashAppPay.createCustomerRequest(params: CreateCustomerRequestParams(actions: actions,
                                                                             redirectURL: configuration.redirectURL,
                                                                             referenceID: configuration.referenceId,
                                                                             metadata: nil))
    }
    
    private func createPaymentActions() -> [PaymentAction] {
        var actions = [PaymentAction]()
        if let amount = payment?.amount, amount.value > 0 {
            let moneyAmount = Money(amount: UInt(amount.value), currency: .USD)
            let oneTimeAction = PaymentAction.oneTimePayment(scopeID: cashAppPayPaymentMethod.scopeId,
                                                             money: moneyAmount)
            actions.append(oneTimeAction)
        }
        
        if storePayment {
            let onFileAction = PaymentAction.onFilePayment(scopeID: cashAppPayPaymentMethod.scopeId,
                                                           accountReferenceID: nil)
            actions.append(onFileAction)
        }
        
        return actions
    }
    
    private func cashAppPayDetails(from customerProfile: CustomerRequest.CustomerProfile?,
                                   grants: [CustomerRequest.Grant]) throws -> CashAppPayDetails {
        guard grants.isEmpty == false else {
            throw Error.noGrant
        }
        let onFileGrant = grants.first { $0.type == .EXTENDED }
        let oneTimeGrant = grants.first { $0.type == .ONE_TIME }
        let cashtag = onFileGrant != nil ? customerProfile?.cashtag : nil
        let customerId = onFileGrant?.customerID
        
        return CashAppPayDetails(paymentMethod: cashAppPayPaymentMethod,
                                 grantId: oneTimeGrant?.id,
                                 onFileGrantId: onFileGrant?.id,
                                 customerId: customerId,
                                 cashtag: cashtag)
    }
    
}

@available(iOS 13.0, *)
extension CashAppPayComponent: CashAppPayObserver {

    public func stateDidChange(to state: CashAppPayState) {
        switch state {
        case let .readyToAuthorize(request):
            cashAppPay.authorizeCustomerRequest(request)
        case let .approved(request, grants):
            do {
                let details = try cashAppPayDetails(from: request.customerProfile, grants: grants)
                submit(data: PaymentComponentData(paymentMethodDetails: details,
                                                  amount: payment?.amount,
                                                  order: order,
                                                  storePaymentMethod: storePayment))
            } catch {
                fail(with: error)
            }
        case let .apiError(error):
            fail(with: error)
        case let .networkError(error):
            fail(with: error)
        case let .unexpectedError(error):
            fail(with: error)
        case let .integrationError(error):
            fail(with: error)
        case .declined:
            fail(with: Error.declined)
        default:
            break
        }
    }
    
    private func fail(with error: Swift.Error) {
        stopLoading()
        delegate?.didFail(with: error, from: self)
    }
}

@available(iOS 13.0, *)
extension CashAppPayComponent {
    /// Configuration object for Cash App Component
    public struct Configuration: AnyCashAppPayConfiguration {

        /// The URL for Cash App to call in order to redirect back to your application.
        public let redirectURL: URL

        /// A reference to your system (for example, a cart or checkout identifier).
        public let referenceId: String?
    
        /// Indicates if the field for storing the payment method should be displayed in the form. Defaults to `true`.
        public var showsStorePaymentMethodField: Bool
        
        /// Determines whether to store this payment method. Defaults to `false`.
        /// Ignored if `showsStorePaymentMethodField` is `true`.
        public var storePaymentMethod: Bool
    
        /// Describes the component's UI style.
        public var style: FormComponentStyle

        /// The localization parameters, leave it nil to use the default parameters.
        public var localizationParameters: LocalizationParameters?

        /// Initializes an instance of `CashAppPayComponent.Configuration`
        ///
        /// - Parameters:
        ///   - redirectURL: The URL for Cash App to call in order to redirect back to your application.
        ///   - referenceId: A reference to your system (for example, a cart or checkout identifier).
        ///   - showsStorePaymentMethodField: Determines the visibility of the field for storing the payment method.
        ///   - storePaymentMethod: Determines whether to store this payment method.
        ///   Ignored if `showsStorePaymentMethodField` is `true`.
        ///   - style: The UI style of the component.
        ///   - localizationParameters: The localization parameters, leave it nil to use the default parameters.
        public init(redirectURL: URL,
                    referenceId: String? = nil,
                    showsStorePaymentMethodField: Bool = true,
                    storePaymentMethod: Bool = false,
                    style: FormComponentStyle = FormComponentStyle(),
                    localizationParameters: LocalizationParameters? = nil) {
            self.redirectURL = redirectURL
            self.referenceId = referenceId
            self.showsStorePaymentMethodField = showsStorePaymentMethodField
            self.storePaymentMethod = storePaymentMethod
            self.style = style
            self.localizationParameters = localizationParameters
        }
    }
}

@available(iOS 13.0, *)
extension CashAppPayComponent {

    /// Describes the errors that can occur during the Cash App Pay payment flow, in addition to Cash App Pay's own errors.
    public enum Error: LocalizedError {
        /// Grants array of the customer request is empty
        case noGrant
        /// Payment was declined by the Cash App Pay app.
        case declined
        
        public var errorDescription: String? {
            switch self {
            case .noGrant:
                return "There was no grant object in the customer request."
            case .declined:
                return "The payment was declined by the Cash App Pay app."
            }
        }
    }
}

@available(iOS 13.0, *)
@_spi(AdyenInternal)
extension CashAppPayComponent: TrackableComponent {}

@available(iOS 13.0, *)
@_spi(AdyenInternal)
extension CashAppPayComponent: ViewControllerDelegate {

    public func viewWillAppear(viewController: UIViewController) {
        sendTelemetryEvent()
    }
}
