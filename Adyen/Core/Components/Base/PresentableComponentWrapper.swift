//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// A component that wraps any `Component` to make it a `PresentableComponent`.
@_spi(AdyenInternal)
public final class PresentableComponentWrapper: PresentableComponent,
    Cancellable,
    FinalizableComponent,
    LoadingComponent {
    
    public var apiContext: APIContext { component.context.apiContext }

    /// The context object for this component.
    public var context: AdyenContext { component.context }
    
    public let viewController: UIViewController
    
    /// The wrapped component.
    public let component: Component
    
    public let requiresModalPresentation: Bool = true
    
    @_spi(AdyenInternal)
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

    public func didCancel() {
        component.cancelIfNeeded()
        stopLoading()
    }

    public func didFinalize(with success: Bool, completion: (() -> Void)?) {
        component.finalizeIfNeeded(with: success, completion: completion)
    }

    public func stopLoading() {
        component.stopLoadingIfNeeded()
    }
}
