//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import PassKit

/// A component that handles Apple Pay payments.
public class ApplePayComponent: NSObject, PresentableComponent, PaymentComponent, FinalizableComponent {

    private let paymentRequest: PKPaymentRequest

    internal var resultConfirmed: Bool = false

    internal var viewControllerDidFinish: Bool = false

    internal let applePayPaymentMethod: ApplePayPaymentMethod

    
    /// The Adyen context
    public let adyenContext: AdyenContext

    /// The Apple Pay payment method.
    public var paymentMethod: PaymentMethod { applePayPaymentMethod }

    /// Read-only payment property. Set `payment` is not supported on ApplePayComponent.
    public var payment: Payment? {
        configuration.applePayPayment.payment
    }

    internal let configuration: Configuration

    internal var paymentAuthorizationViewController: PKPaymentAuthorizationViewController?

    internal var paymentAuthorizationCompletion: ((PKPaymentAuthorizationStatus) -> Void)?

    internal var finalizeCompletion: (() -> Void)?
    
    /// The delegate of the component.
    public weak var delegate: PaymentComponentDelegate?
    
    /// Initializes the component.
    /// - Warning: Do not dismiss this component.
    ///  First, call `didFinalize(with:completion:)` on error or success, then dismiss it.
    ///  Dismissal should occur within `completion` block.
    ///
    /// - Parameter paymentMethod: The Apple Pay payment method. Must include country code.
    /// - Parameter apiContext: The API environment and credentials.
    /// - Parameter adyenContext: The Adyen context.
    /// - Parameter configuration: Apple Pay component configuration
    /// - Throws: `ApplePayComponent.Error.userCannotMakePayment`.
    /// if user can't make payments on any of the payment request’s supported networks.
    /// - Throws: `ApplePayComponent.Error.deviceDoesNotSupportApplyPay` if the current device's hardware doesn't support ApplePay.
    /// - Throws: `ApplePayComponent.Error.userCannotMakePayment` if user can't make payments on any of the supported networks.
    public init(paymentMethod: ApplePayPaymentMethod,
                adyenContext: AdyenContext,
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
        self.adyenContext = adyenContext
        self.paymentAuthorizationViewController = viewController
        self.applePayPaymentMethod = paymentMethod
        super.init()

        viewController.delegate = self
    }

    public var viewController: UIViewController {
        createPaymentAuthorizationViewController()
    }

    public func didFinalize(with success: Bool, completion: (() -> Void)?) {
        self.resultConfirmed = true
        if let paymentAuthorizationCompletion = paymentAuthorizationCompletion {
            finalizeCompletion = completion
            paymentAuthorizationCompletion(success ? .success : .failure)
            self.paymentAuthorizationCompletion = nil
        } else {
            completion?()
        }
    }

    // MARK: - Private

    private func createPaymentAuthorizationViewController() -> PKPaymentAuthorizationViewController {
        if paymentAuthorizationViewController == nil {
            paymentAuthorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
            paymentAuthorizationViewController?.delegate = self
            paymentAuthorizationCompletion = nil
            resultConfirmed = false
        }
        return paymentAuthorizationViewController!
    }

    private static func canMakePaymentWith(_ networks: [PKPaymentNetwork]) -> Bool {
        PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: networks)
    }
}

extension ApplePayComponent: TrackableComponent {}

extension ApplePayComponent: ViewControllerDelegate {
    public func viewDidLoad(viewController: UIViewController) { /* Empty implementation */ }

    public func viewDidAppear(viewController: UIViewController) { /* Empty implementation */ }

    public func viewWillAppear(viewController: UIViewController) {
        sendTelemetryEvent()
    }
}
