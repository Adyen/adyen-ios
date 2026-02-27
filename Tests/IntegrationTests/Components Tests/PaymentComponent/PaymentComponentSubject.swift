//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation
import UIKit

class PaymentComponentSubject: PaymentComponent, PresentableComponent {

    // MARK: - Properties

    var context: AdyenContext
    var delegate: PaymentComponentDelegate?
    var payment: Payment?
    var order: PartialPaymentOrder?
    var paymentMethod: PaymentMethod

    /// PresentableComponent requirement
    var viewController: UIViewController {
        UIViewController()
    }

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
