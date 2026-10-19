//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenComponents)
    import AdyenComponents
#endif
#if canImport(AdyenActions)
    import AdyenActions
#endif
#if canImport(AdyenCard)
    import AdyenCard
#endif
import AdyenNetworking
import UIKit

extension DropInComponent: ReadyToSubmitPaymentComponentDelegate {

    package func showConfirmation(for component: PaymentComponent, with order: PartialPaymentOrder?) {
//        let newRootViewController = resolvePreselectedPaymentMethodView(
//            for: component,
//            onCancel: { [weak self] in
//                guard let self,
//                      let order else { return }
//                self.partialPaymentDelegate?.cancelOrder(order, component: self)
//            }
//        )
//        navigationController.present(newRootViewController, animated: true)
//        rootViewController = newRootViewController
    }
}

extension DropInComponent: TrackableComponent {
    package var analyticsFlavor: AnalyticsFlavor {
        let paymentMethodTypes = paymentMethods.regular.map(\.type.rawValue)
        return .dropIn(paymentMethods: paymentMethodTypes)
    }

    package func sendDidLoadEvent() {
        var infoEvent = AnalyticsEventInfo(component: "dropin", type: .rendered)
        infoEvent.configData = DropInAnalyticsConfiguration(configuration: configuration)
        context.analyticsProvider?.add(info: infoEvent)
    }
}
