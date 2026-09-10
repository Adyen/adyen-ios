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
    package let callbackHandler: any CheckoutCallbackHandling

    internal lazy var actionComponentConfiguration: CheckoutActionComponent.Configuration = {
        var authenticationConfiguration: AuthenticationConfiguration = configuration.configuration(
            for: .threeDS2,
            defaultValue: AuthenticationConfiguration(theme: configuration.theme)
        )
        authenticationConfiguration.localizationParameters = configuration.resolvedCheckoutLocalizationParameters(
            mergingExistingParameters: authenticationConfiguration.localizationParameters
        )

        return CheckoutActionComponent.Configuration(
            localizationParameters: configuration.resolvedCheckoutLocalizationParameters(),
            authentication: authenticationConfiguration,
            twint: configuration.configuration(for: .twint)
        )
    }()

    internal lazy var actionHandlingComponent: ActionHandlingComponent = {
        let actionHandlingComponent = CheckoutActionComponent(
            context: adyenContext,
            configuration: actionComponentConfiguration
        )
        actionHandlingComponent.delegate = self
        actionHandlingComponent.presentationDelegate = presentationDelegate
        return actionHandlingComponent
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
        callbackHandler: any CheckoutCallbackHandling
    ) {
        self.configuration = configuration
        self.session = session
        self.paymentMethods = paymentMethods ?? session?.state.paymentMethods
        self.presentationDelegate = presentationDelegate
        self.adyenContext = adyenContext
        self.resultCallbacks = resultCallbacks
        self.callbackHandler = callbackHandler
        self.session?.presentationDelegate = presentationDelegate
    }

    deinit {
        submitTask?.cancel()
        additionalDetailsTask?.cancel()
    }

    package func createPaymentComponent(for type: PaymentMethodType) throws -> CheckoutPaymentComponent {
        guard let paymentMethod = paymentMethods?.paymentMethod(ofType: type) else {
            throw CheckoutError(
                code: .paymentMethodFailure,
                message: "Payment method \(type.rawValue) is not available in the current payment methods."
            )
        }

        let paymentComponent = try CheckoutComponentBuilder.build(
            for: paymentMethod,
            configuration: configuration,
            sessionConfiguration: session?.componentConfiguration,
            context: adyenContext
        )
        paymentComponent.delegate = self
        return CheckoutPaymentComponent(paymentComponent: paymentComponent)
    }

    package func createPaymentComponent(for identifier: String) throws -> CheckoutPaymentComponent {
        guard let storedPaymentMethod = paymentMethods?.stored.first(where: { $0.identifier == identifier }) else {
            throw CheckoutError(code: .paymentMethodFailure, message: "No stored payment method found for identifier \(identifier).")
        }

        let paymentComponent = CheckoutComponentBuilder.build(
            for: storedPaymentMethod,
            configuration: configuration,
            context: adyenContext
        )
        paymentComponent.delegate = self
        return CheckoutPaymentComponent(paymentComponent: paymentComponent)
    }

    package func createDropIn() -> DropInComponent? {
        guard let paymentMethods else { return nil }

        let checkoutConfiguration = configuration
        let sessionConfiguration = session?.componentConfiguration
        let context = adyenContext
        let paymentComponentBuilder: DropInPaymentComponentBuilder = { paymentMethod in
            try CheckoutComponentBuilder.build(
                forAnyPaymentMethod: paymentMethod,
                configuration: checkoutConfiguration,
                sessionConfiguration: sessionConfiguration,
                context: context
            )
        }
        let dropInComponent = CheckoutComponentBuilder.buildDropIn(
            paymentMethods: paymentMethods,
            configuration: checkoutConfiguration,
            context: context,
            actionComponentConfiguration: actionComponentConfiguration,
            managementCapability: sessionManagementCapability,
            paymentComponentBuilder: paymentComponentBuilder
        )
        dropInComponent.delegate = self
        return dropInComponent
    }

    package func handle(action: Action) {
        actionHandlingComponent.handle(action)
    }
}

private extension CheckoutCore {

    var sessionManagementCapability: StoredPaymentMethodManagementCapability? {
        guard let session, session.showRemovePaymentMethodButton else { return nil }

        return StoredPaymentMethodManagementCapability { [weak session] storedPaymentMethod in
            guard let session else {
                throw StoredPaymentMethodRemovalError.unavailable
            }
            try await session.disable(storedPaymentMethod: storedPaymentMethod)
        }
    }
}
