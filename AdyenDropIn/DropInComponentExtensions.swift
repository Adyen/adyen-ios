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

extension DropInComponent: NavigationDelegate {

    internal func dismiss(completion: (() -> Void)? = nil) {
        viewController.dismiss(animated: true, completion: completion)
    }

    @_spi(AdyenInternal)
    public func present(component: PresentableComponent) {
        viewController.present(component.viewController, animated: true)
    }

}

extension DropInComponent: FinalizableComponent {

    public func didFinalize(with success: Bool, completion: (() -> Void)?) {
        stopLoading()
        if let finalizableComponent = selectedPaymentComponent as? FinalizableComponent {
            finalizableComponent.didFinalize(with: success, completion: completion)
        } else {
            completion?()
        }
    }
}

extension DropInComponent: ReadyToSubmitPaymentComponentDelegate {

    package func showConfirmation(for component: InstantPaymentComponent, with order: PartialPaymentOrder?) {
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
