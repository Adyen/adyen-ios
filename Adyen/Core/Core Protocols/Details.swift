//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Contains details supplied by a component. These details are used to initiate or complete a payment.
public protocol Details: OpaqueEncodable {}

/// Contains the payment details entered by the user to complete payment with chosen payment method.
public protocol PaymentMethodDetails: Details {
    
    @_spi(AdyenInternal)
    var checkoutAttemptId: String? { get set }
}

public extension PaymentMethodDetails {

    @_spi(AdyenInternal)
    var checkoutAttemptId: String? {
        get {
            guard let value = objc_getAssociatedObject(self, &AssociatedKeys.checkoutAttemptId) as? String else {
                return "do-not-track"
            }
            return value
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.checkoutAttemptId, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

private enum AssociatedKeys {
    internal static var checkoutAttemptId = "checkoutAttemptId"
}

/// Contains additional details that were retrieved to complete a payment.
public protocol AdditionalDetails: Details {}
