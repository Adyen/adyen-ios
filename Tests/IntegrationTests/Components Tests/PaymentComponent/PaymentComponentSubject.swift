//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
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
    var type: ComponentType = .undefined

    // MARK: - Initializers

    public init(
        context: AdyenContext,
        delegate: PaymentComponentDelegate,
        payment: Payment?,
        order: PartialPaymentOrder?,
        paymentMethod: PaymentMethod
    ) {
        self.context = context
        self.delegate = delegate
        self.payment = payment
        self.order = order
        self.paymentMethod = paymentMethod
        self.payment = payment
    }
}
