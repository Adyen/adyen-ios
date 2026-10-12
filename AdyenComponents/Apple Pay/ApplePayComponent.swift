//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenUI)
    import AdyenUI
#endif
import Foundation
import PassKit

/// A component that handles Apple Pay payments.
@MainActor
package class ApplePayComponent: NSObject, PaymentComponent, FinalizableComponent {

    /// The Apple Pay payment request. Kept on the configuration; exposed here as a
    /// convenience that returns the same `PKPaymentRequest` reference.
    internal var paymentRequest: PKPaymentRequest {
        configuration.paymentRequest
    }

    internal let applePayPaymentMethod: ApplePayPaymentMethod

    /// Handles the Apple Pay sheet on screen. `nil` when no sheet is shown.
    internal private(set) var authorizationHandler: ApplePayAuthorizationHandler?

    /// Creates the controller that presents the Apple Pay sheet. A new one is needed for every presentation.
    internal var makeAuthorizationController: (PKPaymentRequest) -> ApplePayAuthorizationControlling = {
        PKPaymentAuthorizationController(paymentRequest: $0)
    }

    /// The context object for this component.
    package let context: AdyenContext

    /// The Apple Pay payment method.
    package var paymentMethod: PaymentMethod {
        applePayPaymentMethod
    }

    internal let configuration: ApplePayConfiguration

    /// The delegate of the component.
    package weak var delegate: PaymentComponentDelegate?

    package let type: PaymentComponentType = .regular
    package let requiresUserInteraction: Bool = true
    
    private var presentationWindow: UIWindow? {
        viewController.viewIfLoaded?.window ?? UIApplication.shared.adyen.mainKeyWindow
    }

    /// Initializes the component.
    ///
    /// The component shows the Apple Pay button in its `viewController`. Tapping it, or calling `submit()`,
    /// opens the Apple Pay sheet. After the shopper authorizes payment, the component keeps the sheet open
    /// until `finalize(success:)` is called with the backend result.
    ///
    /// - Parameter paymentMethod: The Apple Pay payment method. Must include country code.
    /// - Parameter context: The context object for this component.
    /// - Parameter configuration: Apple Pay component configuration
    /// - Throws: `ApplePayComponent.Error.deviceDoesNotSupportApplePay` if the current device's hardware doesn't support ApplePay.
    /// - Throws: `ApplePayComponent.Error.userCannotMakePayment` if user can't make payments on any of the supported networks.
    package init(
        paymentMethod: ApplePayPaymentMethod,
        context: AdyenContext,
        configuration: ApplePayConfiguration
    ) throws {
        let supportedNetworks = try Self.validatedSupportedNetworks(
            for: paymentMethod,
            configuration: configuration
        )

        configuration.paymentRequest.supportedNetworks = supportedNetworks
        self.configuration = configuration
        self.context = context
        self.applePayPaymentMethod = paymentMethod
        super.init()

        // TODO: Move the setup analytics request out of the component
        // because _isDropIn is not used yet.
        // Inside Drop-in, this duplicates Drop-in's own setup request.
        sendInitialAnalytics()
    }

    /// The screen that contains the Apple Pay button. It's empty when `showsSubmitButton` is `false`.
    package var viewController: UIViewController {
        buttonViewController
    }

    private lazy var buttonViewController: ApplePayButtonViewController = {
        let viewController = ApplePayButtonViewController(
            appearance: configuration.buttonAppearance,
            showsSubmitButton: configuration.showsSubmitButton
        )
        viewController.onSubmit = { [weak self] in
            self?.performSubmit()
        }
        return viewController
    }()

    /// Checks the device and wallet prerequisites for Apple Pay without side effects.
    ///
    /// - Returns: The networks that the payment request should support.
    /// - Throws: `ApplePayComponent.Error.deviceDoesNotSupportApplePay` if the device doesn't support Apple Pay.
    /// - Throws: `ApplePayComponent.Error.userCannotMakePayment` if the payment method has no supported networks,
    ///   or if onboarding isn't allowed and the user can't pay with any of the supported networks.
    internal static func validatedSupportedNetworks(
        for paymentMethod: ApplePayPaymentMethod,
        configuration: ApplePayConfiguration
    ) throws -> [PKPaymentNetwork] {
        guard PKPaymentAuthorizationController.canMakePayments() else {
            throw Error.deviceDoesNotSupportApplePay
        }
        let supportedNetworks = paymentMethod.supportedNetworks()
        // Onboarding can't make up for a payment request without any supported networks.
        guard !supportedNetworks.isEmpty else {
            throw Error.userCannotMakePayment
        }
        guard configuration.allowOnboarding || canMakePaymentWith(supportedNetworks) else {
            throw Error.userCannotMakePayment
        }
        return supportedNetworks
    }

    private static func canMakePaymentWith(_ networks: [PKPaymentNetwork]) -> Bool {
        PKPaymentAuthorizationController.canMakePayments(usingNetworks: networks)
    }

    /// Shows the payment result on the Apple Pay sheet and returns once the sheet is dismissed.
    /// Returns right away when no sheet is on screen.
    /// Called by the Checkout layer once the backend payment result is known.
    ///
    /// - Parameter success: `true` if the payment succeeded, `false` otherwise.
    package func finalize(success: Bool) async {
        await authorizationHandler?.finalize(success: success)
    }

    /// Opens the Apple Pay sheet.
    ///
    /// Does nothing while the sheet is already on screen.
    /// Reports `ApplePayComponent.Error.invalidPaymentRequest` if the sheet can't be presented.
    package func performSubmit() {
        guard authorizationHandler == nil else { return }

        let handler = ApplePayAuthorizationHandler(
            controller: makeAuthorizationController(paymentRequest),
            configuration: configuration,
            presentationWindow: presentationWindow,
            onPresent: { [weak self] in
                self?.sendDidLoadEvent()
            },
            submitPayment: { [weak self] payment in
                self?.submit(payment)
            },
            onFinish: { [weak self] outcome in
                self?.authorizationHandler = nil
                self?.report(outcome)
            }
        )
        authorizationHandler = handler
        handler.start()
    }

    private func submit(_ payment: PKPayment) {
        let details = ApplePayDetails(
            paymentMethod: applePayPaymentMethod,
            token: payment.token.paymentData.base64EncodedString(),
            network: payment.token.paymentMethod.network?.rawValue ?? "",
            billingContact: payment.billingContact,
            shippingContact: payment.shippingContact,
            shippingMethod: payment.shippingMethod
        )
        submit(data: PaymentComponentData(paymentMethodDetails: details, order: order))
    }

    private func report(_ outcome: ApplePayAuthorizationHandler.Outcome) {
        switch outcome {
        case .submitted:
            break
        case .cancelled:
            delegate?.didFail(with: ComponentError.cancelled, from: self)
        case let .failed(error):
            delegate?.didFail(with: error, from: self)
        }
    }
}

// MARK: - Analytics

/// The `rendered` event is sent each time the Apple Pay sheet opens.
extension ApplePayComponent: TrackableComponent {}
