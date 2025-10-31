//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit
@_spi(AdyenInternal) import Adyen

internal protocol PaymentMethodListViewModelProtocol {
    var paymentMethodListView: UIViewController { get }
    func cancel()
}

internal class PaymentMethodListViewModel: PaymentMethodListViewModelProtocol {

    // MARK: - Properties

    internal weak var router: PaymentMethodListRouting?
    private let paymentMethodListComponent: PaymentMethodListComponent
    private weak var dropInComponent: DropInComponent?
    private weak var dropInComponentDelegate: DropInComponentDelegate?

    // MARK: - Initializers

    internal init(
        context: AdyenContext,
        componentManager: ComponentManager,
        configuration: DropInComponent.Configuration,
        dropInComponent: DropInComponent,
        dropInComponentDelegate: DropInComponentDelegate?
    ) {
        let components = componentManager.sections
        self.paymentMethodListComponent = PaymentMethodListComponent(
            context: context,
            components: components,
            style: configuration.style.listComponent
        )
        self.paymentMethodListComponent.localizationParameters = configuration.localizationParameters
        self.paymentMethodListComponent.delegate = self
        self.dropInComponent = dropInComponent
        self.dropInComponentDelegate = dropInComponentDelegate
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
        paymentMethodListComponent.cancel()
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
        
        switch component {
        case let component as PresentableComponent:
            router?.present(component) { [weak self] in
                self?.stopLoading()
            }
        case let component as PaymentInitiable:
            (component as? PaymentComponent)?.delegate = self
            component.initiatePayment()
        default:
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
        guard let dropInComponent else { return }
        
        let checkoutAttemptId = component.context.analyticsProvider?.checkoutAttemptId
        let updatedData = data.replacing(
            checkoutAttemptId: checkoutAttemptId
        )

        guard updatedData.browserInfo == nil else {
            dropInComponentDelegate?.didSubmit(data, from: component, in: dropInComponent)
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
        defer { stopLoading() }
        
        guard let dropInComponent else { return }

        if case ComponentError.cancelled = error {
            cancel()
        } else {
            dropInComponentDelegate?.didFail(with: error, from: component, in: dropInComponent)
        }
    }
}
