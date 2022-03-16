//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenActions)
    import AdyenActions
#endif
import Foundation

/// :nodoc:
extension Session: PaymentComponentDelegate {
    public func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent) {
        didSubmit(data, currentComponent: component)
    }
    
    internal func didSubmit(_ data: PaymentComponentData, currentComponent: Component) {
        let request = PaymentsRequest(sessionId: sessionContext.identifier,
                                      sessionData: sessionContext.data,
                                      data: data)
        apiClient.perform(request) { [weak self] in
            self?.handle(paymentResponseResult: $0, for: currentComponent)
        }
    }
    
    internal func handle(paymentResponseResult: Result<PaymentsResponse, Error>,
                         for currentComponent: Component) {
        switch paymentResponseResult {
        case let .success(response):
            handle(paymentResponse: response, for: currentComponent)
        case let .failure(error):
            finish(with: error)
        }
    }
    
    private func handle(paymentResponse response: PaymentsResponse,
                        for currentComponent: Component) {
        if let action = response.action {
            handle(action: action, for: currentComponent)
        } else if let order = response.order,
                  let remainingAmount = order.remainingAmount,
                  remainingAmount.value > 0 {
            handle(order: order, for: currentComponent)
        } else {
            finish()
        }
    }
    
    private func handle(action: Action, for currentComponent: Component) {
        if let component = currentComponent as? ActionHandlingComponent {
            component.handle(action)
        } else {
            actionComponent.handle(action)
        }
    }
    
    private func handle(order: PartialPaymentOrder, for currentComponent: Component) {
        Self.makeSetupCall(with: configuration,
                           baseAPIClient: apiClient,
                           order: order) { [weak self] result in
            self?.updateContext(with: result)
            self?.reload(currentComponent: currentComponent, with: order)
        }
    }
    
    private func updateContext(with result: Result<Context, Error>) {
        switch result {
        case let .success(context):
            sessionContext = context
        case let .failure(error):
            finish(with: error)
        }
    }
    
    private func reload(currentComponent: Component, with order: PartialPaymentOrder) {
        do {
            guard let currentComponent = currentComponent as? AnyDropInComponent else {
                throw PartialPaymentError.notSupportedForComponent
            }
            try currentComponent.reload(with: order, sessionContext.paymentMethods)
        } catch {
            finish(with: error)
        }
    }
    
    internal func finish() {
        // TODO: Handle Finish
    }
    
    internal func finish(with error: Error) {
        // TODO: Handle Finish
    }

    public func didFail(with error: Error, from component: PaymentComponent) {
        didFail(with: error, currentComponent: component)
    }
    
    internal func didFail(with error: Error, currentComponent: Component) {
        // TODO: call back the merchant
    }
}
