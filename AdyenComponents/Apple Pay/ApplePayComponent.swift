//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation
import PassKit

/// A component that handles Apple Pay payments.
public class ApplePayComponent: NSObject, PresentableComponent, PaymentComponent {

    internal let paymentRequest: PKPaymentRequest

    internal let applePayPaymentMethod: ApplePayPaymentMethod

    /// The continuation that bridges the gap between `submit(data:)` (fire-and-forget)
    /// and the backend result delivered via `resolve(success:)`.
    /// While suspended, the Apple Pay sheet stays on screen waiting for a `PKPaymentAuthorizationResult`.
    internal var paymentResultContinuation: CheckedContinuation<Bool, Never>?

    /// Tracks whether `handleDidAuthorize` ran and returned a result to Apple.
    /// Used by `didFinish` to distinguish user cancellation from normal sheet dismissal.
    /// Set to `true` in every exit path of `handleDidAuthorize` — including early returns
    /// for invalid tokens or failed `onAuthorize` — to prevent a spurious `didFail(.cancelled)`.
    internal var authorizationHandled = false

    /// The context object for this component.
    @_spi(AdyenInternal)
    public let context: AdyenContext

    /// The Apple Pay payment method.
    public var paymentMethod: PaymentMethod {
        applePayPaymentMethod
    }

    internal let configuration: Configuration

    internal var paymentAuthorizationViewController: PKPaymentAuthorizationViewController?

    /// The delegate of the component.
    public weak var delegate: PaymentComponentDelegate?
    
    /// Initializes the component.
    ///
    /// After the shopper authorizes payment, the component suspends the Apple Pay sheet
    /// until `resolve(success:)` is called with the backend result.
    /// The sheet then shows a success or failure animation and dismisses automatically.
    ///
    /// - Note: Do not reuse this component after a payment is authorized. It can be re-presented if the user cancels before authorizing.
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
        configuration: Configuration
    ) throws {
        guard PKPaymentAuthorizationViewController.canMakePayments() else {
            throw Error.deviceDoesNotSupportApplePay
        }
        let supportedNetworks = paymentMethod.supportedNetworks()
        guard configuration.allowOnboarding || Self.canMakePaymentWith(supportedNetworks) else {
            throw Error.userCannotMakePayment
        }

        var configuration = configuration
        self.paymentRequest = configuration.paymentRequest(with: supportedNetworks)
        self.configuration = configuration
        self.context = context
        self.applePayPaymentMethod = paymentMethod
        super.init()

        let controller = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
        guard let controller else {
            throw UnknownError(
                errorDescription: "Failed to instantiate PKPaymentAuthorizationViewController because of unknown error"
            )
        }
        controller.delegate = self
        self.paymentAuthorizationViewController = controller
        sendInitialAnalytics()
    }

    /// Returns the existing payment authorization view controller, or lazily recreates one
    /// after the user cancelled and `didFinish` cleared the previous instance.
    ///
    /// - Note: First access after recreation sends an analytics event.
    public var viewController: UIViewController {
        if paymentAuthorizationViewController == nil {
            let controller = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
            controller?.delegate = self
            paymentAuthorizationViewController = controller
        }
        if let controller = paymentAuthorizationViewController, !controller.isViewLoaded {
            sendDidLoadEvent()
        }
        guard let controller = paymentAuthorizationViewController else {
            preconditionFailure("PKPaymentAuthorizationViewController could not be created from a previously validated payment request.")
        }
        return controller
    }

    /// Called to finalize the component when the backend payment result is known.
    ///
    /// Resumes the suspended Apple Pay delegate method so the sheet shows a success/failure animation.
    /// - Parameter success: `true` if the payment succeeded, `false` otherwise.
    @MainActor
    package func resolve(success: Bool) {
        resumeContinuation(returning: success)
    }

    /// Cancels a pending authorization when the user dismisses the Apple Pay sheet
    /// before the async `didAuthorizePayment` flow has completed.
    @MainActor
    internal func cancelPendingAuthorization() {
        resumeContinuation(returning: false)
    }

    /// Atomically extracts and resumes the continuation, guaranteeing exactly-once delivery.
    @MainActor
    private func resumeContinuation(returning success: Bool) {
        let continuation = paymentResultContinuation
        paymentResultContinuation = nil
        continuation?.resume(returning: success)
    }

    private static func canMakePaymentWith(_ networks: [PKPaymentNetwork]) -> Bool {
        guard !networks.isEmpty else { return false }
        return PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: networks)
    }
}

@_spi(AdyenInternal)
extension ApplePayComponent: TrackableComponent {}
