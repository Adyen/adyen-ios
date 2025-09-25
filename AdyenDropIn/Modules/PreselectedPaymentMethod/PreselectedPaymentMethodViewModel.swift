//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit
@_spi(AdyenInternal) import Adyen

@objc
internal protocol PreselectedPaymentMethodViewModelProtocol {
    var paymentMethodView: UIViewController { get }
    func cancel()
}

internal class PreselectedPaymentMethodViewModel: PreselectedPaymentMethodViewModelProtocol, PreselectedPaymentMethodComponentDelegate {

    // MARK: - Properties

    internal weak var router: PreselectedPaymentMethodRouterProtocol?
    private let component: PaymentComponent
    private let preselectedPaymentMethodComponent: PreselectedPaymentMethodComponent

    // MARK: - Initializers

    internal init(
        component: PaymentComponent,
        title: String,
        configuration: DropInComponent.Configuration
    ) {
        let style = configuration.style
        self.component = component
        self.preselectedPaymentMethodComponent = PreselectedPaymentMethodComponent(
            component: component,
            title: title,
            style: style.formComponent,
            listItemStyle: style.listComponent.listItem
        )
        self.preselectedPaymentMethodComponent.localizationParameters = configuration.localizationParameters
        self.preselectedPaymentMethodComponent.delegate = self
    }

    // MARK: - PreselectedPaymentMethodViewModelProtocol

    internal var paymentMethodView: UIViewController {
        preselectedPaymentMethodComponent.viewController
    }

    internal func cancel() {
        stopLoading()
        router?.dismiss(completion: nil)
    }

    // MARK: - PreselectedPaymentMethodComponentDelegate

    internal func didRequestAllPaymentMethods() {
        router?.showAllPaymentMethods()
    }

    internal func didProceed(with component: any PaymentComponent) {
        startLoading()
        startPaymentFlow(for: component)
    }

    // MARK: - Private

    private func startPaymentFlow(for component: PaymentComponent) {
        // TODO: - Handle payment delegation
//        setNecessaryDelegates(on: component)

        switch component {
        case let component as PresentableComponent:
            router?.proceed(with: component)
        case let component as PaymentInitiable:
            component.initiatePayment()
        default:
            break
        }
    }

    private func startLoading() {
        preselectedPaymentMethodComponent.startLoading(for: component)
    }

    private func stopLoading() {
        preselectedPaymentMethodComponent.stopLoadingIfNeeded()
    }
}
