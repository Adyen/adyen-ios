//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

// sourcery:AutoMockable
@MainActor
internal protocol ComponentContainerViewModelProtocol {
    var componentViewController: UIViewController { get }
    func cancel()
}

@MainActor
internal class ComponentContainerViewModel: ComponentContainerViewModelProtocol {

    // MARK: - Properties

    internal weak var router: ComponentContainerRouting?
    private let component: PaymentComponent
    private let configuration: DropInConfiguration
    private var dropInFlowManager: DropInFlowManaging
    private weak var partialPaymentDelegate: PartialPaymentDelegate?

    // MARK: - Initializers

    internal init(
        component: PaymentComponent,
        configuration: DropInConfiguration,
        dropInFlowManager: DropInFlowManaging,
        partialPaymentDelegate: PartialPaymentDelegate?
    ) {
        self.component = component
        self.configuration = configuration
        self.dropInFlowManager = dropInFlowManager
        self.partialPaymentDelegate = partialPaymentDelegate
        setupComponent()
    }

    // MARK: - Public

    internal var componentViewController: UIViewController {
        component.viewController
    }

    internal func cancel() {
        dropInFlowManager.cancel(component: component)
        
        stopLoading()
        router?.dismiss(completion: nil)
    }

    // MARK: - Private

    private func setupComponent() {
        component.delegate = self
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
        dropInFlowManager.submit(data, from: component)
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

// MARK: - ReadyToSubmitPaymentComponentDelegate

extension ComponentContainerViewModel: ReadyToSubmitPaymentComponentDelegate {

    internal func showConfirmation(
        for component: PaymentComponent,
        with order: PartialPaymentOrder?
    ) {
        // TODO: - Handle gift card balance confirmation
        // 1. Present preselected payment method.
    }
}
