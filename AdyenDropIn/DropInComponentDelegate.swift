//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

#if canImport(AdyenActions)
    import AdyenActions
#endif
import Adyen
import Foundation

/// Defines the methods a delegate of the drop in component should implement.
public protocol DropInComponentDelegate: AnyObject {
    
    /// Invoked when a payment method is selected and the initial details have been filled.
    ///
    /// - Parameters:
    ///   - data: The data supplied by the drop in component, containing the filled payment method details.
    ///   - paymentMethod: The paymen method of selected paymen component.
    ///   - component: The drop in component in which the payment method was selected and filled.
    func didSubmit(_ data: PaymentComponentData, for paymentMethod: PaymentMethod, from component: DropInComponent)
    
    /// Invoked when additional details have been provided for a payment method.
    ///
    /// - Parameters:
    ///   - data: The additional data supplied by the drop in component.
    ///   - component: The drop in component from which the additional details were provided.
    func didProvide(_ data: ActionComponentData, from component: DropInComponent)

    /// Invoked when the action component finishes,
    /// without any further steps needed by the application, for example in case of voucher payment methods.
    /// The application just needs to dismiss the `DropInComponent`.
    ///
    /// - Parameters:
    ///   - component: The component that handled the action.
    func didComplete(from component: DropInComponent)
    
    /// Invoked when the drop in component failed with an error.
    ///
    /// - Parameters:
    ///   - error: The error that occurred.
    ///   - component: The drop in component that failed.
    func didFail(with error: Error, from component: DropInComponent)
    
    /// Invoked when user closes a payment component.
    ///
    /// - Parameters:
    ///   - component: The component that the user closed.
    ///   - dropInComponent: The drop in component that owns the `component`.
    func didCancel(component: PaymentComponent, from dropInComponent: DropInComponent)
    
}

/// :nodoc:
public extension DropInComponentDelegate {
    
    /// :nodoc:
    func didCancel(component: PaymentComponent, from dropInComponent: DropInComponent) {}
}
