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

    /// PassKit waits on this for the payment result after the shopper taps Pay.
    /// `submit(data:)` doesn't return a result, so it arrives later through `finalize(success:)`.
    internal var paymentResultContinuation: CheckedContinuation<Bool, Never>?

    /// How the sheet ended, from the component's point of view.
    internal enum SheetOutcome {
        /// The shopper closed the sheet without paying.
        case cancelled
        /// The shopper tapped Pay. The payment result is reported by the Checkout layer.
        case authorized
        /// The sheet closed because of an error.
        case failed(Swift.Error)
    }

    /// What to report once the sheet is gone. Updated while the sheet is on screen.
    internal var sheetOutcome = SheetOutcome.cancelled

    /// Runs while the sheet is on screen and keeps the component alive. `finalize(success:)` waits for it.
    /// `nil` when no sheet is shown.
    internal var sheetTask: Task<Void, Never>?

    /// `sheetTask` waits on this until the sheet must close. Resumed by `requestSheetClose()`.
    private var sheetCloseContinuation: CheckedContinuation<Void, Never>?

    /// Set by `requestSheetClose()`, so a close that arrives before `sheetTask` waits isn't lost.
    private var isSheetCloseRequested = false

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

    /// Extracts and resumes the continuation, guaranteeing exactly-once delivery
    /// via MainActor serialization.
    private func resumeContinuation(success: Bool) {
        let continuation = paymentResultContinuation
        paymentResultContinuation = nil
        continuation?.resume(returning: success)
    }
    
    /// Shows the payment result on the Apple Pay sheet and returns once the sheet is dismissed.
    /// Returns right away when no sheet is on screen.
    /// Called by the Checkout layer once the backend payment result is known.
    ///
    /// - Parameter success: `true` if the payment succeeded, `false` otherwise.
    package func finalize(success: Bool) async {
        resumeContinuation(success: success)
        await sheetTask?.value
    }

    /// Opens the Apple Pay sheet.
    ///
    /// Does nothing while the sheet is already on screen.
    /// Reports `ApplePayComponent.Error.invalidPaymentRequest` if the sheet can't be presented.
    package func performSubmit() {
        guard sheetTask == nil else { return }

        // An authorization that the shopper dismissed while `onAuthorize` ran can still wait for a result.
        resumeContinuation(success: false)
        sheetOutcome = .cancelled
        isSheetCloseRequested = false

        let controller = makeAuthorizationController(paymentRequest)
        controller.delegate = self
        // Set before presenting, so repeated taps are ignored before the sheet appears.
        sheetTask = Task {
            await showSheet(using: controller)
        }
    }

    /// Called when PassKit reports that the sheet finished, and when the sheet must close because of an error.
    internal func requestSheetClose() {
        isSheetCloseRequested = true
        sheetCloseContinuation?.resume()
        sheetCloseContinuation = nil
    }

    /// Presents the sheet, keeps it until `requestSheetClose()` is called, then dismisses it and reports `sheetOutcome`.
    private func showSheet(using controller: ApplePayAuthorizationControlling) async {
        guard await controller.present() else {
            sheetTask = nil
            delegate?.didFail(with: Error.invalidPaymentRequest, from: self)
            return
        }
        sendDidLoadEvent()

        if !isSheetCloseRequested {
            await withCheckedContinuation { sheetCloseContinuation = $0 }
        }
        await controller.dismiss()
        sheetTask = nil
        // PassKit stopped waiting for a result, for example after its timeout.
        resumeContinuation(success: false)

        // Reported after the task ends, so the `finalize(success:)` it leads to doesn't wait for this task.
        switch sheetOutcome {
        case .authorized:
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
