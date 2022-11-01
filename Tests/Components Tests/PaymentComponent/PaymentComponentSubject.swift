//
//  PaymentComponentSubject.swift
//  AdyenUIHost
//
//  Created by Naufal Aros on 09/06/2022.
//  Copyright © 2022 Adyen. All rights reserved.
//

import Adyen
import Foundation

class PaymentComponentSubject: PaymentComponent {

    // MARK: - Properties

    var context: AdyenContext
    var delegate: PaymentComponentDelegate?
    var payment: Payment?
    var order: PartialPaymentOrder?
    var paymentMethod: PaymentMethod

    // MARK: - Initializers

    public init(context: AdyenContext,
                delegate: PaymentComponentDelegate,
                payment: Payment?,
                order: PartialPaymentOrder?,
                paymentMethod: PaymentMethod) {
        self.context = context
        self.delegate = delegate
        self.payment = payment
        self.order = order
        self.paymentMethod = paymentMethod
        self.payment = payment
    }
}
