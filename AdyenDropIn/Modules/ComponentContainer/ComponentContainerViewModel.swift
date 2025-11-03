//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
#if canImport(AdyenCard)
    import AdyenCard
#endif
import Foundation
import UIKit

internal protocol ComponentContainerViewModelProtocol {
    var componentViewController: UIViewController { get }
    func cancel()
}

internal class ComponentContainerViewModel: ComponentContainerViewModelProtocol {

    // MARK: - Properties

    internal weak var router: ComponentContainerRouting?
    private let component: PresentableComponent
    private let context: AdyenContext
    private let configuration: DropInComponent.Configuration
    private weak var dropInComponent: DropInComponent?
    private weak var dropInComponentDelegate: DropInComponentDelegate?
    private weak var cardComponentDelegate: CardComponentDelegate?
    private weak var partialPaymentDelegate: PartialPaymentDelegate?
    private let onCancel: (() -> Void)?

    // MARK: - Initializers

    internal init(
        component: PresentableComponent,
        context: AdyenContext,
        configuration: DropInComponent.Configuration,
        dropInComponent: DropInComponent,
        dropInComponentDelegate: DropInComponentDelegate?,
        cardComponentDelegate: CardComponentDelegate?,
        partialPaymentDelegate: PartialPaymentDelegate?,
        onCancel: (() -> Void)? = nil
    ) {
        self.component = component
        self.context = context
        self.configuration = configuration
        self.dropInComponent = dropInComponent
        self.dropInComponentDelegate = dropInComponentDelegate
        self.cardComponentDelegate = cardComponentDelegate
        self.partialPaymentDelegate = partialPaymentDelegate
        self.onCancel = onCancel

        setupComponent()
    }

    // MARK: - Public

    internal var componentViewController: UIViewController {
        component.viewController
    }

    internal func cancel() {
        guard let dropInComponent else { return }

        if let component = (component as? PaymentComponent) {
            dropInComponentDelegate?.didCancel(component: component, from: dropInComponent)
        }
        
        stopLoading()
        onCancel?()
        router?.dismiss(completion: nil)
    }

    // MARK: - Private

    private func setupComponent() {
        (component as? PaymentComponent)?.delegate = self
        (component as? CardComponent)?.cardComponentDelegate = cardComponentDelegate
        (component as? PartialPaymentComponent)?.partialPaymentDelegate = partialPaymentDelegate
        (component as? PartialPaymentComponent)?.readyToSubmitComponentDelegate = self
    }
        
    private func stopLoading() {
        component.stopLoading()
    }
}

// MARK: - PaymentComponentDelegate

extension ComponentContainerViewModel: PaymentComponentDelegate {

    internal func didSubmit(
        _ data: PaymentComponentData,
        from component: any PaymentComponent
    ) {
        guard let dropInComponent else { return }
        
        let checkoutAttemptId = component.context.analyticsProvider?.checkoutAttemptId
        let updatedData = data.replacing(
            checkoutAttemptId: checkoutAttemptId
        )

        guard updatedData.browserInfo == nil else {
            dropInComponentDelegate?.didSubmit(updatedData, from: component, in: dropInComponent)
            return
        }
        updatedData.dataByAddingBrowserInfo { [weak self] newData in
            guard let self else { return }
            dropInComponentDelegate?.didSubmit(newData, from: component, in: dropInComponent)
        }
    }
    
    internal func didFail(
        with error: any Error,
        from component: any PaymentComponent
    ) {
        guard let dropInComponent else { return }
        
        if case ComponentError.cancelled = error {
            cancel()
        } else {
            dropInComponentDelegate?.didFail(with: error, from: component, in: dropInComponent)
        }
    }
}

// MARK: - PresentationDelegate

extension ComponentContainerViewModel: PresentationDelegate {

    internal func present(component: any PresentableComponent) {
        router?.present(component: component)
    }
}

// MARK: - ReadyToSubmitPaymentComponentDelegate

extension ComponentContainerViewModel: ReadyToSubmitPaymentComponentDelegate {

    internal func showConfirmation(
        for component: InstantPaymentComponent,
        with order: PartialPaymentOrder?
    ) {
        // TODO: - Handle gift card balance confirmation
        // 1. Present preselected payment method.
    }
}
