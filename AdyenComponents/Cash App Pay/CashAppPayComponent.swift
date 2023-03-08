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
        PaymentAware {

        /// Configuration object for Cash App Component
        public struct Configuration {

            /// The URL for Cash App to call in order to redirect back to your application.
            public let redirectURL: URL

            /// Reference ID for?
            public let referenceId: String?

            /// The localization parameters, leave it nil to use the default parameters.
            public var localizationParameters: LocalizationParameters?

            /// Initializes an instance of `Configuration`
            ///
            /// - Parameters:
            ///   - redirectURL: The URL for Cash App to call in order to redirect back to your application.
            ///   - referenceId: ...
            ///   - localizationParameters: The localization parameters, leave it nil to use the default parameters.
            public init(redirectURL: URL,
                        referenceId: String? = nil,
                        localizationParameters: LocalizationParameters? = nil) {
                self.redirectURL = redirectURL
                self.referenceId = referenceId
                self.localizationParameters = localizationParameters
            }
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

        private let cashAppPayPaymentMethod: CashAppPayPaymentMethod

        private lazy var cashAppPay: PayKit = {
            let cashAppPay = PayKit(clientID: cashAppPayPaymentMethod.merchantId, endpoint: .sandbox)
            cashAppPay.addObserver(self)
            return cashAppPay
        }()

        private var pendingRequest: CustomerRequest?

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

        private func initializeCashAppPay() {
            guard let amount = payment?.amount else {
                AdyenAssertion.assertionFailure(message: "Cash App Pay sdk requires amount to work")
                return
            }
            let action = PaymentAction.oneTimePayment(scopeID: cashAppPayPaymentMethod.scopeId,
                                                      money: Money(amount: UInt(amount.value), currency: .USD))
                cashAppPay.createCustomerRequest(params: CreateCustomerRequestParams(actions: [action],
                                                                                     redirectURL: configuration.redirectURL,
                                                                                     referenceID: configuration.referenceId,
                                                                                     metadata: nil))
        }

    }

    @available(iOS 13.0, *)
    extension CashAppPayComponent: PayKitObserver {

    public func stateDidChange(to state: PayKitState) {
        switch state {
        case .readyToAuthorize(let request):
            pendingRequest = request
            cashAppPay.authorizeCustomerRequest(request)
        case let .approved(request, grants):
            guard let grant = grants.first else {
    //            delegate?.didFail(with: , from: self)
                return
            }
            let details = CashAppPayDetails(paymentMethod: cashAppPayPaymentMethod, grantId: grant.id)
            submit(data: PaymentComponentData(paymentMethodDetails: details, amount: payment?.amount, order: order))
            
        default:
            break
        }
    }


    }

 #endif

