//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// A component that can send analytics events.
@_spi(AdyenInternal)
public protocol TrackableComponent: Component {
    
    /// Analytics flavor to determine the component / dropIn that initiates the events.
    var analyticsFlavor: AnalyticsFlavor { get }
    
    /// Sends the initial data and retrieves the checkout attempt id
    func sendInitialAnalytics()
    
    /// Sends the rendering event of the component
    func sendDidLoadEvent()
}

@_spi(AdyenInternal)
extension TrackableComponent where Self: ViewControllerDelegate {
    
    public func viewDidLoad(viewController: UIViewController) {
        sendInitialAnalytics()
        sendDidLoadEvent()
    }
}

// Generic extension to send events for all components and dropIn.
@_spi(AdyenInternal)
extension TrackableComponent {
    
    public func sendInitialAnalytics() {
        // initial call is not needed again if inside dropIn
        guard !_isDropIn else { return }
        let amount = context.payment?.amount
        let additionalFields = AdditionalAnalyticsFields(amount: amount, sessionId: AnalyticsForSession.sessionId)
        context.analyticsProvider?.sendInitialAnalytics(
            with: analyticsFlavor,
            additionalFields: additionalFields
        )
    }
}

@_spi(AdyenInternal)
extension TrackableComponent where Self: PaymentMethodAware {
    
    public var analyticsFlavor: AnalyticsFlavor {
        .components(type: paymentMethod.type)
    }
    
    public func sendDidLoadEvent() {
        var infoEvent = AnalyticsEventInfo(component: paymentMethod.type.rawValue, type: .rendered)
        infoEvent.isStoredPaymentMethod = (paymentMethod is StoredPaymentMethod) ? true : nil
        infoEvent.brand = (paymentMethod as? StoredCardPaymentMethod)?.brand.rawValue
        context.analyticsProvider?.add(info: infoEvent)
    }
}
