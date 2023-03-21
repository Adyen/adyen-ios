//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

#if canImport(PayKit)
    @_spi(AdyenInternal) import Adyen
    import PayKit
    import UIKit

    /// A component that handles a Cash App Pay payment.
    @available(iOS 13.0, *)
    public final class CashAppPayComponent: PaymentComponent,
        PaymentAware,
        PresentableComponent,
        LoadingComponent {
        
        private enum ViewIdentifier {
            static let payButtonItem = "payButtonItem"
        }

        /// The context object for this component.
        @_spi(AdyenInternal)
        public var context: AdyenContext

        /// The payment method object for this component.
        public var paymentMethod: PaymentMethod { cashAppPayPaymentMethod }

        /// The delegate of the component.
        public weak var delegate: PaymentComponentDelegate?

        /// Component's configuration
        public var configuration: Configuration
        
        public lazy var viewController: UIViewController = SecuredViewController(child: formViewController,
                                                                                 style: configuration.style)

        public var requiresModalPresentation: Bool = true
        
        private let cashAppPayPaymentMethod: CashAppPayPaymentMethod

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
            formViewController.localizationParameters = configuration.localizationParameters
            formViewController.title = paymentMethod.displayInformation(using: configuration.localizationParameters).title
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
            initiateCashAppPayFlow()
        }
        
        private func startLoading() {
            cashAppPayButton.showsActivityIndicator = true
            formViewController.view.isUserInteractionEnabled = false
        }
        
        public func stopLoading() {
            cashAppPayButton.showsActivityIndicator = false
            formViewController.view.isUserInteractionEnabled = true
        }
        
        private func initiateCashAppPayFlow() {
            var moneyAmount: Money?
            if let amount = context.payment?.amount {
                moneyAmount = Money(amount: UInt(amount.value), currency: .USD)
            }
            let action = PaymentAction.oneTimePayment(scopeID: cashAppPayPaymentMethod.scopeId,
                                                      money: moneyAmount)
            cashAppPay.createCustomerRequest(params: CreateCustomerRequestParams(actions: [action],
                                                                                 redirectURL: configuration.redirectURL,
                                                                                 referenceID: configuration.referenceId,
                                                                                 metadata: nil))
        }
        
    }

    @available(iOS 13.0, *)
    extension CashAppPayComponent: CashAppPayObserver {

        public func stateDidChange(to state: CashAppPayState) {
            switch state {
            case let .readyToAuthorize(request):
                cashAppPay.authorizeCustomerRequest(request)
            case let .approved(_, grants):
                guard let grant = grants.first else {
                    delegate?.didFail(with: Error.noGrant, from: self)
                    return
                }
                let details = CashAppPayDetails(paymentMethod: cashAppPayPaymentMethod, grantId: grant.id)
                submit(data: PaymentComponentData(paymentMethodDetails: details,
                                                  amount: payment?.amount,
                                                  order: order,
                                                  storePaymentMethod: configuration.storePaymentMethod))
            case let .apiError(error):
                delegate?.didFail(with: error, from: self)
            case let .networkError(error):
                delegate?.didFail(with: error, from: self)
            case let .unexpectedError(error):
                delegate?.didFail(with: error, from: self)
            case let .integrationError(error):
                delegate?.didFail(with: error, from: self)
            case .declined:
                delegate?.didFail(with: Error.declined, from: self)
                stopLoading()
            default:
                break
            }
        }
    }

    @available(iOS 13.0, *)
    extension CashAppPayComponent {
        /// Configuration object for Cash App Component
        public struct Configuration {

            /// The URL for Cash App to call in order to redirect back to your application.
            public let redirectURL: URL

            /// A reference to your system (for example, a cart or checkout identifier).
            public let referenceId: String?
        
            /// Determines whether to store this payment method.
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
            ///   - storePaymentMethod: Determines whether to store this payment method.
            ///   - style: The UI style of the component.
            ///   - localizationParameters: The localization parameters, leave it nil to use the default parameters.
            public init(redirectURL: URL,
                        referenceId: String? = nil,
                        storePaymentMethod: Bool,
                        style: FormComponentStyle = FormComponentStyle(),
                        localizationParameters: LocalizationParameters? = nil) {
                self.redirectURL = redirectURL
                self.referenceId = referenceId
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

#endif
