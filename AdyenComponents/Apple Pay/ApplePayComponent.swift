//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation
import PassKit

/// A component that handles Apple Pay payments.
public class ApplePayComponent: NSObject, PresentableComponent, PaymentComponent, FinalizableComponent {

    private let paymentRequest: PKPaymentRequest

    internal var applePayPayment: ApplePayPayment

    internal var state: State = .initial

    internal var viewControllerDidFinish: Bool = false

    internal let applePayPaymentMethod: ApplePayPaymentMethod

    /// The context object for this component.
    @_spi(AdyenInternal)
    public let context: AdyenContext

    /// The Apple Pay payment method.
    public var paymentMethod: PaymentMethod { applePayPaymentMethod }

    internal let configuration: Configuration

    internal var paymentAuthorizationViewController: PKPaymentAuthorizationViewController?

    /// The delegate of the component.
    public weak var delegate: PaymentComponentDelegate?

    /// The delegate changes of ApplePay payment state.
    public weak var applePayDelegate: ApplePayComponentDelegate?
    
    /// Initializes the component.
    /// - Warning: Do not dismiss this component.
    ///  First, call `didFinalize(with:completion:)` on error or success, then dismiss it.
    ///  Dismissal should occur within `completion` block.
    ///
    /// - Parameter paymentMethod: The Apple Pay payment method. Must include country code.
    /// - Parameter context: The context object for this component.
    /// - Parameter configuration: Apple Pay component configuration
    /// - Throws: `ApplePayComponent.Error.userCannotMakePayment`.
    /// if user can't make payments on any of the payment request’s supported networks.
    /// - Throws: `ApplePayComponent.Error.deviceDoesNotSupportApplyPay` if the current device's hardware doesn't support ApplePay.
    /// - Throws: `ApplePayComponent.Error.userCannotMakePayment` if user can't make payments on any of the supported networks.
    public init(paymentMethod: ApplePayPaymentMethod,
                context: AdyenContext,
                configuration: Configuration) throws {
        guard PKPaymentAuthorizationViewController.canMakePayments() else {
            throw Error.deviceDoesNotSupportApplyPay
        }
        let supportedNetworks = paymentMethod.supportedNetworks
        guard configuration.allowOnboarding || Self.canMakePaymentWith(supportedNetworks) else {
            throw Error.userCannotMakePayment
        }

        self.paymentRequest = configuration.createPaymentRequest(supportedNetworks: supportedNetworks)
        guard let viewController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest) else {
            throw UnknownError(
                errorDescription: "Failed to instantiate PKPaymentAuthorizationViewController because of unknown error"
            )
        }

        self.configuration = configuration
        self.context = context
        self.paymentAuthorizationViewController = viewController
        self.applePayPaymentMethod = paymentMethod
        self.applePayPayment = configuration.applePayPayment
        super.init()

        viewController.delegate = self
    }

    public var viewController: UIViewController {
        createPaymentAuthorizationViewController()
    }

    public func didFinalize(with success: Bool, completion: (() -> Void)?) {
        if case let .paid(paymentAuthorizationCompletion) = state {
            state = .finalized(completion)
            paymentAuthorizationCompletion(success ? .success : .failure)
        } else {
            state = .initial
            completion?()
        }
    }

    internal func update(payment: Payment?) throws {
        guard let payment = payment else {
            throw ApplePayComponent.Error.negativeGrandTotal
        }

        applePayPayment = try ApplePayPayment(payment: payment, brand: applePayPayment.brand)
    }

    // MARK: - Private

    private func createPaymentAuthorizationViewController() -> PKPaymentAuthorizationViewController {
        if paymentAuthorizationViewController == nil {
            paymentAuthorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
            paymentAuthorizationViewController?.delegate = self
            state = .initial
        }
        return paymentAuthorizationViewController!
    }

    private static func canMakePaymentWith(_ networks: [PKPaymentNetwork]) -> Bool {
        PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: networks)
    }
}

extension ApplePayComponent {

    internal enum State {
        case initial
        case paid((PKPaymentAuthorizationStatus) -> Void)
        case finalized((() -> Void)?)
    }

}

@_spi(AdyenInternal)
extension ApplePayComponent: TrackableComponent {}

@_spi(AdyenInternal)
extension ApplePayComponent: ViewControllerDelegate {
    public func viewDidLoad(viewController: UIViewController) { /* Empty implementation */ }

    public func viewDidAppear(viewController: UIViewController) { /* Empty implementation */ }

    public func viewWillAppear(viewController: UIViewController) {
        sendTelemetryEvent()
    }
}
