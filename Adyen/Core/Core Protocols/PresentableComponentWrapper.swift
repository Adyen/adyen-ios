//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// :nodoc:
/// A component that wraps any `Component` to make it a `PresentableComponent`.
public final class PresentableComponentWrapper: PresentableComponent, Cancellable {
    
    /// :nodoc:
    public let viewController: UIViewController
    
    /// The wrapped component.
    public let component: Component
    
    /// :nodoc:
    public var requiresModalPresentation: Bool = true
    
    /// Initializes the wrapper component.
    ///
    /// - Parameter component: The wrapped component.
    /// - Parameter viewController: The `ViewController` used as the UI of the `PresentableComponent`.
    public init(component: Component, viewController: UIViewController) {
        self.component = component
        self.viewController = viewController
    }
    
    /// :nodoc:
    public func didCancel() {
        guard let component = component as? Cancellable else { return }
        component.didCancel()
    }
}
