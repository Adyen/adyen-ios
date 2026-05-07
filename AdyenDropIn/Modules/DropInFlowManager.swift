//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
#if canImport(AdyenActions)
    import AdyenActions
#endif
import Foundation

// sourcery:AutoMockable
@MainActor
internal protocol ActionPresenter: AnyObject {
    func present(actionComponent: PresentableComponent)
    func didCancel(actionComponent: ActionComponent)
}

// sourcery:AutoMockable
@MainActor
internal protocol DropInFlowManaging {
    func submit(
        _ data: PaymentComponentData,
        from component: PaymentComponent,
        actionPresenter: ActionPresenter
    )
    func fail(with error: Error, from component: PaymentComponent)
    func cancel(component: PaymentComponent)
    func handle(action: Action)
}

@MainActor
internal class DropInFlowManager: DropInFlowManaging {

    // MARK: - Properties

    private weak var dropInComponent: DropInComponent?
    private weak var dropInComponentDelegate: DropInComponentDelegate?
    private let context: AdyenContext
    private let configuration: DropInComponent.Configuration
    private weak var actionPresenter: ActionPresenter?

    // MARK: - Initializers

    internal init(
        dropInComponent: DropInComponent,
        dropInComponentDelegate: DropInComponentDelegate?,
        context: AdyenContext,
        configuration: DropInComponent.Configuration
    ) {
        self.dropInComponent = dropInComponent
        self.dropInComponentDelegate = dropInComponentDelegate
        self.context = context
        self.configuration = configuration
    }

    // MARK: - Private

    private lazy var actionComponent: CheckoutActionComponent = {
        let actionComponent = CheckoutActionComponent(context: context)
        actionComponent.delegate = self
        actionComponent.presentationDelegate = self
        actionComponent.configuration.style = configuration.style.actionComponent
        actionComponent.configuration.localizationParameters = configuration.localizationParameters
        actionComponent.configuration.authentication = configuration.actionComponent.authentication
        actionComponent.configuration.twint = configuration.actionComponent.twint
        return actionComponent
    }()

    // MARK: - DropInFlowManaging

    internal func submit(
        _ data: PaymentComponentData,
        from component: PaymentComponent,
        actionPresenter: ActionPresenter
    ) {
        Task { [weak self] in
            guard let self, let dropInComponent else { return }
            self.actionPresenter = actionPresenter
            let updatedData = await component.prepareSubmitData(from: data)
            dropInComponentDelegate?.didSubmit(updatedData, from: component, in: dropInComponent)
        }
    }

    internal func fail(with error: Error, from component: PaymentComponent) {
        guard let dropInComponent else { return }
        dropInComponentDelegate?.didFail(with: error, from: component, in: dropInComponent)
    }

    internal func cancel(component: PaymentComponent) {
        guard let dropInComponent else { return }
        dropInComponentDelegate?.didCancel(component: component, from: dropInComponent)
    }

    internal func handle(action: Action) {
        actionComponent.handle(action)
    }
}

// MARK: - ActionComponentDelegate

extension DropInFlowManager: ActionComponentDelegate {

    internal func didOpenExternalApplication(component: any ActionComponent) {
        component.stopLoading()

        guard let dropInComponent else { return }
        dropInComponentDelegate?.didOpenExternalApplication(component: component, in: dropInComponent)
    }

    internal func didProvide(_ data: ActionComponentData, from component: any ActionComponent) {
        guard let dropInComponent else { return }
        dropInComponentDelegate?.didProvide(data, from: component, in: dropInComponent)
    }

    internal func didComplete(from component: any ActionComponent) {
        guard let dropInComponent else { return }
        dropInComponentDelegate?.didComplete(from: component, in: dropInComponent)
    }

    internal func didFail(with error: any Error, from component: any ActionComponent) {
        guard let dropInComponent else { return }

        if case ComponentError.cancelled = error {
            actionPresenter?.didCancel(actionComponent: component)
        } else {
            dropInComponentDelegate?.didFail(with: error, from: component, in: dropInComponent)
        }
    }
}

// MARK: - PresentationDelegate

extension DropInFlowManager: PresentationDelegate {

    internal func present(component: any PresentableComponent) {
        actionPresenter?.present(actionComponent: component)
    }
}
