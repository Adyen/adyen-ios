//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Any Object that is aware of a `PaymentMethod`.
public protocol PaymentMethodAware: AnyObject {
    /// The payment method for which to gather payment details.
    var paymentMethod: PaymentMethod { get }
}

/// A component that handles the initial phase of getting payment details to initiate a payment.
public protocol PaymentComponent: PaymentAwareComponent, PaymentMethodAware {

    /// The context object for this component.
    @_spi(AdyenInternal)
    var context: AdyenContext { get }
    
    /// The delegate of the payment component.
    var delegate: PaymentComponentDelegate? { get set }
    
}

@_spi(AdyenInternal)
extension PaymentComponent {
    
    public func submit(data: PaymentComponentData, component: PaymentComponent? = nil) {
        let component = component ?? self
        let checkoutAttemptId = component.context.analyticsProvider.checkoutAttemptId
        var updatedData: PaymentComponentData

        if data.checkoutAttemptId == checkoutAttemptId {
            updatedData = data
        } else {
            updatedData = PaymentComponentData(paymentMethodDetails: data.paymentMethod,
                                               amount: data.amount,
                                               order: data.order,
                                               storePaymentMethod: data.storePaymentMethod,
                                               browserInfo: data.browserInfo,
                                               checkoutAttemptId: checkoutAttemptId,
                                               installments: data.installments)

        }

        guard updatedData.browserInfo == nil else {
            delegate?.didSubmit(updatedData, from: component)
            return
        }
        updatedData.dataByAddingBrowserInfo { [weak self] in
            guard let self = self else { return }
            self.delegate?.didSubmit($0, from: component)
        }
    }
}

/// Describes the methods a delegate of the payment component needs to implement.
public protocol PaymentComponentDelegate: AnyObject {
    
    /// Invoked when the shopper submits the data needed for the payments call.
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

    public var amountToPay: Amount? {
        order?.remainingAmount ?? payment?.amount
    }
}

private enum AssociatedKeys {

    internal static var payment = "paymentObject"

    internal static var order = "orderObject"
}
