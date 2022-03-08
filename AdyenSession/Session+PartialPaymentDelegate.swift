//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

extension Session: PartialPaymentDelegate {
    
    public func checkBalance(with data: PaymentComponentData,
                             completion: @escaping (Result<Balance, Error>) -> Void) {
        let request = BalanceCheckRequest(sessionId: sessionContext.identifier,
                                          sessionData: sessionContext.data,
                                          data: data)
        apiClient.perform(request) { _ in
            // TODO: Handle result
        }
    }
    
    public func requestOrder(_ completion: @escaping (Result<PartialPaymentOrder, Error>) -> Void) {
        let request = CreateOrderRequest(sessionId: sessionContext.identifier,
                                         sessionData: sessionContext.data)
        apiClient.perform(request) { _ in
            // TODO: Handle result
        }
    }
    
    public func cancelOrder(_ order: PartialPaymentOrder) {
        let request = CancelOrderRequest(sessionId: sessionContext.identifier,
                                         sessionData: sessionContext.data,
                                         order: order)
        apiClient.perform(request) { _ in
            // TODO: Handle result
        }
    }
}
