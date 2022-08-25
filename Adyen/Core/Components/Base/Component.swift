//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A component provides payment method-specific UI and handling.
public protocol Component: APIContextAware {}

/// :nodoc:
extension Component {

    /// Finalizes the payment if there is any, after being processed by payment provider.
    /// - Parameter success: The status of the payment.
    @available(*, deprecated, message: "Use finalizeIfNeeded(with:, completion:) instead.")
    public func finalizeIfNeeded(with success: Bool) {
        (self as? FinalizableComponent)?.didFinalize(with: success, completion: nil)
    }

    public func finalizeIfNeeded(with success: Bool, completion: (() -> Void)?) {
        stopLoadingIfNeeded()
        if let finalizable = self as? FinalizableComponent {
            finalizable.didFinalize(with: success, completion: completion)
        } else {
            completion?()
        }
    }

    /// Called when the user cancels the component.
    public func cancelIfNeeded() {
        (self as? Cancellable)?.didCancel()
        stopLoadingIfNeeded()
    }

    /// Stops any processing animation that might be running.
    public func stopLoadingIfNeeded() {
        (self as? LoadingComponent)?.stopLoading()
    }
}

/// A component that needs to be aware of the result of the payment.
public protocol FinalizableComponent: Component {

    /// Finalizes payment after being processed by payment provider.
    /// - Parameter success: The status of the payment.
    @available(*, deprecated, message: "Use finalizeIfNeeded(with:, completion:) instead.")
    func didFinalize(with success: Bool)

    /// Finalizes payment after being processed by payment provider.
    /// - Parameter success: The status of the payment.
    /// - Parameter completion: The block to execute after the component finalizes its activity.
    /// Use of this block is recommended for ApplePayComponent. You may specify nil for this parameter.
    func didFinalize(with success: Bool, completion: (() -> Void)?)
}

public extension Component {
    
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

private enum AssociatedKeys {
    internal static var isDropIn = "isDropInObject"

    internal static var environment = "environmentObject"

    internal static var clientKey = "clientKeyObject"
}
