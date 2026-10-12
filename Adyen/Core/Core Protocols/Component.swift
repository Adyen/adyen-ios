//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A component provides payment method-specific UI and handling.
public protocol Component: AdyenContextAware {}

/// Provides convenience functions to `Component` instances.
extension Component {

    /// Stops loading, then lets a `FinalizableComponent` show the payment result.
    /// Returns once the component's UI is gone.
    /// - Parameter success: Whether the payment succeeded.
    @MainActor
    package func finalizeIfNeeded(success: Bool) async {
        stopLoading()
        if let finalizable = self as? FinalizableComponent {
            await finalizable.finalize(success: success)
        }
    }

    /// Called when the user cancels the component.
    public func cancel() {
        (self as? Cancellable)?.didCancel()
        stopLoading()
    }

    /// Stops any processing animation that might be running.
    public func stopLoading() {
        (self as? LoadingComponent)?.stopLoading()
    }
}

/// A component that shows the payment result in its own UI before the payment ends.
package protocol FinalizableComponent: Component {

    /// Shows the payment result and returns once the component's UI is gone.
    /// - Parameter success: Whether the payment succeeded.
    @MainActor
    func finalize(success: Bool) async
}

package extension Component {

    package var _isDropIn: Bool { // swiftlint:disable:this identifier_name
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
    internal static var isDropIn: Void?

    internal static var environment: Void?

    internal static var clientKey: Void?
}
