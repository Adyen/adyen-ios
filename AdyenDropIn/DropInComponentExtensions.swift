//
// Copyright (c) 2022 Adyen N.V.
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
extension DropInComponent: PaymentMethodListComponentDelegate {

    internal func didLoad(_ paymentMethodListComponent: PaymentMethodListComponent) {
        let paymentMethodTypes = paymentMethods.regular.map(\.type.rawValue)
        context.analyticsProvider.sendTelemetryEvent(flavor: .dropIn(paymentMethods: paymentMethodTypes))
    }
    
    internal func didSelect(_ component: PaymentComponent,
                            in paymentMethodListComponent: PaymentMethodListComponent) {
        (rootComponent as? ComponentLoader)?.startLoading(for: component)
        didSelect(component)
    }
    
    internal func didDelete(_ paymentMethod: StoredPaymentMethod,
                            in paymentMethodListComponent: PaymentMethodListComponent,
                            completion: @escaping (Bool) -> Void) {
        let deletionCompletion = { [weak self] (success: Bool) in
            defer {
                completion(success)
            }
            guard success else { return }
            self?.paymentMethods.stored.removeAll(where: { $0 == paymentMethod })
            self?.reloadComponentManager()
        }
        storedPaymentMethodsDelegate?.disable(storedPaymentMethod: paymentMethod, completion: deletionCompletion)
    }
}

@_spi(AdyenInternal)
extension DropInComponent: PaymentComponentDelegate {
    
    public func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent) {
        paymentInProgress = true
        /// try to fetch the fetchCheckoutAttemptId to get cached if its not already cached
        component.context.analyticsProvider.fetchAndCacheCheckoutAttemptIdIfNeeded()
        
        let updatedData = data.replacing(checkoutAttemptId: component.context.analyticsProvider.checkoutAttemptId)

        guard updatedData.browserInfo == nil else {
            self.delegate?.didSubmit(updatedData, from: component, in: self)
            return
        }
        updatedData.dataByAddingBrowserInfo { [weak self] in
            guard let self = self else { return }
            self.delegate?.didSubmit($0, from: component, in: self)
        }
        
    }
    
    public func didFail(with error: Error, from component: PaymentComponent) {
        if case ComponentError.cancelled = error {
            userDidCancel(component)
        } else {
            delegate?.didFail(with: error, from: self)
        }
    }

}

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

extension DropInComponent: PreselectedPaymentMethodComponentDelegate {

    internal func didProceed(with component: PaymentComponent) {
        (rootComponent as? ComponentLoader)?.startLoading(for: component)
        didSelect(component)
    }
    
    internal func didRequestAllPaymentMethods() {
        showPaymentMethodsList(onCancel: nil)
    }

    internal func showPaymentMethodsList(onCancel: (() -> Void)?) {
        let newList = paymentMethodListComponent(onCancel: onCancel)
        navigationController.present(root: newList)
        rootComponent = newList
    }
}

extension DropInComponent: NavigationDelegate {

    internal func dismiss(completion: (() -> Void)? = nil) {
        navigationController.dismiss(animated: true, completion: completion)
    }

    @_spi(AdyenInternal)
    public func present(component: PresentableComponent) {
        navigationController.present(asModal: component)
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
        let newRoot = preselectedPaymentMethodComponent(for: component, onCancel: { [weak self] in
            guard let self = self, let order = order else { return }
            self.partialPaymentDelegate?.cancelOrder(order, component: self)
        })
        navigationController.present(root: newRoot)
        rootComponent = newRoot
    }
}
