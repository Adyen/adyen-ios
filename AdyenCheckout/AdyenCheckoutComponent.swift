//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
@_spi(AdyenInternal) import AdyenSession
@_spi(AdyenInternal) import AdyenDropIn
@_spi(AdyenInternal) import AdyenComponents
@_spi(AdyenInternal) import AdyenActions

// TODO: add description
public final class AdyenCheckoutComponent {
    
    private var paymentComponent: PaymentComponent?
    
    private var actionComponent: ActionComponent?
    
    private var actionHandlingComponent: ActionHandlingComponent?
    
    private var configuration: CheckoutConfiguration
    
    package init(
        paymentMethod: PaymentMethod,
        configuration: CheckoutConfiguration,
        session: AdyenSession? = nil
    ) {
        self.configuration = configuration
        self.paymentComponent = CheckoutComponentBuilder.build(for: paymentMethod, configuration: configuration)
        self.paymentComponent?.delegate = self
    }
    
    package init(
        action: Action,
        configuration: CheckoutConfiguration,
        session: AdyenSession? = nil
    ) {
        self.configuration = configuration
        self.actionComponent = CheckoutComponentBuilder.build(for: action, configuration: configuration)
    }
}

extension AdyenCheckoutComponent: PaymentComponentDelegate {
    
    public func didSubmit(_ data: PaymentComponentData, from component: any PaymentComponent) {
        configuration.onSubmit?(data) { [weak self] response in
            guard let self else { return }
            self.handle(response)
        }
    }
    
    public func didFail(with error: any Error, from component: any PaymentComponent) {}
    
    private func handle(_ paymentsResponse: CheckoutPaymentsResponse) {
        if let action = paymentsResponse.action {
            // handle action
        } else {
            finish(with: CheckoutResult(resultCode: paymentsResponse.resultCode))
        }
    }
    
    private func finish(with result: CheckoutResult) {
        // add any finalizing code if needed
        configuration.onComplete?(result)
    }
    
    private func finish(with error: Error) {
        // add any finalizing code if needed
        configuration.onError?(CheckoutError(error: error))
    }
}
