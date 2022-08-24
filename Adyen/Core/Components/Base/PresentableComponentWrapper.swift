//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// A component that wraps any `Component` to make it a `PresentableComponent`.
/// :nodoc:
public final class PresentableComponentWrapper: PresentableComponent,
    Cancellable,
    FinalizableComponent,
    LoadingComponent {
    
    /// :nodoc:
    public var apiContext: APIContext { component.apiContext }
    
    /// :nodoc:
    public let viewController: UIViewController
    
    /// The wrapped component.
    public let component: Component
    
    /// :nodoc:
    public var requiresModalPresentation: Bool = true
    
    /// :nodoc:
    public var navBarType: NavigationBarType
    
    /// Initializes the wrapper component.
    ///
    /// - Parameter component: The wrapped component.
    /// - Parameter viewController: The `ViewController` used as the UI of the `PresentableComponent`.
    /// - Parameter navBarType: Type of the navigation bar to use.
    public init(
        component: Component,
        viewController: UIViewController,
        navBarType: NavigationBarType = .regular
    ) {
        self.component = component
        self.viewController = viewController
        self.navBarType = navBarType
    }
    
    /// :nodoc:
    public func didCancel() {
        component.cancelIfNeeded()
        stopLoading()
    }

    /// :nodoc:
    public func didFinalize(with success: Bool) {
        component.finalizeIfNeeded(with: success, completion: nil)
    }

    /// :nodoc:
    public func didFinalize(with success: Bool, completion: (() -> Void)?) {
        stopLoading()
        component.finalizeIfNeeded(with: success, completion: completion)
    }

    /// :nodoc:
    public func stopLoading() {
        component.stopLoadingIfNeeded()
    }
}
