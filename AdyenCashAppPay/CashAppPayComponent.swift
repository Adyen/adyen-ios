//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import PayKit
import PayKitUI
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
        static let cashAppButtonItem = "cashAppButtonItem"
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
    public var configuration: CashAppPayConfiguration

    public lazy var viewController: UIViewController = SecuredViewController(child: formViewController,
                                                                             style: configuration.style)

    public var requiresModalPresentation: Bool = true

    private let cashAppPayPaymentMethod: CashAppPayPaymentMethod

    private var storePayment: Bool? {
        configuration.showsStorePaymentMethodField ? storeDetailsItem.value : nil
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

    internal lazy var cashAppPayButton: CashAppPayButtonItem = {
        let item = CashAppPayButtonItem { [weak self] in
            self?.didSelectSubmitButton()
        }
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: ViewIdentifier.cashAppButtonItem)
        return item
    }()

    // MARK: - Private

    private lazy var formViewController: FormViewController = {
        let formViewController = FormViewController(
            scrollEnabled: configuration.showSubmitButton,
            style: configuration.style,
            localizationParameters: configuration.localizationParameters
        )
        formViewController.delegate = self
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
                configuration: CashAppPayConfiguration) {
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
            AdyenAssertion.assertionFailure(message: "At least one paymentAction is required to create a CashAppPay request")
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
    
        if storePayment == true {
            let onFileAction = PaymentAction.onFilePayment(scopeID: cashAppPayPaymentMethod.scopeId,
                                                           accountReferenceID: nil)
            actions.append(onFileAction)
        }
    
        return actions
    }

    private func cashAppPayDetails(from grants: [CustomerRequest.Grant],
                                   customerProfile: CustomerRequest.CustomerProfile?) throws -> CashAppPayDetails {
        guard grants.isEmpty == false else {
            throw Error.noGrant
        }
        let onFileGrant = grants.first { $0.type == .EXTENDED }
        let oneTimeGrant = grants.first { $0.type == .ONE_TIME }
        let cashtag = onFileGrant != nil ? customerProfile?.cashtag : nil
        let customerId = customerProfile?.id
    
        return CashAppPayDetails(paymentMethod: cashAppPayPaymentMethod,
                                 grantId: oneTimeGrant?.id,
                                 onFileGrantId: onFileGrant?.id,
                                 customerId: customerId,
                                 cashtag: cashtag)
    }
    
    internal func submitApprovedRequest(with grants: [CustomerRequest.Grant], profile: CustomerRequest.CustomerProfile?) {
        do {
            let details = try cashAppPayDetails(from: grants, customerProfile: profile)
            submit(data: PaymentComponentData(paymentMethodDetails: details,
                                              amount: payment?.amount,
                                              order: order,
                                              storePaymentMethod: storePayment))
        } catch {
            fail(with: error)
        }
    }

}

@available(iOS 13.0, *)
extension CashAppPayComponent: CashAppPayObserver {

    public func stateDidChange(to state: CashAppPayState) {
        switch state {
        case let .readyToAuthorize(request):
            cashAppPay.authorizeCustomerRequest(request)
        case let .approved(request, grants):
            submitApprovedRequest(with: grants, profile: request.customerProfile)
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
extension CashAppPayComponent: ViewControllerDelegate {}

// MARK: - SubmitCustomizable

@available(iOS 13.0, *)
extension CashAppPayComponent: SubmitCustomizable {

    public func submit() {
        guard !configuration.showSubmitButton else {
            AdyenAssertion.assertionFailure(message: "Default submit button must be hidden in order to call submit.")
            return
        }

        didSelectSubmitButton()
    }
}
