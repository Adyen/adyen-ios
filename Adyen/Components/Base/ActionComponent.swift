//
// Copyright (c) 2019 Adyen B.V.
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
    
    /// Invoked when the action component finishes
    /// and provides the delegate with the data that was retrieved.
    ///
    /// - Parameters:
    ///   - data: The data supplied by the action component.
    ///   - component: The component that handled the action.
    func didProvide(_ data: ActionComponentData, from component: ActionComponent)
    
    /// Invoked when the action component fails.
    ///
    /// - Parameters:
    ///   - error: The error that occurred.
    ///   - component: The component that failed.
    func didFail(with error: Error, from component: ActionComponent)
    
}
