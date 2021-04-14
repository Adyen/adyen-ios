//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes the methods a delegate of the payment component needs to implement.
public protocol PartialPaymentDelegate: AnyObject {

    /// Invoked when the payment component needs a balance check call to be done by the merchant.
    ///
    /// - Parameters:
    ///   - data: The data supplied by the payment component.
    ///   - component: The payment component from which the payment details were submitted.
    ///   - completion: The completion closure called when the balance is checked.
    func checkBalance(_ data: PaymentComponentData,
                      from component: PaymentComponent,
                      completion: @escaping (Result<Balance, Error>) -> Void)

    /// Invoked when the payment component needs a partial payment order object.
    ///
    /// - Parameters:
    ///   - data: The data supplied by the payment component.
    ///   - component: The payment component from which the payment details were submitted.
    ///   - completion: The completion closure called when the order object.
    func requestOrder(_ data: PaymentComponentData,
                      from component: PaymentComponent,
                      completion: @escaping (Result<PartialPaymentOrder, Error>) -> Void)

    /// Invoked when the payment component needs to cancel the order.
    ///
    /// - Parameters:
    ///   - order: The order object.
    func cancelOrder(_ order: PartialPaymentOrder,
                     from component: PaymentComponent,
                     completion: @escaping (Error?) -> Void)

}
