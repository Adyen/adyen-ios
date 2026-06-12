//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// A component that wraps any `Component` together with its action view controller.
@MainActor
package final class ActionViewWrapper:
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

    /// Initializes the wrapper component.
    ///
    /// - Parameter component: The wrapped component.
    /// - Parameter viewController: The `ViewController` used as the UI of the wrapped action.
    package init(
        component: Component,
        viewController: UIViewController
    ) {
        self.component = component
        self.viewController = viewController
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
