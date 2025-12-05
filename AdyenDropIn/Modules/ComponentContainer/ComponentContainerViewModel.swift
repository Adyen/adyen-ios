//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
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
    private let configuration: DropInComponent.Configuration
    private var dropInFlowManager: DropInFlowManaging
    private weak var partialPaymentDelegate: PartialPaymentDelegate?
    private let onCancel: (() -> Void)?

    // MARK: - Initializers

    internal init(
        component: PresentableComponent,
        configuration: DropInComponent.Configuration,
        dropInFlowManager: DropInFlowManaging,
        partialPaymentDelegate: PartialPaymentDelegate?,
        onCancel: (() -> Void)? = nil
    ) {
        self.component = component
        self.configuration = configuration
        self.dropInFlowManager = dropInFlowManager
        self.partialPaymentDelegate = partialPaymentDelegate
        self.onCancel = onCancel
        setupComponent()
    }

    // MARK: - Public

    internal var componentViewController: UIViewController {
        component.viewController
    }

    internal func cancel() {
        if let component = (component as? PaymentComponent) {
            dropInFlowManager.cancel(component: component)
        }
        
        stopLoading()
        onCancel?()
        router?.dismiss(completion: nil)
    }

    // MARK: - Private

    private func setupComponent() {
        (component as? PaymentComponent)?.delegate = self
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
        dropInFlowManager.submit(data, from: component, actionPresenter: self)
    }
    
    internal func didFail(
        with error: any Error,
        from component: any PaymentComponent
    ) {
        if case ComponentError.cancelled = error {
            cancel()
        } else {
            dropInFlowManager.fail(with: error, from: component)
        }
    }
}

// MARK: - ActionPresenter

extension ComponentContainerViewModel: ActionPresenter {

    internal func present(actionComponent: any PresentableComponent) {
        router?.present(actionComponent: actionComponent) { [weak self] in
            self?.stopLoading()
        }
    }

    internal func didCancel(actionComponent: any ActionComponent) {
        stopLoading()
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
