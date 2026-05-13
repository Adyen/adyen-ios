//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenSession)
    import AdyenSession
#endif
#if canImport(AdyenDropIn)
    import AdyenDropIn
#endif
#if canImport(AdyenActions)
    import AdyenActions
#endif
#if canImport(AdyenComponents)
    import AdyenComponents
#endif
import Foundation

@MainActor
package protocol CheckoutCoreProtocol: AnyObject {
    var session: SessionProtocol? { get }

    var paymentMethods: PaymentMethods? { get }

    func handle(action: Action)

    func createPaymentComponent(for type: PaymentMethodType) throws -> CheckoutPaymentComponent

    func createPaymentComponent(for identifier: String) throws -> CheckoutPaymentComponent

    func createDropIn() -> DropInComponent?
}

@MainActor
package final class CheckoutCore: CheckoutCoreProtocol {

    package let paymentMethods: PaymentMethods?
    package let session: SessionProtocol?

    package let configuration: CheckoutConfiguration
    package weak var presentationDelegate: PresentationDelegate?
    package let adyenContext: AdyenContext
    package let resultCallbacks: any CheckoutResultCallbackStore
    package let submissionHandler: any CheckoutSubmissionHandling

    internal lazy var actionHandlingComponent: ActionHandlingComponent = {
        let authenticationConfiguration: AuthenticationConfiguration = configuration.configuration(
            for: .threeDS2,
            defaultValue: AuthenticationConfiguration(theme: configuration.theme)
        )

        let twintConfig: TwintActionConfiguration? = configuration.configuration(for: .twint)

        let actionConfig = CheckoutActionComponent.Configuration(
            authentication: authenticationConfiguration,
            twint: twintConfig
        )

        let handler = CheckoutActionComponent(
            context: adyenContext,
            configuration: actionConfig
        )
        handler.delegate = self
        handler.presentationDelegate = presentationDelegate
        return handler
    }()

    internal var submitTask: Task<Void, Never>?
    internal var additionalDetailsTask: Task<Void, Never>?

    internal weak var pendingPaymentComponent: (any PaymentComponent)?

    package init(
        configuration: CheckoutConfiguration,
        session: SessionProtocol? = nil,
        paymentMethods: PaymentMethods? = nil,
        adyenContext: AdyenContext,
        presentationDelegate: PresentationDelegate?,
        resultCallbacks: any CheckoutResultCallbackStore,
        submissionHandler: any CheckoutSubmissionHandling
    ) {
        self.configuration = configuration
        self.session = session
        self.paymentMethods = paymentMethods ?? session?.state.paymentMethods
        self.presentationDelegate = presentationDelegate
        self.adyenContext = adyenContext
        self.resultCallbacks = resultCallbacks
        self.submissionHandler = submissionHandler
        self.session?.presentationDelegate = presentationDelegate
    }

    deinit {
        submitTask?.cancel()
        additionalDetailsTask?.cancel()
    }

    package func createPaymentComponent(for type: PaymentMethodType) throws -> CheckoutPaymentComponent {
        guard let paymentMethod = paymentMethods?.paymentMethod(ofType: type) else {
            throw UnknownError(
                errorDescription: "Payment method \(type.rawValue) is not available in the current payment methods."
            )
        }

        return try CheckoutPaymentComponent(
            paymentMethod: paymentMethod,
            configuration: configuration,
            context: adyenContext,
            delegate: self
        )
    }

    package func createPaymentComponent(for identifier: String) throws -> CheckoutPaymentComponent {
        guard let storedPaymentMethod = paymentMethods?.stored.first(where: { $0.identifier == identifier }) else {
            throw UnknownError(
                errorDescription: "No stored payment method found for identifier \(identifier)."
            )
        }

        return CheckoutPaymentComponent(
            storedPaymentMethod: storedPaymentMethod,
            configuration: configuration,
            context: adyenContext,
            delegate: self
        )
    }

    package func createDropIn() -> DropInComponent? {
        // TODO: dropin creation discussion with new changes
        nil
    }

    package func handle(action: Action) {
        actionHandlingComponent.handle(action)
    }
}
