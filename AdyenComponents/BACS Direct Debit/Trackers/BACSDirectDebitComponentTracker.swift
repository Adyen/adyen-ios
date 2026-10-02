//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

package protocol BACSDirectDebitComponentTrackerProtocol: AnyObject {
    func sendInitialAnalytics()
    func sendDidLoadEvent()
}

package class BACSDirectDebitComponentTracker: BACSDirectDebitComponentTrackerProtocol {

    // MARK: - Properties

    private let paymentMethod: BACSDirectDebitPaymentMethod
    private let context: AdyenContext
    private let isDropIn: () -> Bool

    // MARK: - Initializers

    package init(
        paymentMethod: BACSDirectDebitPaymentMethod,
        context: AdyenContext,
        isDropIn: @escaping () -> Bool
    ) {
        self.paymentMethod = paymentMethod
        self.context = context
        self.isDropIn = isDropIn
    }

    // MARK: - BACSDirectDebitComponentTrackerProtocol

    package func sendInitialAnalytics() {
        // initial call is not needed again if inside dropIn
        guard !isDropIn() else { return }
        let flavor: AnalyticsFlavor = .components(type: paymentMethod.type)
        let amount = context.amount
        let additionalFields = AdditionalAnalyticsFields(amount: amount, sessionId: AnalyticsForSession.sessionId)
        context.analyticsProvider?.sendInitialAnalytics(
            with: flavor,
            additionalFields: additionalFields
        )
    }
    
    package func sendDidLoadEvent() {
        let infoEvent = AnalyticsEventInfo(component: paymentMethod.type.rawValue, type: .rendered)
        context.analyticsProvider?.add(info: infoEvent)
    }

}
