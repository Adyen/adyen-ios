//
//  PartialPaymentDelegateMock.swift
//  AdyenDropIn
//
//  Created by Mohamed Eldoheiri on 4/22/21.
//  Copyright © 2021 Adyen. All rights reserved.
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
