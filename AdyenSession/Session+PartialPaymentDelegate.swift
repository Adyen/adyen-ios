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
        // TODO: Check balance
    }
    
    public func requestOrder(_ completion: @escaping (Result<PartialPaymentOrder, Error>) -> Void) {
        // TODO: Request new Order
    }
    
    public func cancelOrder(_ order: PartialPaymentOrder) {
        // TODO: Cancel Order
    }
}
