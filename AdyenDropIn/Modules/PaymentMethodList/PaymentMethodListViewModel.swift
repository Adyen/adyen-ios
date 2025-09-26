//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit
@_spi(AdyenInternal) import Adyen

internal protocol RoutablePaymentMethodListViewModel {
    func stopComponentLoading()
}

@objc
internal protocol PaymentMethodListViewModelProtocol {
    var paymentMethodListView: UIViewController { get }
    func cancel()
}

internal class PaymentMethodListViewModel: PaymentMethodListViewModelProtocol {

    // MARK: - Properties

    internal weak var router: PaymentMethodListRouterProtocol?
    private let paymentMethodListComponent: PaymentMethodListComponent

    // MARK: - Initializers

    internal init(
        context: AdyenContext,
        componentManager: ComponentManager,
        configuration: DropInComponent.Configuration
    ) {
        let components = componentManager.sections
        self.paymentMethodListComponent = PaymentMethodListComponent(
            context: context,
            components: components,
            style: configuration.style.listComponent
        )
        self.paymentMethodListComponent.localizationParameters = configuration.localizationParameters
        self.paymentMethodListComponent.delegate = self
    }

    // MARK: - PaymentMethodListViewModelProtocol

    internal var paymentMethodListView: UIViewController {
        paymentMethodListComponent.viewController
    }

    internal func cancel() {
        // TODO: - Handle cancellation
        router?.didCancel(completion: nil)
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
        // TODO: - Handle analytics
    }

    internal func didSelect(
        _ component: any PaymentComponent,
        in paymentMethodListComponent: PaymentMethodListComponent
    ) {
        startLoading(for: component)
        
        switch component {
        case let component as PresentableComponent:
            router?.didSelect(component)
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
        let checkoutAttemptId = component.context.analyticsProvider?.checkoutAttemptId
        let updatedData = data.replacing(
            checkoutAttemptId: checkoutAttemptId
        )

        guard updatedData.browserInfo == nil else {
            router?.didSubmit(updatedData, from: component)
            return
        }
        updatedData.dataByAddingBrowserInfo { [weak self] in
            guard let self else { return }
            router?.didSubmit($0, from: component)
        }
    }
    
    internal func didFail(
        with error: any Error,
        from component: any PaymentComponent
    ) {
        defer { stopLoading() }
        
        if case ComponentError.cancelled = error {
            cancel()
        } else {
            router?.didFail(with: error, from: component)
        }
    }
}

// MARK: - RoutableViewModel

extension PaymentMethodListViewModel: RoutablePaymentMethodListViewModel {
    
    func stopComponentLoading() {
        stopLoading()
    }
}
