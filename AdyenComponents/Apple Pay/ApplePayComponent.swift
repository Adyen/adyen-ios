//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
@_spi(AdyenInternal) import protocol Adyen.PresentableComponent
import Foundation
import PassKit

/// A component that handles Apple Pay payments.
@MainActor
public class ApplePayComponent: NSObject, PresentableComponent, PaymentComponent, FinalizableComponent {

    /// The Apple Pay payment request. Kept on the configuration; exposed here as a
    /// convenience that returns the same `PKPaymentRequest` reference.
    internal var paymentRequest: PKPaymentRequest {
        configuration.paymentRequest
    }

    internal let applePayPaymentMethod: ApplePayPaymentMethod

    /// The continuation that bridges the gap between `submit(data:)` (fire-and-forget)
    /// and the backend result delivered via `didFinalize(with:completion:)`.
    /// While suspended, the Apple Pay sheet stays on screen waiting for a `PKPaymentAuthorizationResult`.
    internal var paymentResultContinuation: CheckedContinuation<Bool, Never>?

    /// `true` once the shopper has tapped Pay. Lets `didFinish` distinguish a real
    /// cancellation (false) from a UI-only sheet dismissal during authorization (true).
    internal var authorizationHandled = false

    /// The context object for this component.
    @_spi(AdyenInternal)
    public let context: AdyenContext

    /// The Apple Pay payment method.
    public var paymentMethod: PaymentMethod {
        applePayPaymentMethod
    }

    internal let configuration: ApplePayConfiguration

    internal var paymentAuthorizationViewController: PKPaymentAuthorizationViewController?

    /// The delegate of the component.
    public weak var delegate: PaymentComponentDelegate?
    
    /// Initializes the component.
    ///
    /// After the shopper authorizes payment, the component suspends the Apple Pay sheet
    /// until `didFinalize(with:completion:)` is called with the backend result.
    /// The sheet then shows a success or failure animation and dismisses automatically.
    ///
    /// - Note: Do not reuse this component. Create a fresh instance per payment attempt.
    ///
    /// - Parameter paymentMethod: The Apple Pay payment method. Must include country code.
    /// - Parameter context: The context object for this component.
    /// - Parameter configuration: Apple Pay component configuration
    /// - Throws: `ApplePayComponent.Error.userCannotMakePayment`.
    /// if user can't make payments on any of the payment request’s supported networks.
    /// - Throws: `ApplePayComponent.Error.deviceDoesNotSupportApplePay` if the current device's hardware doesn't support ApplePay.
    /// - Throws: `ApplePayComponent.Error.userCannotMakePayment` if user can't make payments on any of the supported networks.
    public init(
        paymentMethod: ApplePayPaymentMethod,
        context: AdyenContext,
        configuration: ApplePayConfiguration
    ) throws {
        guard PKPaymentAuthorizationViewController.canMakePayments() else {
            throw Error.deviceDoesNotSupportApplePay
        }
        let supportedNetworks = paymentMethod.supportedNetworks()
        guard configuration.allowOnboarding || Self.canMakePaymentWith(supportedNetworks) else {
            throw Error.userCannotMakePayment
        }

        configuration.paymentRequest.supportedNetworks = supportedNetworks
        self.configuration = configuration
        self.context = context
        self.applePayPaymentMethod = paymentMethod
        super.init()

        let controller = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
        guard let controller else {
            throw UnknownError(
                errorDescription: "Failed to instantiate PKPaymentAuthorizationViewController. "
                    + "This usually indicates the payment request is missing required fields or contains invalid values."
            )
        }
        controller.delegate = self
        self.paymentAuthorizationViewController = controller
        sendInitialAnalytics()
    }

    /// Returns the payment authorization view controller created during initialization.
    ///
    /// - Important: Do not access this property after the component has been used and dismissed.
    ///   Create a new `ApplePayComponent` instance for each payment attempt.
    public var viewController: UIViewController {
        guard let controller = paymentAuthorizationViewController else {
            preconditionFailure(
                "The Apple Pay view controller is no longer available. "
                    + "Create a new ApplePayComponent instance for each payment attempt."
            )
        }
        if !controller.isViewLoaded {
            sendDidLoadEvent()
        }
        return controller
    }

    /// Cancels a pending authorization when the user dismisses the Apple Pay sheet
    /// before the async `didAuthorizePayment` flow has completed.
    internal func cancelPendingAuthorization() {
        resumeContinuation(success: false)
    }

    /// Extracts and resumes the continuation, guaranteeing exactly-once delivery
    /// via MainActor serialization.
    private func resumeContinuation(success: Bool) {
        let continuation = paymentResultContinuation
        paymentResultContinuation = nil
        continuation?.resume(returning: success)
    }

    private static func canMakePaymentWith(_ networks: [PKPaymentNetwork]) -> Bool {
        guard !networks.isEmpty else { return false }
        return PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: networks)
    }
    
    // TODO: turn this into async, as now the sheet dismisses immediately
    // before user can see the success checkmark on Apple Pay
    /// Resumes the suspended Apple Pay authorization so the sheet shows a success/failure animation
    /// and dismisses. Called by the Checkout layer once the backend payment result is known.
    ///
    /// - Parameters:
    ///   - success: `true` if the payment succeeded, `false` otherwise.
    ///   - completion: Invoked once the continuation has been resumed.
    public func didFinalize(with success: Bool, completion: (() -> Void)?) {
        resumeContinuation(success: success)
        completion?()
    }

    public func submit() {
        // TODO: - Check where to perform submit in ApplePay. I dont think it applies here.
    }
}

@_spi(AdyenInternal)
extension ApplePayComponent: TrackableComponent {}
