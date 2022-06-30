//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Any component with a payment property.
public protocol PaymentAwareComponent: Component {

    /// The payment information.
    var payment: Payment? { get set }

    /// The partial payment order if any.
    var order: PartialPaymentOrder? { get set }
}

@_spi(AdyenInternal)
extension PaymentAwareComponent {

    public var payment: Payment? {
        get {
            objc_getAssociatedObject(self, &AssociatedKeys.payment) as? Payment
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.payment, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
        }
    }

    public var order: PartialPaymentOrder? {
        get {
            objc_getAssociatedObject(self, &AssociatedKeys.order) as? PartialPaymentOrder
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.order, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
        }
    }
}

private enum AssociatedKeys {

    internal static var payment = "paymentObject"

    internal static var order = "orderObject"
}
