//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import Foundation

final class PartialPaymentDelegateMock: PartialPaymentDelegate {
    var onCheckBalance: ((PaymentComponentData,
                          (Result<Balance, Error>) -> Void) -> Void)?

    func checkBalance(with data: PaymentComponentData,
                      component: Component,
                      completion: @escaping (Result<Balance, Error>) -> Void) {
        onCheckBalance?(data, completion)
    }

    var onRequestOrder: (((Result<PartialPaymentOrder, Error>) -> Void) -> Void)?

    func requestOrder(for component: Component, completion: @escaping (Result<PartialPaymentOrder, Error>) -> Void) {
        onRequestOrder?(completion)
    }

    var onCancelOrder: ((PartialPaymentOrder) -> Void)?

    func cancelOrder(_ order: PartialPaymentOrder, component: Component) {
        onCancelOrder?(order)
    }

}
