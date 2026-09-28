//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

#if canImport(AdyenDropIn)
    import AdyenDropIn
#endif
import UIKit

/// A component that presents the complete Drop-in payment flow.
///
/// Create instances using ``PaymentCheckout/createDropIn()``. Retain both the checkout flow and
/// this component while its view controller is presented.
///
/// ```swift
/// let dropIn = try checkout.createDropIn()
/// present(dropIn.viewController, animated: true)
/// ```
@MainActor
public final class CheckoutDropInComponent {

    internal let dropInComponent: DropInComponent

    /// The view controller that presents Drop-in.
    public var viewController: UIViewController {
        dropInComponent.viewController
    }

    package init(dropInComponent: DropInComponent) {
        self.dropInComponent = dropInComponent
    }
}
