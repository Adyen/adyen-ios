//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Any DropIn Component.
public protocol AnyDropInComponent: PresentableComponent {
    
    /// The delegate of the DropIn component.
    var delegate: DropInComponentDelegate? { get set }
    
    /// Reloads the DropIn with a partial payment order and a new `PaymentMethods` object.
    ///
    /// - Parameter order: The partial payment order.
    /// - Parameter paymentMethods: The new payment methods.
    /// - Throws: `PartialPaymentError.missingOrderData` in case `order.orderData` is `nil`.
    func reload(with order: PartialPaymentOrder,
                _ paymentMethods: PaymentMethods) throws
}
