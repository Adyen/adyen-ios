//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A component that wraps any `Component` to make it a `PresentableComponent`.
internal final class PresentableComponentWrapper: PresentableComponent {
    
    /// :nodoc:
    internal let viewController: UIViewController
    
    /// The wrapped component.
    internal let component: Component
    
    /// Initializes the wrapper component.
    ///
    /// - Parameter component: The wrapped component.
    /// - Parameter viewController: The `ViewController` used as the UI of the `PresentableComponent`.
    internal init(component: Component, viewController: UIViewController) {
        self.component = component
        self.viewController = viewController
    }
    
    /// :nodoc:
    internal func didCancel() {
        guard let component = component as? Cancellable else { return }
        component.didCancel()
    }
}
