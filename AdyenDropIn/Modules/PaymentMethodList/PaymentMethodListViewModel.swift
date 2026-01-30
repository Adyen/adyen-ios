//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit
@_spi(AdyenInternal) import Adyen

// sourcery:AutoMockable
internal protocol PaymentMethodListViewModelProtocol {
    var paymentMethodListView: UIViewController { get }
    func cancel()
}

internal class PaymentMethodListViewModel: PaymentMethodListViewModelProtocol {

    // MARK: - Properties

    internal weak var router: PaymentMethodListRouting?
    internal let paymentMethodListComponent: PaymentMethodListComponent
    private var dropInFlowManager: DropInFlowManaging

    // MARK: - Initializers

    internal init(
        context: AdyenContext,
        componentManager: ComponentManager,
        configuration: DropInComponent.Configuration,
        dropInFlowManager: DropInFlowManaging
    ) {
        let components = componentManager.sections
        self.paymentMethodListComponent = PaymentMethodListComponent(
            context: context,
            components: components,
            style: configuration.style.listComponent
        )
        self.dropInFlowManager = dropInFlowManager
        self.paymentMethodListComponent.localizationParameters = configuration.localizationParameters
        self.paymentMethodListComponent.delegate = self
    }

    // MARK: - PaymentMethodListViewModelProtocol

    internal var paymentMethodListView: UIViewController {
        paymentMethodListComponent.viewController
    }

    internal func cancel() {
        router?.dismiss(completion: nil)
    }

    // MARK: - Private
    
    private func startLoading(for component: any PaymentComponent) {
        paymentMethodListComponent.startLoading(for: component)
    }
    
    private func stopLoading() {
        paymentMethodListComponent.stopLoading()
    }
}

extension PaymentMethodListViewModel: PaymentMethodListComponentDelegate {

    // MARK: - PaymentMethodListComponentDelegate

    internal func didLoad(
        _ paymentMethodListComponent: PaymentMethodListComponent
    ) {
        // TODO: - Handle analytics on list load.
    }

    internal func didSelect(
        _ component: any PaymentComponent,
        in paymentMethodListComponent: PaymentMethodListComponent
    ) {
        startLoading(for: component)
        
        switch component.type {
        case let .presentable(presentableComponent):
            router?.present(paymentComponent: presentableComponent) { [weak self] in
                self?.stopLoading()
            }
        case let .instant(initiablePaymentComponent):
            initiablePaymentComponent.delegate = self
            initiablePaymentComponent.initiatePayment()
        case .none:
            break
        }
    }

    internal func didDelete(
        _ paymentMethod: any StoredPaymentMethod,
        in paymentMethodListComponent: PaymentMethodListComponent,
        completion: @escaping Adyen.Completion<Bool>
    ) {
        // TODO: - Logic to delete stored payment method
    }
}

// MARK: - PaymentComponentDelegate

extension PaymentMethodListViewModel: PaymentComponentDelegate {
    
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
        defer { stopLoading() }

        if case ComponentError.cancelled = error {
            cancel()
        } else {
            dropInFlowManager.fail(with: error, from: component)
        }
    }
}

// MARK: - ActionPresenter

extension PaymentMethodListViewModel: ActionPresenter {

    internal func present(actionComponent: any PresentableComponent) {
        router?.present(actionComponent: actionComponent) { [weak self] in
            self?.stopLoading()
        }
    }

    internal func didCancel(actionComponent: any ActionComponent) {
        stopLoading()
    }
}
