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
#if canImport(AdyenActions)
    @_spi(AdyenInternal) import AdyenActions
#endif

internal protocol ComponentContainerViewModelDelegate: AnyObject {
    // MARK: - PaymentComponentDelegate

    func didSubmit(
        _ data: PaymentComponentData,
        from component: PaymentComponent
    )
    func didFail(with error: Error)
    func didCancel(component: PaymentComponent)
    
    // MARK: - ActionComponentDelegate

    func didOpenExternalApplication(component: ActionComponent)
    func didProvide(
        _ data: ActionComponentData,
        from component: ActionComponent
    )
    func didComplete(from component: ActionComponent)
    func didFail(with error: Error, from component: ActionComponent)
}

internal protocol ComponentContainerViewModelProtocol {
    var componentViewController: UIViewController { get }
    func cancel()
}

internal class ComponentContainerViewModel: ComponentContainerViewModelProtocol {

    // MARK: - Properties

    internal weak var delegate: ComponentContainerViewModelDelegate?
    private let component: PresentableComponent
    private let context: AdyenContext
    private let configuration: DropInComponent.Configuration
    private weak var cardComponentDelegate: CardComponentDelegate?
    private weak var partialPaymentDelegate: PartialPaymentDelegate?

    // MARK: - Initializers

    internal init(
        component: PresentableComponent,
        context: AdyenContext,
        delegate: ComponentContainerViewModelDelegate,
        configuration: DropInComponent.Configuration,
        cardComponentDelegate: CardComponentDelegate?,
        partialPaymentDelegate: PartialPaymentDelegate?
    ) {
        self.component = component
        self.context = context
        self.delegate = delegate
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
        component.cancelIfNeeded()

        if let component = (component as? PaymentComponent) {
            delegate?.didCancel(component: component)
        }
        
        component.stopLoadingIfNeeded()
    }

    // MARK: - Private

    private func setupComponent() {
        (component as? PaymentComponent)?.delegate = self
        (component as? CardComponent)?.cardComponentDelegate = cardComponentDelegate
        (component as? PartialPaymentComponent)?.partialPaymentDelegate = partialPaymentDelegate
        (component as? PartialPaymentComponent)?.readyToSubmitComponentDelegate = self
    }
    
    private var actionComponent: AdyenActionComponent {
        let actionComponent = AdyenActionComponent(context: context)
        actionComponent.delegate = self
        actionComponent.presentationDelegate = self
        actionComponent.configuration.style = configuration.style.actionComponent
        actionComponent.configuration.localizationParameters = configuration.localizationParameters
        actionComponent.configuration.threeDS = configuration.actionComponent.threeDS
        actionComponent.configuration.twint = configuration.actionComponent.twint
        return actionComponent
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
            delegate?.didSubmit(updatedData, from: component)
            return
        }
        updatedData.dataByAddingBrowserInfo { [weak self] in
            guard let self else { return }
            delegate?.didSubmit($0, from: component)
        }
    }
    
    func didFail(
        with error: any Error,
        from component: any Adyen.PaymentComponent
    ) {
        if case ComponentError.cancelled = error {
            cancel()
        } else {
            delegate?.didFail(with: error)
        }
    }

    // MARK: - Private

}

extension ComponentContainerViewModel: ReadyToSubmitPaymentComponentDelegate {

    func showConfirmation(
        for component: InstantPaymentComponent,
        with order: PartialPaymentOrder?
    ) {
        // TODO: - Handle gift card balance confirmation
        // 1. Present preselected payment method.
    }
}

extension ComponentContainerViewModel: ActionComponentDelegate {
    
    func didOpenExternalApplication(component: any ActionComponent) {
        component.stopLoadingIfNeeded()
        delegate?.didOpenExternalApplication(component: component)
    }

    func didProvide(_ data: ActionComponentData, from component: any ActionComponent) {
        delegate?.didProvide(data, from: component)
    }
    
    func didComplete(from component: any ActionComponent) {
        delegate?.didComplete(from: component)
    }
    
    func didFail(with error: any Error, from component: any ActionComponent) {
        if case ComponentError.cancelled = error {
            cancel()
        } else {
            delegate?.didFail(with: error, from: component)
        }
    }

}

extension ComponentContainerViewModel: PresentationDelegate {

    func present(component: any Adyen.PresentableComponent) {
        // TODO: - Handle subsequent presentations
    }
}
