//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenActions)
    import AdyenActions
#endif
import Foundation
import UIKit

// sourcery:AutoMockable
@MainActor
internal protocol ActionPresenter: AnyObject {
    func present(actionViewController: UIViewController)
    func didCancel(actionComponent: ActionComponent)
}

// sourcery:AutoMockable
@MainActor
internal protocol DropInDismissing: AnyObject {
    func dismissDropIn(completion: (() -> Void)?)
}

// sourcery:AutoMockable
@MainActor
internal protocol DropInFlowManaging: AnyObject {
    /// The root router of the drop in, which the flow manager dismisses.
    var dropInFlowRouter: DropInDismissing? { get set }
    func submit(
        _ data: PaymentComponentData,
        from component: PaymentComponent,
        actionPresenter: ActionPresenter
    )
    func fail(with error: Error, from component: PaymentComponent)
    func cancel(component: PaymentComponent)
    func handle(action: Action)
    /// Notifies the merchant that the user closed the drop in before submitting a payment.
    func cancelDropIn()
    func dismissDropIn()
}

@MainActor
internal class DropInFlowManager: DropInFlowManaging {

    // MARK: - Properties

    internal weak var dropInFlowRouter: DropInDismissing?
    private weak var dropInComponent: DropInComponent?
    private let context: AdyenContext
    private let actionComponentConfiguration: CheckoutActionComponent.Configuration
    private weak var actionPresenter: ActionPresenter?
    private var didCancelDropIn = false

    // MARK: - Initializers

    internal init(
        dropInComponent: DropInComponent,
        context: AdyenContext,
        actionComponentConfiguration: CheckoutActionComponent.Configuration
    ) {
        self.dropInComponent = dropInComponent
        self.context = context
        self.actionComponentConfiguration = actionComponentConfiguration
    }

    // MARK: - Private

    private var dropInComponentDelegate: DropInComponentDelegate? {
        dropInComponent?.delegate
    }

    private lazy var actionComponent: CheckoutActionComponent = {
        let actionComponent = CheckoutActionComponent(
            context: context,
            configuration: actionComponentConfiguration
        )
        actionComponent.delegate = self
        actionComponent.presentationDelegate = self
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

    internal func cancelDropIn() {
        guard !didCancelDropIn else { return }
        didCancelDropIn = true

        sendExitEvent()

        guard let dropInComponent else { return }
        dropInComponentDelegate?.didFail(with: ComponentError.cancelled, from: dropInComponent)
    }

    internal func dismissDropIn() {
        dropInFlowRouter?.dismissDropIn(completion: nil)
    }

    // MARK: - Private

    private func sendExitEvent() {
        let logEvent = AnalyticsEventLog(component: AnalyticsConstants.dropInComponentIdentifier, type: .closed)
        context.analyticsProvider?.add(log: logEvent)
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

    internal func present(viewController: UIViewController) {
        actionPresenter?.present(actionViewController: viewController)
    }
}
