//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

// sourcery:AutoMockable
@MainActor
internal protocol PaymentActionPresenting: Router, PaymentActionRouterListener {
    /// Presents the module of the action produced by the payment the presenter submitted.
    ///
    /// The action module is a child of the router that caused it, so a router can override
    /// this to present the action differently, or to insert screens in between.
    func present(paymentActionRouter: Router)
}

extension PaymentActionPresenting {

    internal func present(paymentActionRouter: Router) {
        childRouter = paymentActionRouter
        rootViewController.present(paymentActionRouter.rootViewController, animated: true)
    }

    internal func didDismissPaymentAction(completion: (() -> Void)?) {
        childRouter = nil
        completion?()
    }
}
