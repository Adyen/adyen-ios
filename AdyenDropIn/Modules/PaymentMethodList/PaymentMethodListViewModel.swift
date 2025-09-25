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
        // TODO: - Handle non presentable component
        switch component {
        case let component as PresentableComponent:
            router?.didSelect(component)
        case let component as PaymentInitiable:
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
