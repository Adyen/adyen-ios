//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import AdyenActions
import Foundation

internal protocol DropInFlowManagerDelegate: AnyObject {
    func didPresent(actionComponent: PresentableComponent)
    func didCancel(actionComponent: ActionComponent)
}

internal protocol DropInFlowManaging {
    var delegate: DropInFlowManagerDelegate? { get set }
    func submit(_ data: PaymentComponentData, from component: PaymentComponent)
    func fail(with error: Error, from component: PaymentComponent)
    func cancel(component: PaymentComponent)
    func handle(action: Action)
}

internal class DropInFlowManager: DropInFlowManaging {

    // MARK: - Properties

    private weak var dropInComponent: DropInComponent?
    private weak var dropInComponentDelegate: DropInComponentDelegate?
    private let context: AdyenContext
    private let configuration: DropInComponent.Configuration
    internal weak var delegate: DropInFlowManagerDelegate?

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

    private lazy var actionComponent: AdyenActionComponent = {
        let actionComponent = AdyenActionComponent(context: context)
        actionComponent.delegate = self
        actionComponent.presentationDelegate = self
        actionComponent.configuration.style = configuration.style.actionComponent
        actionComponent.configuration.localizationParameters = configuration.localizationParameters
        actionComponent.configuration.threeDS = configuration.actionComponent.threeDS
        actionComponent.configuration.twint = configuration.actionComponent.twint
        return actionComponent
    }()

    // MARK: - DropInFlowManaging

    internal func submit(_ data: PaymentComponentData, from component: PaymentComponent) {
        guard let dropInComponent else { return }

        let checkoutAttemptId = component.context.analyticsProvider?.checkoutAttemptId
        let updatedData = data.replacing(
            checkoutAttemptId: checkoutAttemptId
        )

        guard updatedData.browserInfo == nil else {
            dropInComponentDelegate?.didSubmit(updatedData, from: component, in: dropInComponent)
            return
        }
        updatedData.dataByAddingBrowserInfo { [weak self] newData in
            guard let self else { return }
            dropInComponentDelegate?.didSubmit(newData, from: component, in: dropInComponent)
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
            delegate?.didCancel(actionComponent: component)
        } else {
            dropInComponentDelegate?.didFail(with: error, from: component, in: dropInComponent)
        }
    }
}

// MARK: - PresentationDelegate

extension DropInFlowManager: PresentationDelegate {

    internal func present(component: any PresentableComponent) {
        delegate?.didPresent(actionComponent: component)
    }
}
