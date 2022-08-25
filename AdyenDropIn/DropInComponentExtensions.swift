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

/// :nodoc:
extension DropInComponent: PaymentMethodListComponentDelegate {
    
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

/// :nodoc:
extension DropInComponent: PaymentComponentDelegate {
    
    /// :nodoc:
    public func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent) {
        paymentInProgress = true
        delegate?.didSubmit(data, for: component.paymentMethod, from: self)
    }
    
    /// :nodoc:
    public func didFail(with error: Error, from component: PaymentComponent) {
        if case ComponentError.cancelled = error {
            userDidCancel(component)
        } else {
            delegate?.didFail(with: error, from: self)
        }
    }

}

/// :nodoc:
extension DropInComponent: ActionComponentDelegate {
    
    /// :nodoc:
    public func didOpenExternalApplication(_ component: ActionComponent) {
        stopLoading()
        delegate?.didOpenExternalApplication(self)
    }

    /// :nodoc:
    public func didComplete(from component: ActionComponent) {
        delegate?.didComplete(from: self)
    }
    
    /// :nodoc:
    public func didFail(with error: Error, from component: ActionComponent) {
        if case ComponentError.cancelled = error {
            userDidCancel(component)
        } else {
            delegate?.didFail(with: error, from: self)
        }
    }
    
    /// :nodoc:
    public func didProvide(_ data: ActionComponentData, from component: ActionComponent) {
        delegate?.didProvide(data, from: self)
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

extension DropInComponent: PresentationDelegate {

    /// :nodoc:
    public func present(component: PresentableComponent) {
        navigationController.present(asModal: component)
    }
}

extension DropInComponent: FinalizableComponent {

    public func didFinalize(with success: Bool, completion: (() -> Void)?) {
        stopLoading()
        if let component = selectedPaymentComponent {
            component.finalizeIfNeeded(with: success, completion: completion)
        } else {
            completion?()
        }
    }

    /// Stops loading and finalize DropIn's selected payment if necessary.
    /// This method must be called after certain payment methods (e.x. ApplePay)
    /// - Parameter success: Status of the payment.
    @available(*, deprecated, message: "Use didFinalize(with:, completion:) instead.")
    public func didFinalize(with success: Bool) {
        stopLoading()
        selectedPaymentComponent?.finalizeIfNeeded(with: success)
    }
}

extension DropInComponent: ReadyToSubmitPaymentComponentDelegate {

    /// :nodoc:
    public func showConfirmation(for component: InstantPaymentComponent, with order: PartialPaymentOrder?) {
        let newRoot = preselectedPaymentMethodComponent(for: component, onCancel: { [weak self] in
            guard let order = order else { return }
            self?.partialPaymentDelegate?.cancelOrder(order)
        })
        navigationController.present(root: newRoot)
        rootComponent = newRoot
    }
}
