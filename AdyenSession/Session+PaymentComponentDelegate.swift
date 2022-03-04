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

extension Session: PaymentComponentDelegate {
    public func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent) {
        let request = PaymentsRequest(sessionId: sessionContext.idenitifier,
                                      sessionData: sessionContext.data,
                                      data: data)
        apiClient.perform(request, completionHandler: paymentResponseHandler)
    }
    
    internal func paymentResponseHandler(result: Result<PaymentsResponse, Error>) {
        switch result {
        case let .success(response):
            updateContext(with: response)
            if let action = response.action {
                handle(action)
            } else if let order = response.order,
                      let remainingAmount = order.remainingAmount,
                      remainingAmount.value > 0 {
                handle(order)
            } else {
                finish(with: response.resultCode)
            }
        case let .failure(error):
            finish(with: error)
        }
    }
    
    private func updateContext(with response: PaymentsResponse) {
        sessionContext.data = response.sessionData
    }
    
    private func handle(_ action: Action) {
        // TODO: Handle Action
    }
    
    private func handle(_ order: PartialPaymentOrder) {
        // TODO: Handle Order
    }
    
    private func finish(with resultCode: PaymentsResponse.ResultCode) {
        // TODO: Handle Finish
    }
    
    private func finish(with error: Error) {
        // TODO: Handle Finish
    }

    public func didFail(with error: Error, from component: PaymentComponent) {
        // TODO: call back the merchant
    }
}
