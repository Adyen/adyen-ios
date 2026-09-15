//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenCheckout
import UIKit
import XCTest

@MainActor
final class CheckoutDropInPublicAPITests: XCTestCase {

    func test_publicDropInCreationAndPresentationAPI_compiles() {
        func createDropIn(from checkout: PaymentCheckout) throws -> CheckoutDropInComponent {
            try checkout.createDropIn()
        }

        func viewController(from component: CheckoutDropInComponent) -> UIViewController {
            component.viewController
        }

        _ = createDropIn
        _ = viewController
    }
}
