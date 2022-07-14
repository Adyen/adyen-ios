//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Any component with a partial payment property.
public protocol PartialPaymentOrderAware {

    /// The partial payment order if any.
    var order: PartialPaymentOrder? { get set }

}

/// Any component with a payment property.
public protocol PaymentAware {

    /// The payment information.
    var payment: Payment? { get }

}

@_spi(AdyenInternal)
extension PartialPaymentOrderAware {

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
