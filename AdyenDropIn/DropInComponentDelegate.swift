//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Defines the methods a delegate of the drop in component should implement.
public protocol DropInComponentDelegate: AnyObject {
    
    /// Invoked when a payment method is selected and the initial details have been filled.
    ///
    /// - Parameters:
    ///   - data: The data supplied by the drop in component, containing the selected payment method and the filled details.
    ///   - component: The drop in component in which the payment method was selected and filled.
    func didSubmit(_ data: PaymentComponentData, from component: DropInComponent)
    
    /// Invoked when additional details have been provided for a payment method.
    ///
    /// - Parameters:
    ///   - data: The additional data supplied by the drop in component..
    ///   - component: The drop in component from which the additional details were provided.
    func didProvide(_ data: ActionComponentData, from component: DropInComponent)
    
    /// Invoked when the drop in component failed with an error.
    ///
    /// - Parameters:
    ///   - error: The error that occurred.
    ///   - component: The drop in component that failed.
    func didFail(with error: Error, from component: DropInComponent)
    
}
