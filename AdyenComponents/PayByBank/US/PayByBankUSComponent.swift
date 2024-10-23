//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen

/// A component that handles a Twint payment.
public final class PayByBankUSComponent: PaymentComponent, PresentableComponent {

    /// The context object for this component.
    @_spi(AdyenInternal)
    public let context: AdyenContext

    /// The payment method object for this component.
    public let paymentMethod: PaymentMethod
    
    /// The ready to submit payment data.
    public var paymentData: PaymentComponentData {
        let details = InstantPaymentDetails(type: paymentMethod.type)

        return PaymentComponentData(
            paymentMethodDetails: details,
            amount: context.payment?.amount,
            order: order
        )
    }

    /// Component's configuration
    public var configuration: Configuration

    /// The delegate of the component.
    public weak var delegate: PaymentComponentDelegate?
    
    public var requiresModalPresentation: Bool = true
    
    public var viewController: UIViewController {
        confirmationViewController
    }
    
    private lazy var confirmationViewController: ConfirmationViewController = {

        let headerImageUrl = LogoURLProvider.logoURL(
            withName: paymentMethod.type.rawValue,
            environment: context.apiContext.environment
        )
        
        return .init(
            model: .init(
                headerImageUrl: headerImageUrl,
                style: configuration.style,
                continueHandler: { [weak self] in
                    self?.initiatePayment()
                }
            )
        )
    }()

    // MARK: - Initializers

    /// Initializes the Twint component.
    ///
    /// - Parameter paymentMethod: The Twint  payment method.
    /// - Parameter context: The context object for this component.
    /// - Parameter configuration: The configuration for the component.
    public init(
        paymentMethod: PayByBankUSPaymentMethod,
        context: AdyenContext,
        configuration: Configuration = .init()
    ) {
        self.paymentMethod = paymentMethod
        self.context = context
        self.configuration = configuration
    }

    // MARK: - PaymentInitiable

    /// Generate the payment details and invoke PaymentsComponentDelegate method.
    public func initiatePayment() {
        submit(data: paymentData)
    }
}

@_spi(AdyenInternal)
extension PayByBankUSComponent: TrackableComponent {}

extension PayByBankUSComponent: LoadingComponent {
    public func stopLoading() {
        confirmationViewController.submitButton.showsActivityIndicator = false
    }
}
