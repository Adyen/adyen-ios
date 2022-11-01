//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Any Object that is aware of a `PaymentMethod`.
public protocol PaymentMethodAware {

    /// The payment method for which to gather payment details.
    var paymentMethod: PaymentMethod { get }
    
}

/// A component that handles the initial phase of getting payment details to initiate a payment.
public protocol PaymentComponent: Component, PartialPaymentOrderAware, PaymentMethodAware {
    
    /// The delegate of the payment component.
    var delegate: PaymentComponentDelegate? { get set }
    
}

@_spi(AdyenInternal)
extension PaymentComponent {
    
    /// Submits payment data to the payment delegate.
    /// - Parameters:
    ///   - data: The Payment data to be submitted
    ///   - component: The component from which the payment originates.
    public func submit(data: PaymentComponentData, component: PaymentComponent? = nil) {
        let component = component ?? self
        /// try to fetch the fetchCheckoutAttemptId to get cached if its not already cached
        component.context.analyticsProvider.fetchAndCacheCheckoutAttemptIdIfNeeded()
        
        let updatedData = data.replacing(checkoutAttemptId: component.context.analyticsProvider.checkoutAttemptId)

        guard updatedData.browserInfo == nil else {
            delegate?.didSubmit(updatedData, from: component)
            return
        }
        updatedData.dataByAddingBrowserInfo { [weak self] in
            self?.delegate?.didSubmit($0, from: component)
        }
        
    }

}

extension AdyenContextAware where Self: PaymentAware {

    public var payment: Payment? {
        context.payment
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
