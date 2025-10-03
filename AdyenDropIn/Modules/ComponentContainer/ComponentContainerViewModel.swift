//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
#if canImport(AdyenCard)
    import AdyenCard
#endif
import Foundation
import UIKit

internal protocol RoutableComponentContainerViewModel {
    func stopLoading()
}

internal protocol ComponentContainerViewModelProtocol {
    var componentViewController: UIViewController { get }
    func cancel()
}

internal class ComponentContainerViewModel: ComponentContainerViewModelProtocol {

    // MARK: - Properties

    internal weak var router: ComponentContainerRouting?
    private let component: PresentableComponent
    private let context: AdyenContext
    private let configuration: DropInComponent.Configuration
    private weak var cardComponentDelegate: CardComponentDelegate?
    private weak var partialPaymentDelegate: PartialPaymentDelegate?

    // MARK: - Initializers

    internal init(
        component: PresentableComponent,
        context: AdyenContext,
        configuration: DropInComponent.Configuration,
        cardComponentDelegate: CardComponentDelegate?,
        partialPaymentDelegate: PartialPaymentDelegate?
    ) {
        self.component = component
        self.context = context
        self.configuration = configuration
        self.cardComponentDelegate = cardComponentDelegate
        self.partialPaymentDelegate = partialPaymentDelegate

        setupComponent()
    }

    // MARK: - Public

    internal var componentViewController: UIViewController {
        component.viewController
    }

    internal func cancel() {
        component.cancel()

        if let component = (component as? PaymentComponent) {
            router?.cancel(component: component)
        }
        
        stopLoading()
    }

    // MARK: - Private

    private func setupComponent() {
        (component as? PaymentComponent)?.delegate = self
        (component as? CardComponent)?.cardComponentDelegate = cardComponentDelegate
        (component as? PartialPaymentComponent)?.partialPaymentDelegate = partialPaymentDelegate
        (component as? PartialPaymentComponent)?.readyToSubmitComponentDelegate = self
    }
}

// MARK: - RoutableComponentContainerViewModel

extension ComponentContainerViewModel: RoutableComponentContainerViewModel {
    
    func stopLoading() {
        component.stopLoading()
    }
}

// MARK: - PaymentComponentDelegate

extension ComponentContainerViewModel: PaymentComponentDelegate {

    func didSubmit(
        _ data: PaymentComponentData,
        from component: any PaymentComponent
    ) {
        let checkoutAttemptId = component.context.analyticsProvider?.checkoutAttemptId
        let updatedData = data.replacing(
            checkoutAttemptId: checkoutAttemptId
        )

        guard updatedData.browserInfo == nil else {
            router?.submit(updatedData, from: component)
            return
        }
        updatedData.dataByAddingBrowserInfo { [weak self] in
            guard let self else { return }
            router?.submit($0, from: component)
        }
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

// MARK: - PresentationDelegate

extension ComponentContainerViewModel: PresentationDelegate {

    func present(component: any PresentableComponent) {
        router?.present(component.viewController, animated: true)
    }
}

// MARK: - ReadyToSubmitPaymentComponentDelegate

extension ComponentContainerViewModel: ReadyToSubmitPaymentComponentDelegate {

    func showConfirmation(
        for component: InstantPaymentComponent,
        with order: PartialPaymentOrder?
    ) {
        // TODO: - Handle gift card balance confirmation
        // 1. Present preselected payment method.
    }
}
