//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

#if canImport(AdyenActions)
    import AdyenActions
#endif
import Adyen
import Foundation

/// Defines the methods a delegate of the drop in component should implement.
public protocol DropInComponentDelegate: PaymentComponentDelegate, ActionComponentDelegate {
    
    /// Invoked when the drop in component failed with an error.
    ///
    /// - Parameters:
    ///   - error: The error that occurred.
    ///   - component: The drop in component that failed.
    func didFail(with error: Error, from dropInComponent: DropInComponent)
    
    /// Invoked when user closes a payment component.
    ///
    /// - Parameters:
    ///   - component: The component that the user closed.
    ///   - dropInComponent: The drop in component that owns the `component`.
    func didCancel(component: PaymentComponent, from dropInComponent: DropInComponent)
    
}

/// Describes the methods a delegate of stored payment methods needs to implement.
public protocol StoredPaymentMethodsDelegate: AnyObject {

    /// Invoked when shopper wants to delete a stored payment method.
    ///
    /// - Parameters:
    ///   - storedPaymentMethod: The stored payment method that the user wants to disable.
    ///   - completion: The delegate need to call back this closure when the disabling is done,
    ///    with a boolean parameter that indicates success or failure.
    func disable(storedPaymentMethod: StoredPaymentMethod, completion: @escaping Completion<Bool>)
    
}

/// :nodoc:
public extension DropInComponentDelegate {
    
    /// :nodoc:
    func didCancel(component: PaymentComponent, from dropInComponent: DropInComponent) {}

    /// :nodoc:
    func didOpenExternalApplication(_ component: ActionComponent) {}
}
