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
    public final class CashAppComponent: PaymentComponent,
        PaymentAware {

        /// Configuration object for Cash App Component
        public struct Configuration {

            /// The component UI style.
            public var style: ListComponentStyle

            /// The localization parameters, leave it nil to use the default parameters.
            public var localizationParameters: LocalizationParameters?

            /// The URL for Cash App to call in order to redirect back to your application.
            public let redirectURL: URL

            /// Initializes an instance of `Configuration`
            ///
            /// - Parameters:
            ///   - style: The Component UI style.
            ///   - localizationParameters: The localization parameters, leave it nil to use the default parameters.
            public init(redirectURL: URL,
                        style: ListComponentStyle = ListComponentStyle(),
                        localizationParameters: LocalizationParameters? = nil) {
                self.redirectURL = redirectURL
                self.style = style
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

        /// The viewController for the component.
//        public lazy var viewController: UIViewController = SecuredViewController(child: formViewController,
//                                                                                 style: configuration.style)

        /// This indicates that `viewController` expected to be presented modally,
//        public var requiresModalPresentation: Bool = true

        /// Component's configuration
        public var configuration: Configuration

        private let cashAppPayPaymentMethod: CashAppPayPaymentMethod

        /// Initializes the UPI  component.
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

//        public func stopLoading() {
//            continueButton.showsActivityIndicator = false
//            formViewController.view.isUserInteractionEnabled = true
//        }

    }

#endif
