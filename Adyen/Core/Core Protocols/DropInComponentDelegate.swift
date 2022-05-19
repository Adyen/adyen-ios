//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Defines the methods a delegate of the drop in component should implement.
public protocol DropInComponentDelegate: AnyObject {
    
    /// Invoked when a payment method is selected and the initial details have been filled.
    ///
    /// - Parameters:
    ///   - data: The data supplied by the drop in component, containing the filled payment method details.
    ///   - component: The payment component in which the payment method was selected and filled.
    ///   - dropInComponent: The DropIn component.
    func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent, in dropInComponent: AnyDropInComponent)
    
    /// Invoked when a payment component fails.
    ///
    /// - Parameters:
    ///   - error: The error that occurred.
    ///   - component: The payment component that failed.
    ///   - dropInComponent: The DropIn component.
    func didFail(with error: Error, from component: PaymentComponent, in dropInComponent: AnyDropInComponent)
    
    /// Invoked when there is new data provided that is required for the payment details call.
    ///
    /// - Parameters:
    ///   - data: The additional data supplied by the drop in component.
    ///   - component: The action component from which the additional details were provided.
    ///   - dropInComponent: The DropIn component.
    func didProvide(_ data: ActionComponentData, from component: ActionComponent, in dropInComponent: AnyDropInComponent)
    
    /// Invoked when the action component finishes,
    /// without any further steps needed by the application, for example in case of voucher payment methods.
    /// The application just needs to dismiss the `DropInComponent`.
    ///
    /// - Parameters:
    ///   - component: The action component that handled the action.
    ///   - dropInComponent: The DropIn component.
    func didComplete(from component: ActionComponent, in dropInComponent: AnyDropInComponent)
    
    /// Invoked when the action component fails.
    ///
    /// - Parameters:
    ///   - error: The error that occurred.
    ///   - component: The action component that failed.
    ///   - dropInComponent: The DropIn component.
    func didFail(with error: Error, from component: ActionComponent, in dropInComponent: AnyDropInComponent)
    
    /// Invoked when the action component opens a third party application outside the scope of the Adyen checkout,
    /// e.g WeChat Pay Application.
    /// In which case you can for example stop any loading animations.
    ///
    /// - parameter component: The action component that handled the action.
    /// - parameter dropInComponent: The DropIn component.
    func didOpenExternalApplication(component: ActionComponent, in dropInComponent: AnyDropInComponent)
    
    /// Invoked when the drop in component failed with an error.
    ///
    /// - Parameters:
    ///   - error: The error that occurred.
    ///   - component: The drop in component that failed.
    func didFail(with error: Error, from dropInComponent: AnyDropInComponent)
    
    /// Invoked when user closes a payment component.
    ///
    /// - Parameters:
    ///   - component: The component that the user closed.
    ///   - dropInComponent: The drop in component that owns the `component`.
    func didCancel(component: PaymentComponent, from dropInComponent: AnyDropInComponent)
    
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

/// Provides default empty implementations for some of the `DropInComponentDelegate` functions.
public extension DropInComponentDelegate {
    
    func didCancel(component: PaymentComponent, from dropInComponent: AnyDropInComponent) {}

    func didOpenExternalApplication(component: ActionComponent, in dropInComponent: AnyDropInComponent) {}
}
