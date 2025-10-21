//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
#if canImport(AdyenComponents)
    import AdyenComponents
#endif
#if canImport(AdyenActions)
    @_spi(AdyenInternal) import AdyenActions
#endif
#if canImport(AdyenCard)
    @_spi(AdyenInternal) import AdyenCard
#endif
import AdyenNetworking
import UIKit

@_spi(AdyenInternal)
extension DropInComponent: ActionComponentDelegate {

    public func didOpenExternalApplication(component: ActionComponent) {
        stopLoading()
        delegate?.didOpenExternalApplication(component: component, in: self)
    }

    public func didComplete(from component: ActionComponent) {
        delegate?.didComplete(from: component, in: self)
    }

    public func didFail(with error: Error, from component: ActionComponent) {
        if case ComponentError.cancelled = error {
            userDidCancel(component)
        } else {
            delegate?.didFail(with: error, from: component, in: self)
        }
    }

    public func didProvide(_ data: ActionComponentData, from component: ActionComponent) {
        delegate?.didProvide(data, from: component, in: self)
    }

}

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

    @_spi(AdyenInternal)
    public func showConfirmation(for component: InstantPaymentComponent, with order: PartialPaymentOrder?) {
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

@_spi(AdyenInternal)
extension DropInComponent: TrackableComponent {
    public var analyticsFlavor: AnalyticsFlavor {
        let paymentMethodTypes = paymentMethods.regular.map(\.type.rawValue)
        return .dropIn(paymentMethods: paymentMethodTypes)
    }

    public func sendDidLoadEvent() {
        var infoEvent = AnalyticsEventInfo(component: "dropin", type: .rendered)
        infoEvent.configData = DropInAnalyticsConfiguration(configuration: configuration)
        context.analyticsProvider?.add(info: infoEvent)
    }
}
