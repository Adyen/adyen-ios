//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

// sourcery:AutoMockable
@MainActor
internal protocol PaymentActionPresenting: PaymentActionRouterListener {
    /// Presents the module of the action produced by the submitted payment.
    func present(paymentActionRouter: Router)
}
