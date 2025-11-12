//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import Adyen
import AdyenActions

internal protocol DropInFlowManaging {
    func submit(_ data: PaymentComponentData, from component: PaymentComponent)
    func fail(with error: Error, from component: PaymentComponent)
    func fail(with error: Error)
    func cancel(component: PaymentComponent)
}

internal class DropInFlowManager: DropInFlowManaging {

    // MARK: - Properties

    private weak var dropInComponent: DropInComponent?
    private weak var dropInComponentDelegate: DropInComponentDelegate?
    private let context: AdyenContext
    private let configuration: DropInComponent.Configuration

    // MARK: - Initializers

    internal init(
        dropInComponent: DropInComponent,
        dropInComponentDelegate: DropInComponentDelegate,
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

    func submit(_ data: PaymentComponentData, from component: PaymentComponent) {
        guard let dropInComponent else { return }
        dropInComponentDelegate?.didSubmit(data, from: component, in: dropInComponent)
    }

    func fail(with error: Error, from component: PaymentComponent) {
        guard let dropInComponent else { return }
        dropInComponentDelegate?.didFail(with: error, from: component, in: dropInComponent)
    }

    func fail(with error: Error) {
        guard let dropInComponent else { return }
        dropInComponentDelegate?.didFail(with: error, from: dropInComponent)
    }

    func cancel(component: PaymentComponent) {
        guard let dropInComponent else { return }
        dropInComponentDelegate?.didCancel(component: component, from: dropInComponent)
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
            // TODO: - Handle action cancellation
        } else {
            dropInComponentDelegate?.didFail(with: error, from: component, in: dropInComponent)
        }
    }
}

// MARK: - PresentationDelegate

extension DropInFlowManager: PresentationDelegate {

    internal func present(component: any PresentableComponent) {
        // TODO: - Handle presentation
    }
}

