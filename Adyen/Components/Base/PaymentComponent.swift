//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A component that handles the initial phase of getting payment details to initiate a payment.
public protocol PaymentComponent: Component {
    
    /// The payment method for which to gather payment details.
    var paymentMethod: PaymentMethod { get }
    
    /// The delegate of the payment component.
    var delegate: PaymentComponentDelegate? { get set }
    
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
