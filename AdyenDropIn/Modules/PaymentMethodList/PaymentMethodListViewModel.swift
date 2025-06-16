//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit
@_spi(AdyenInternal) import Adyen

@objc
internal protocol PaymentMethodListViewModelProtocol {
    var paymentMethodListView: UIViewController { get }
    func cancel()
}

internal class PaymentMethodListViewModel: PaymentMethodListViewModelProtocol, PaymentMethodListComponentDelegate {

    // MARK: - Properties

    private let router: PaymentMethodListRouterProtocol
    private let paymentMethodListComponent: PaymentMethodListComponent

    // MARK: - Initializers

    internal init(
        router: PaymentMethodListRouterProtocol,
        context: AdyenContext,
        componentManager: ComponentManager,
        configuration: DropInComponent.Configuration
    ) {
        self.router = router

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
        router.dismiss(completion: nil)
    }

    // MARK: - PaymentMethodListComponentDelegate

    internal func didLoad(
        _ paymentMethodListComponent: PaymentMethodListComponent
    ) {
        // TODO: - Handle analytcis
        router.didLoad()
    }

    internal func didSelect(
        _ component: any Adyen.PaymentComponent,
        in paymentMethodListComponent: PaymentMethodListComponent
    ) {
        // TODO: - Handle non presentable component
        switch component {
        case let component as PresentableComponent:
            router.present(component)
        case let component as PaymentInitiable:
            component.initiatePayment()
        default:
            break
        }
    }

    internal func didDelete(
        _ paymentMethod: any Adyen.StoredPaymentMethod,
        in paymentMethodListComponent: PaymentMethodListComponent,
        completion: @escaping Adyen.Completion<Bool>
    ) {
        // TODO: - Logic to delete stored payment method
        router.delete(storedPaymentMethod: paymentMethod, completion: completion)
    }

    // MARK: - Private
}
