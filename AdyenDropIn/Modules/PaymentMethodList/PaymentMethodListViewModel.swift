//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit
@_spi(AdyenInternal) import Adyen

// sourcery:AutoMockable
internal protocol PaymentMethodListViewModelProtocol {
    var context: AdyenContext { get }
    var localizationParameters: LocalizationParameters? { get }
    var componentSections: [ComponentsSection] { get }
    func cancel()

    func didLoad()
    func select(_ component: PaymentComponent)
    func delete(_ storePaymentMethod: StoredPaymentMethod, completion: @escaping Completion<Bool>)
}

internal class PaymentMethodListViewModel: PaymentMethodListViewModelProtocol {

    // MARK: - Properties

    internal let context: AdyenContext
    internal let localizationParameters: LocalizationParameters?
    internal let componentManager: ComponentManager
    internal weak var router: PaymentMethodListRouting?
    private var dropInFlowManager: DropInFlowManaging

    // MARK: - Initializers

    internal init(
        context: AdyenContext,
        localizationParameters: LocalizationParameters? = nil,
        componentManager: ComponentManager,
        configuration: DropInComponent.Configuration,
        dropInFlowManager: DropInFlowManaging
    ) {
        self.context = context
        self.localizationParameters = localizationParameters
        self.componentManager = componentManager
        self.dropInFlowManager = dropInFlowManager
    }

    // MARK: - PaymentMethodListViewModelProtocol

    internal var componentSections: [ComponentsSection] {
        componentManager.sections
    }

    internal func cancel() {
        router?.dismiss(completion: nil)
    }

    internal func didLoad() {
        // TODO: - Handle analytics on list load.
    }

    internal func select(_ component: PaymentComponent) {
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

    internal func delete(_ storedPaymentMethod: StoredPaymentMethod, completion: @escaping Adyen.Completion<Bool>) {
        // TODO: - Logic to delete stored payment method
    }

    // MARK: - Private

    // TODO: - Handle loading
    private func startLoading(for component: any PaymentComponent) {
//        paymentMethodListComponent.startLoading(for: component)
    }
    
    private func stopLoading() {
//        paymentMethodListComponent.stopLoading()
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
