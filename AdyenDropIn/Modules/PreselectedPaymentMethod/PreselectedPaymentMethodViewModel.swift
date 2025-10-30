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
    private weak var dropInComponent: DropInComponent?
    private weak var dropInComponentDelegate: DropInComponentDelegate?

    // MARK: - Initializers

    internal init(
        component: PaymentComponent,
        title: String,
        configuration: DropInComponent.Configuration,
        dropInComponent: DropInComponent,
        dropInComponentDelegate: DropInComponentDelegate?
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
        self.dropInComponent = dropInComponent
        self.dropInComponentDelegate = dropInComponentDelegate
    }

    // MARK: - PreselectedPaymentMethodViewModelProtocol

    internal var paymentMethodView: UIViewController {
        preselectedPaymentMethodComponent.viewController
    }

    internal func cancel() {
        guard let dropInComponent else { return }
        dropInComponentDelegate?.didCancel(component: component, from: dropInComponent)
        
        stopLoading()
        component.cancel()
        router?.dismissPresentedComponent()
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
            router?.presentComponent(component)
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
    
    internal func didSubmit(
        _ data: PaymentComponentData,
        from component: any PaymentComponent
    ) {
        guard let dropInComponent else { return }
        dropInComponentDelegate?.didSubmit(data, from: component, in: dropInComponent)
    }
    
    internal func didFail(
        with error: any Error,
        from component: any PaymentComponent
    ) {
        guard let dropInComponent else { return }
        
        if case ComponentError.cancelled = error {
            cancel()
        } else {
            dropInComponentDelegate?.didFail(with: error, from: component, in: dropInComponent)
        }
    }
}

// MARK: - LoadControllable

extension PreselectedPaymentMethodViewModel: LoadControllable {
    
    internal func stopLoading() {
        preselectedPaymentMethodComponent.stopLoading()
    }
}
