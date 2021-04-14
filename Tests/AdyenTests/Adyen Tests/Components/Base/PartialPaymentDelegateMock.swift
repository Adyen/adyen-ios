//
//  PartialPaymentDelegateMock.swift
//  AdyenDropIn
//
//  Created by Mohamed Eldoheiri on 4/22/21.
//  Copyright © 2021 Adyen. All rights reserved.
//

import Foundation
@testable import Adyen

final class PartialPaymentDelegateMock: PartialPaymentDelegate {
    var onCheckBalance: ((PaymentComponentData,
                          PaymentComponent,
                          (Result<Balance, Error>) -> Void) -> Void)?

    func checkBalance(_ data: PaymentComponentData,
                      from component: PaymentComponent,
                      completion: @escaping (Result<Balance, Error>) -> Void) {
        onCheckBalance?(data, component, completion)
    }

    var onRequestOrder: ((PaymentComponentData,
                         PaymentComponent,
                        (Result<PartialPaymentOrder, Error>) -> Void) -> Void)?

    func requestOrder(_ data: PaymentComponentData,
                      from component: PaymentComponent,
                      completion: @escaping (Result<PartialPaymentOrder, Error>) -> Void) {
        onRequestOrder?(data, component, completion)
    }

    var onCancelOrder: ((PartialPaymentOrder,
                        PaymentComponent,
                        (Error?) -> Void) -> Void)?

    func cancelOrder(_ order: PartialPaymentOrder,
                     from component: PaymentComponent,
                     completion: @escaping (Error?) -> Void) {
        onCancelOrder?(order, component, completion)
    }


}
