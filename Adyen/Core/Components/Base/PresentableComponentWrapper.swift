//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// A component that wraps any `Component` to make it a `PresentableComponent`.
@MainActor
package final class PresentableComponentWrapper: PresentableComponent,
    Cancellable,
    FinalizableComponent,
    LoadingComponent {
    
    package var apiContext: APIContext {
        component.context.apiContext
    }

    /// The context object for this component.
    package var context: AdyenContext {
        component.context
    }

    package let viewController: UIViewController

    /// The wrapped component.
    package let component: Component

    package var navBarType: NavigationBarType

    /// Initializes the wrapper component.
    ///
    /// - Parameter component: The wrapped component.
    /// - Parameter viewController: The `ViewController` used as the UI of the `PresentableComponent`.
    /// - Parameter navBarType: Type of the navigation bar to use.
    package init(
        component: Component,
        viewController: UIViewController,
        navBarType: NavigationBarType = .regular
    ) {
        self.component = component
        self.viewController = viewController
        self.navBarType = navBarType
    }

    package func didCancel() {
        component.cancel()
        stopLoading()
    }

    package func didFinalize(with success: Bool, completion: (() -> Void)?) {
        component.finalizeIfNeeded(with: success, completion: completion)
    }

    package func stopLoading() {
        component.stopLoading()
    }
}
