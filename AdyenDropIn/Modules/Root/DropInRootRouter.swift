//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

internal protocol DropInRootRouterProtocol {
    func presentPreselectedPaymentMethod(
        component: PaymentComponent,
        title: String,
        configuration: DropInComponent.Configuration
    )
    func presentPaymentMethodList(
        componentManager: ComponentManager,
        context: AdyenContext,
        configuration: DropInComponent.Configuration
    )
}

internal class DropInRootRouter: DropInRootRouterProtocol {

    // MARK: - Properties

    internal weak var view: UIViewController?

    // MARK: - Initializers

    // MARK: - DropInRootRouterProtocol

    internal func presentPreselectedPaymentMethod(
        component: PaymentComponent,
        title: String,
        configuration: DropInComponent.Configuration
    ) {
        let preselectedPaymentMethodView = resolvePreselectedPaymentMethod(
            component: component,
            title: title,
            configuration: configuration
        )
        view?.present(preselectedPaymentMethodView, animated: true)
    }

    internal func presentPaymentMethodList(
        componentManager: ComponentManager,
        context: AdyenContext,
        configuration: DropInComponent.Configuration
    ) {
        let paymentMethodListView = resolvePaymentMethodList(
            componentManager: componentManager,
            context: context,
            configuration: configuration
        )
        view?.present(paymentMethodListView, animated: true)
    }

    // MARK: - Private

    private func resolvePreselectedPaymentMethod(
        component: PaymentComponent,
        title: String,
        configuration: DropInComponent.Configuration
    ) -> UIViewController {
        let assembler = PreselectedPaymentMethodAssembler()
        let view = assembler.resolvePreselectedPaymentMethodView(
            router: self,
            component: component,
            title: title,
            configuration: configuration
        )
        return view
    }

    private func resolvePaymentMethodList(
        componentManager: ComponentManager,
        context: AdyenContext,
        configuration: DropInComponent.Configuration
    ) -> UIViewController {
        let assembler = PaymentMethodListAssembler(
            componentManager: componentManager,
            context: context
        )
        let view = assembler.resolvePaymentMethodListView(router: self, configuration: configuration)
        return view
    }
}

// MARK: - PreselectedPaymentMethodRouterProtocol

extension DropInRootRouter: PreselectedPaymentMethodRouterProtocol {

    func showAllPaymentMethods() {
        // TODO: -
    }
    
    func proceed(with component: any Adyen.PaymentComponent) {
        // TODO: -
    }
}

extension DropInRootRouter: PaymentMethodListRouterProtocol {

    func didLoad() {
        // TODO: -
    }
    
    func present(_ component: any Adyen.PaymentComponent) {
        // TODO: -
    }
    
    func delete(storedPaymentMethod: any Adyen.StoredPaymentMethod, completion: @escaping (Bool) -> Void) {
        // TODO: -
    }

}
