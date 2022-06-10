//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A component that handles an action to complete a payment.
public protocol ActionComponent: Component {
    
    /// The delegate of the action component.
    var delegate: ActionComponentDelegate? { get set }
    
}

/// Describes the methods a delegate of the action component needs to implement.
public protocol ActionComponentDelegate: AnyObject {
    
    /// Invoked when the action component opens a third party application outside the scope of the Adyen checkout,
    /// e.g WeChat Pay Application.
    /// In which case you can for example stop any loading animations.
    ///
    /// - parameter component: The component that handled the action.
    func didOpenExternalApplication(component: ActionComponent)
    
    /// Invoked when there is new data provided to initiate the payment details call.
    ///
    /// - Parameters:
    ///   - data: The data supplied by the action component.
    ///   - component: The component that handled the action.
    func didProvide(_ data: ActionComponentData, from component: ActionComponent)

    /// Invoked when the action component finishes,
    /// without any further steps needed by the application, for example in case of voucher payment methods.
    /// The application just needs to dismiss the presented component.
    ///
    /// - Parameters:
    ///   - component: The component that handled the action.
    func didComplete(from component: ActionComponent)
    
    /// Invoked when the action component fails.
    ///
    /// - Parameters:
    ///   - error: The error that occurred.
    ///   - component: The component that failed.
    func didFail(with error: Error, from component: ActionComponent)
    
}

/// provides a default empty implementation for ``didOpenExternalApplication(component:)``.
public extension ActionComponentDelegate {
    
    func didOpenExternalApplication(component: ActionComponent) {}
    
}
