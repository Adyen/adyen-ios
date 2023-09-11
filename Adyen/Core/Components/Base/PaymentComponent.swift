//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// :nodoc:
public protocol PaymentMethodAware: AnyObject {
    /// The payment method for which to gather payment details.
    var paymentMethod: PaymentMethod { get }
}

/// A component that handles the initial phase of getting payment details to initiate a payment.
public protocol PaymentComponent: PaymentAwareComponent, PaymentMethodAware {
    
    /// The delegate of the payment component.
    var delegate: PaymentComponentDelegate? { get set }
    
}

/// :nodoc:
extension PaymentComponent {
    
    /// :nodoc:
    public func submit(data: PaymentComponentData, component: PaymentComponent? = nil) {
        guard data.browserInfo == nil else {
            delegate?.didSubmit(data, from: component ?? self)
            return
        }
        data.dataByAddingBrowserInfo { [weak self] in
            guard let self else { return }
            self.delegate?.didSubmit($0, from: component ?? self)
        }
    }
}

/// Describes the methods a delegate of the payment component needs to implement.
public protocol PaymentComponentDelegate: AnyObject {
    
    /// Invoked when the payment component finishes, typically by a user submitting their payment details.
    ///
    /// - Parameters:
    ///   - data: The data supplied by the payment component.
    ///   - component: The payment component from which the payment details were submitted.
    func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent)
    
    /// Invoked when the payment component fails.
    ///
    /// - Parameters:
    ///   - error: The error that occurred.
    ///   - component: The payment component that failed.
    func didFail(with error: Error, from component: PaymentComponent)
    
}

/// Any component with a payment property.
public protocol PaymentAwareComponent: Component {

    /// The payment information.
    var payment: Payment? { get set }

    /// The partial payment order if any.
    var order: PartialPaymentOrder? { get set }
}

/// :nodoc:
extension PaymentAwareComponent {
    /// :nodoc:
    public var payment: Payment? {
        get {
            objc_getAssociatedObject(self, &AssociatedKeys.payment) as? Payment
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.payment, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
        }
    }

    /// :nodoc:
    public var order: PartialPaymentOrder? {
        get {
            objc_getAssociatedObject(self, &AssociatedKeys.order) as? PartialPaymentOrder
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.order, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
        }
    }

    /// :nodoc:
    @available(*, deprecated, message: "This property will no longer be available.")
    public var amountToPay: Amount? {
        order?.remainingAmount ?? payment?.amount
    }
}

private enum AssociatedKeys {

    internal static var payment = "paymentObject"

    internal static var order = "orderObject"
}
