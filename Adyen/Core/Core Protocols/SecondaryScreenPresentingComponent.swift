//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// A component whose form opens secondary screens, like the installments, country and phone prefix pickers or the address lookup.
///
/// Whoever routes the component decides how those screens appear, through ``presenter``:
/// - A standalone component routes itself and presents them modally, as it does not know where the merchant shows it.
/// - Drop-in's router calls `presenter.route(through:)` to push them onto Drop-in's navigation stack.
@MainActor
package protocol SecondaryScreenPresentingComponent: PaymentComponent {

    /// Shows the screens this component opens. Give it to the form items.
    ///
    /// Read-only and the same object for the component's whole life,
    /// so a presenter routed later, like Drop-in's router, is always used.
    var presenter: RoutablePresenter { get }
}
