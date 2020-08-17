//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A component provides payment method-specific UI and handling.
public protocol Component: AnyObject {
    
    /// Defines the environment used to make networking requests.
    var environment: Environment { get set }
    
    /// The client key that corresponds to the webservice user you will use for initiating the payment.
    /// See https://docs.adyen.com/user-management/client-side-authentication for more information.
    var clientKey: String? { get set }
    
}

public extension Component {
    
    /// :nodoc:
    var environment: Environment {
        get {
            guard let value = objc_getAssociatedObject(self, &AssociatedKeys.environment) as? Environment else {
                return Environment.live
            }
            return value
        }
        set {
            var newValue = newValue
            newValue.clientKey = clientKey
            objc_setAssociatedObject(self, &AssociatedKeys.environment, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// :nodoc:
    var clientKey: String? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.clientKey) as? String
        }
        set {
            environment.clientKey = newValue
            objc_setAssociatedObject(self, &AssociatedKeys.clientKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// :nodoc:
    var _isDropIn: Bool { // swiftlint:disable:this identifier_name
        get {
            guard let value = objc_getAssociatedObject(self, &AssociatedKeys.isDropIn) as? Bool else {
                return false
            }
            return value
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.isDropIn, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}

private struct AssociatedKeys {
    internal static var isDropIn = "isDropInObject"
    internal static var environment = "environmentObject"
    internal static var clientKey = "clientKeyObject"
}
