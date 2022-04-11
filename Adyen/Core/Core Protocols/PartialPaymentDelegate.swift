//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes the methods a delegate of the partial payment component needs to implement.
public protocol PartialPaymentDelegate: AnyObject {

    /// Invoked when the payment component needs a balance check call to be done by the merchant.
    ///
    /// - Parameters:
    ///   - component: The current component.
    ///   - data: The data supplied by the payment component.
    ///   - completion: The completion closure called when the balance is checked.
    func checkBalance(with data: PaymentComponentData,
                      component: Component,
                      completion: @escaping (Result<Balance, Error>) -> Void)

    /// Invoked when the payment component needs a partial payment order object.
    ///
    /// - Parameters:
    ///   - component: The current component.
    ///   - completion: The completion closure called when the order object.
    func requestOrder(for component: Component,
                      completion: @escaping (Result<PartialPaymentOrder, Error>) -> Void)

    /// Invoked when the payment component needs to cancel the order.
    ///
    /// - Parameters:
    ///   - order: The order object.
    ///   - component: The current component.
    func cancelOrder(_ order: PartialPaymentOrder, component: Component)

}
