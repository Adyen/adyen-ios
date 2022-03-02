//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

extension DropInSession: PartialPaymentDelegate {
    public func checkBalance(with data: PaymentComponentData, completion: @escaping (Result<Balance, Error>) -> Void) {
        session?.checkBalance(with: data, completion: completion)
    }
    
    public func requestOrder(_ completion: @escaping (Result<PartialPaymentOrder, Error>) -> Void) {
        session?.requestOrder(completion)
    }
    
    public func cancelOrder(_ order: PartialPaymentOrder) {
        session?.cancelOrder(order)
    }
}
