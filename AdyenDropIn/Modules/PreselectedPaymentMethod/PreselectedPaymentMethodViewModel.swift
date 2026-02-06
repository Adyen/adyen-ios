//
// Copyright (c) Adyen N.V.
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
    private var dropInFlowManager: DropInFlowManaging

    // MARK: - Initializers

    internal init(
        component: PaymentComponent,
        title: String,
        configuration: DropInComponent.Configuration,
        dropInFlowManager: DropInFlowManaging
    ) {
        let style = configuration.style
        self.component = component
        self.dropInFlowManager = dropInFlowManager
        self.preselectedPaymentMethodComponent = PreselectedPaymentMethodComponent(
            component: component,
            title: title,
            style: style.formComponent,
            listItemStyle: style.listComponent.listItem
        )
        // TODO: - Localization parameters need to be moved to configuration level.
        self.preselectedPaymentMethodComponent.localizationParameters = configuration.localizationParameters
        self.preselectedPaymentMethodComponent.delegate = self
    }

    // MARK: - PreselectedPaymentMethodViewModelProtocol

    internal var paymentMethodView: UIViewController {
        preselectedPaymentMethodComponent.viewController
    }

    internal func cancel() {
        dropInFlowManager.cancel(component: component)

        stopLoading()
        router?.dismiss(completion: nil)
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
        startLoading(for: component)

        switch component.type {
        case .regular, .stored:
            router?.present(component: component) { [weak self] in
                self?.stopLoading()
            }
        case let .initiable(initiablePaymentComponent):
            initiablePaymentComponent.initiatePayment(delegate: self)
        case .undefined:
            break
        }
    }
    
    private func startLoading(for component: PaymentComponent) {
        preselectedPaymentMethodComponent.startLoading(for: component)
    }
    
    private func stopLoading() {
        preselectedPaymentMethodComponent.stopLoading()
    }
}

// MARK: - PaymentComponentDelegate

extension PreselectedPaymentMethodViewModel: PaymentComponentDelegate {
    
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
        if case ComponentError.cancelled = error {
            cancel()
        } else {
            dropInFlowManager.fail(with: error, from: component)
        }
    }
}

// MARK: - ActionPresenter

extension PreselectedPaymentMethodViewModel: ActionPresenter {

    internal func present(actionComponent: any PresentableComponent) {
        router?.present(actionComponent: actionComponent) { [weak self] in
            self?.stopLoading()
        }
    }

    internal func didCancel(actionComponent: any ActionComponent) {
        stopLoading()
    }
}
