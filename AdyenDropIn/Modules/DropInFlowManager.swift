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
internal protocol DropInDismissing: AnyObject {
    func dismissDropIn(completion: (() -> Void)?)
}

// sourcery:AutoMockable
@MainActor
internal protocol DropInFlowManaging: AnyObject {
    var dropInDismisser: DropInDismissing? { get set }
    /// Submits the payment and waits for the action returned by the payment session, if any.
    func submit(_ data: PaymentComponentData, from component: PaymentComponent) async -> Action?
    /// Delivers the action returned by the payment session to the pending submission.
    func receive(action: Action)
    /// Handles the action and waits for the view controller the action needs to present, if any.
    func handle(action: Action) async -> UIViewController?
    func fail(with error: Error, from component: PaymentComponent)
    func cancel(component: PaymentComponent)
    /// Notifies the merchant that the user closed the drop in before submitting a payment.
    func cancelDropIn()
    func dismissDropIn()
}

@MainActor
internal class DropInFlowManager: DropInFlowManaging {

    // MARK: - Properties

    internal weak var dropInDismisser: DropInDismissing?
    private weak var dropInComponent: DropInComponent?
    private weak var dropInComponentDelegate: DropInComponentDelegate?
    private let context: AdyenContext
    private let actionComponentConfiguration: CheckoutActionComponent.Configuration

    private var submissionContinuation: CheckedContinuation<Action?, Never>?
    private var actionViewControllerContinuation: CheckedContinuation<UIViewController?, Never>?
    private var didCancelDropIn = false

    // MARK: - Initializers

    internal init(
        dropInComponent: DropInComponent,
        dropInComponentDelegate: DropInComponentDelegate?,
        context: AdyenContext,
        actionComponentConfiguration: CheckoutActionComponent.Configuration
    ) {
        self.dropInComponent = dropInComponent
        self.dropInComponentDelegate = dropInComponentDelegate
        self.context = context
        self.actionComponentConfiguration = actionComponentConfiguration
    }

    deinit {
        submissionContinuation?.resume(returning: nil)
        actionViewControllerContinuation?.resume(returning: nil)
    }

    // MARK: - Private

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
        from component: PaymentComponent
    ) async -> Action? {
        resumeSubmission(with: nil)

        let updatedData = await component.prepareSubmitData(from: data)
        guard let dropInComponent else { return nil }

        return await withTaskCancellationHandler {
            await withCheckedContinuation { continuation in
                submissionContinuation = continuation
                dropInComponentDelegate?.didSubmit(updatedData, from: component, in: dropInComponent)
            }
        } onCancel: {
            Task { @MainActor [weak self] in
                self?.resumeSubmission(with: nil)
            }
        }
    }

    internal func receive(action: Action) {
        // An action can arrive after the submission was resumed,
        // for example when the drop in was closed while the payment was in flight.
        guard submissionContinuation != nil else { return }

        resumeSubmission(with: action)
    }

    internal func handle(action: Action) async -> UIViewController? {
        await withCheckedContinuation { continuation in
            actionViewControllerContinuation = continuation
            actionComponent.handle(action)
        }
    }

    internal func fail(with error: Error, from component: PaymentComponent) {
        guard let dropInComponent else { return }
        dropInComponentDelegate?.didFail(with: error, from: component, in: dropInComponent)
    }

    internal func cancel(component: PaymentComponent) {
        resumeSubmission(with: nil)

        guard let dropInComponent else { return }
        dropInComponentDelegate?.didCancel(component: component, from: dropInComponent)
    }

    internal func cancelDropIn() {
        guard !didCancelDropIn else { return }
        didCancelDropIn = true

        resumeSubmission(with: nil)
        sendExitEvent()

        guard let dropInComponent else { return }
        dropInComponentDelegate?.didFail(with: ComponentError.cancelled, from: dropInComponent)
    }

    internal func dismissDropIn() {
        dropInDismisser?.dismissDropIn(completion: nil)
    }

    // MARK: - Private

    private func sendExitEvent() {
        let logEvent = AnalyticsEventLog(component: AnalyticsConstants.dropInComponentIdentifier, type: .closed)
        context.analyticsProvider?.add(log: logEvent)
    }

    private func resumeSubmission(with action: Action?) {
        guard let submissionContinuation else { return }
        self.submissionContinuation = nil
        submissionContinuation.resume(returning: action)
    }

    private func resumeActionPresentation(with viewController: UIViewController?) {
        guard let actionViewControllerContinuation else { return }
        self.actionViewControllerContinuation = nil
        actionViewControllerContinuation.resume(returning: viewController)
    }
}

// MARK: - ActionComponentDelegate

extension DropInFlowManager: ActionComponentDelegate {

    internal func didOpenExternalApplication(component: any ActionComponent) {
        component.stopLoading()
        resumeActionPresentation(with: nil)

        guard let dropInComponent else { return }
        dropInComponentDelegate?.didOpenExternalApplication(component: component, in: dropInComponent)
    }

    internal func didProvide(_ data: ActionComponentData, from component: any ActionComponent) {
        resumeActionPresentation(with: nil)

        guard let dropInComponent else { return }
        dropInComponentDelegate?.didProvide(data, from: component, in: dropInComponent)
    }

    internal func didComplete(from component: any ActionComponent) {
        resumeActionPresentation(with: nil)

        guard let dropInComponent else { return }
        dropInComponentDelegate?.didComplete(from: component, in: dropInComponent)
    }

    internal func didFail(with error: any Error, from component: any ActionComponent) {
        resumeActionPresentation(with: nil)

        // Dismissing an action, for example by closing the web page of a redirect,
        // dismisses the drop in as there is no way back to the payment details.
        if case ComponentError.cancelled = error {
            cancelDropIn()
            return dismissDropIn()
        }

        guard let dropInComponent else { return }
        dropInComponentDelegate?.didFail(with: error, from: component, in: dropInComponent)
    }
}

// MARK: - PresentationDelegate

extension DropInFlowManager: PresentationDelegate {

    internal func present(viewController: UIViewController) {
        resumeActionPresentation(with: viewController)
    }
}
