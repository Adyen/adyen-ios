//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// A component that handles an action to complete a payment.
public protocol ActionComponent: Component {
    
    /// The delegate of the action component.
    var delegate: ActionComponentDelegate? { get set }
    
}

/// Represents any structure/class that can be initialized without any parameters.
/// :nodoc:
public protocol APIContextInitializable {
    /// Initializer that takes an `APIContext`.
    init(apiContext: APIContext)
}

/// Describes the expected interface from any ActionComponent that handles WeChat Pay sdk action.
/// :nodoc:
public protocol AnyWeChatPaySDKActionComponent: ActionComponent, DeviceDependent, APIContextInitializable {
    
    /// Handles the action.
    ///
    /// - Parameter action: The WeChat Pay action.
    func handle(_ action: WeChatPaySDKAction)
    
}

/// Loads the concrete WeChatPaySDKActionComponent Class dynamically.
/// :nodoc:
public func loadTheConcreteWeChatPaySDKActionComponentClass() -> AnyWeChatPaySDKActionComponent.Type? {
    ["AdyenWeChatPay.WeChatPaySDKActionComponent",
     "Adyen.WeChatPaySDKActionComponent"].compactMap { NSClassFromString($0) as? AnyWeChatPaySDKActionComponent.Type }.first
}

/// Describes the methods a delegate of the action component needs to implement.
public protocol ActionComponentDelegate: AnyObject {
    
    /// Invoked when the action component opens a third party application outside the scope of the Adyen checkout,
    /// e.g WeChat Pay Application.
    /// In which case you can for example stop any loading animations.
    ///
    /// - parameter component: The component that handled the action.
    func didOpenExternalApplication(_ component: ActionComponent)
    
    /// Invoked when the action component finishes.
    /// and provides the delegate with the data that was retrieved.
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

/// :nodoc:
public extension ActionComponentDelegate {
    
    /// :nodoc:
    func didOpenExternalApplication(_ component: ActionComponent) {}
    
}
