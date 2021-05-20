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
                          (Result<Balance, Error>) -> Void) -> Void)?

    func checkBalance(with data: PaymentComponentData,
                      completion: @escaping (Result<Balance, Error>) -> Void) {
        onCheckBalance?(data, completion)
    }

    var onRequestOrder: (((Result<PartialPaymentOrder, Error>) -> Void) -> Void)?

    func requestOrder(_ completion: @escaping (Result<PartialPaymentOrder, Error>) -> Void) {
        onRequestOrder?(completion)
    }

    var onCancelOrder: ((PartialPaymentOrder) -> Void)?

    func cancelOrder(_ order: PartialPaymentOrder) {
        onCancelOrder?(order)
    }


}
