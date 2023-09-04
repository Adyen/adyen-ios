//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// :nodoc:
protocol BACSDirectDebitComponentTrackerProtocol: AnyObject {
    func sendEvent()
}

/// :nodoc:
class BACSDirectDebitComponentTracker: BACSDirectDebitComponentTrackerProtocol {

    // MARK: - Properties

    private let paymentMethod: BACSDirectDebitPaymentMethod
    private let apiContext: APIContext
    private let isDropIn: Bool

    // MARK: - Initializers

    init(paymentMethod: BACSDirectDebitPaymentMethod,
         apiContext: APIContext,
         isDropIn: Bool) {
        self.paymentMethod = paymentMethod
        self.apiContext = apiContext
        self.isDropIn = isDropIn
    }

    // MARK: - BACSDirectDebitComponentTrackerProtocol

    func sendEvent() {
        Analytics.sendEvent(component: paymentMethod.type,
                            flavor: isDropIn ? .dropin : .components,
                            context: apiContext)
    }

}
