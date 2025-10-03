//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit
@_spi(AdyenInternal) import Adyen

internal protocol PreselectedPaymentMethodViewModelProtocol {
    var paymentMethodView: UIViewController { get }
    func cancel()
}

internal class PreselectedPaymentMethodViewModel: PreselectedPaymentMethodViewModelProtocol, PreselectedPaymentMethodComponentDelegate {

    // MARK: - Properties

    internal weak var router: PreselectedPaymentMethodRouting?
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
        router?.cancel(component: component)
    }

    // MARK: - PreselectedPaymentMethodComponentDelegate

    internal func didRequestAllPaymentMethods() {
        router?.presentPaymentMethodList()
    }

    internal func didProceed(with component: any PaymentComponent) {
        startPaymentFlow(for: component)
    }

    // MARK: - Private

    private func startPaymentFlow(for component: PaymentComponent) {
        startLoading()
        
        switch component {
        case let component as PresentableComponent:
            router?.proceed(with: component)
        case let component as PaymentInitiable:
            (component as? PaymentComponent)?.delegate = self
            component.initiatePayment()
        default:
            break
        }
    }

    private func startLoading() {
        preselectedPaymentMethodComponent.startLoading(for: component)
    }
}

// MARK: - PaymentComponentDelegate

extension PreselectedPaymentMethodViewModel: PaymentComponentDelegate {
    
    func didSubmit(
        _ data: PaymentComponentData,
        from component: any PaymentComponent
    ) {
        router?.submit(data, from: component)
    }
    
    func didFail(
        with error: any Error,
        from component: any PaymentComponent
    ) {
        if case ComponentError.cancelled = error {
            cancel()
        } else {
            router?.fail(with: error, from: component)
        }
    }
}

// MARK: - LoadControllable

extension PreselectedPaymentMethodViewModel: LoadControllable {
    
    internal func stopLoading() {
        preselectedPaymentMethodComponent.stopLoading()
    }
}
