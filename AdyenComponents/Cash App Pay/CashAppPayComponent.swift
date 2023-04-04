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
            static let spinnerItem = "spinnerItem"
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
        
        internal lazy var spinnerItem: FormSpinnerItem = {
            let item = FormSpinnerItem()
            item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: ViewIdentifier.spinnerItem)
            return item
        }()

        // MARK: - Private
        
        private lazy var formViewController: FormViewController = {
            let formViewController = FormViewController(style: configuration.style)
            formViewController.delegate = self
            formViewController.localizationParameters = configuration.localizationParameters
            formViewController.title = paymentMethod.displayInformation(using: configuration.localizationParameters).title
            formViewController.append(FormSpacerItem(numberOfSpaces: 2))
            formViewController.append(spinnerItem)

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
        
        private func startLoading() {
            spinnerItem.isAnimating = true
            formViewController.view.isUserInteractionEnabled = false
        }
        
        public func stopLoading() {
            spinnerItem.isAnimating = false
            formViewController.view.isUserInteractionEnabled = true
        }
        
        private func initiateCashAppPayFlow() {
            var moneyAmount: Money?
            if let amount = context.payment?.amount {
                moneyAmount = Money(amount: UInt(amount.value), currency: .USD)
            }
            let oneTimeAction = PaymentAction.oneTimePayment(scopeID: cashAppPayPaymentMethod.scopeId,
                                                             money: moneyAmount)
            let onFileAction = PaymentAction.onFilePayment(scopeID: cashAppPayPaymentMethod.scopeId,
                                                           accountReferenceID: nil)
            cashAppPay.createCustomerRequest(params: CreateCustomerRequestParams(actions: [oneTimeAction, onFileAction],
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
                    fail(with: Error.noGrant)
                    return
                }
                let details = CashAppPayDetails(paymentMethod: cashAppPayPaymentMethod,
                                                grantId: grant.id,
                                                onFileGrantId: nil,
                                                customerId: nil,
                                                cashtag: nil)
                submit(data: PaymentComponentData(paymentMethodDetails: details,
                                                  amount: payment?.amount,
                                                  order: order,
                                                  storePaymentMethod: configuration.storePaymentMethod))
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

    @available(iOS 13.0, *)
    @_spi(AdyenInternal)
    extension CashAppPayComponent: TrackableComponent {}

    @available(iOS 13.0, *)
    @_spi(AdyenInternal)
    extension CashAppPayComponent: ViewControllerDelegate {

        public func viewDidLoad(viewController: UIViewController) {
            Analytics.sendEvent(component: paymentMethod.type.rawValue,
                                flavor: _isDropIn ? .dropin : .components,
                                context: context.apiContext)
        }

        /// :nodoc:
        public func viewWillAppear(viewController: UIViewController) {
            sendTelemetryEvent()
            startLoading()
            initiateCashAppPayFlow()
        }
    }

#endif
