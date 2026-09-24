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

/// The root router of the drop in, on which the flow manager presents actions and which it dismisses.
// sourcery:AutoMockable
@MainActor
internal protocol DropInFlowRouting: PaymentActionPresenting, DropInDismissing {}

// sourcery:AutoMockable
@MainActor
internal protocol DropInFlowManaging: AnyObject {
    var dropInFlowRouter: DropInFlowRouting? { get set }
    /// Submits the payment, presenting the action returned by the payment session, if any, on the root router.
    func submit(_ data: PaymentComponentData, from component: PaymentComponent)
    /// Handles the action returned by the payment session for the pending submission.
    func receive(action: Action)
    func fail(with error: Error, from component: PaymentComponent)
    func cancel(component: PaymentComponent)
    /// Notifies the merchant that the user closed the drop in before submitting a payment.
    func cancelDropIn()
    func dismissDropIn()
}

@MainActor
internal class DropInFlowManager: DropInFlowManaging {

    // MARK: - Properties

    internal weak var dropInFlowRouter: DropInFlowRouting?
    private weak var dropInComponent: DropInComponent?
    private weak var dropInComponentDelegate: DropInComponentDelegate?
    private let context: AdyenContext
    private let actionComponentConfiguration: CheckoutActionComponent.Configuration
    private let paymentActionAssembler: PaymentActionAssemblerProtocol

    private var submissionTask: Task<Void, Never>?
    /// Whether the payment session is expected to return an action to handle.
    private var isAwaitingAction = false
    private var didCancelDropIn = false

    // MARK: - Initializers

    internal init(
        dropInComponent: DropInComponent,
        dropInComponentDelegate: DropInComponentDelegate?,
        context: AdyenContext,
        actionComponentConfiguration: CheckoutActionComponent.Configuration,
        paymentActionAssembler: PaymentActionAssemblerProtocol
    ) {
        self.dropInComponent = dropInComponent
        self.dropInComponentDelegate = dropInComponentDelegate
        self.context = context
        self.actionComponentConfiguration = actionComponentConfiguration
        self.paymentActionAssembler = paymentActionAssembler
    }

    deinit {
        submissionTask?.cancel()
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
    ) {
        submissionTask?.cancel()

        isAwaitingAction = true

        submissionTask = Task { [weak self] in
            let updatedData = await component.prepareSubmitData(from: data)
            guard !Task.isCancelled else { return }
            self?.notifyDidSubmit(updatedData, from: component)
        }
    }

    internal func receive(action: Action) {
        // An action can arrive when none is expected,
        // for example when the drop in was closed while the payment was in flight.
        guard isAwaitingAction else { return }
        isAwaitingAction = false

        actionComponent.handle(action)
    }

    internal func fail(with error: Error, from component: PaymentComponent) {
        guard let dropInComponent else { return }
        dropInComponentDelegate?.didFail(with: error, from: component, in: dropInComponent)
    }

    internal func cancel(component: PaymentComponent) {
        endSubmission()

        guard let dropInComponent else { return }
        dropInComponentDelegate?.didCancel(component: component, from: dropInComponent)
    }

    internal func cancelDropIn() {
        guard !didCancelDropIn else { return }
        didCancelDropIn = true

        endSubmission()
        sendExitEvent()

        guard let dropInComponent else { return }
        dropInComponentDelegate?.didFail(with: ComponentError.cancelled, from: dropInComponent)
    }

    internal func dismissDropIn() {
        dropInFlowRouter?.dismissDropIn(completion: nil)
    }

    // MARK: - Private

    private func notifyDidSubmit(_ data: PaymentComponentData, from component: PaymentComponent) {
        guard let dropInComponent else { return }
        dropInComponentDelegate?.didSubmit(data, from: component, in: dropInComponent)
    }

    private func endSubmission() {
        submissionTask?.cancel()
        submissionTask = nil
        isAwaitingAction = false
    }

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
        // The details are sent to the payment session, which can return a follow up action,
        // as happens between the fingerprint and the challenge of a 3DS2 authentication.
        isAwaitingAction = true

        guard let dropInComponent else { return }
        dropInComponentDelegate?.didProvide(data, from: component, in: dropInComponent)
    }

    internal func didComplete(from component: any ActionComponent) {
        endSubmission()

        guard let dropInComponent else { return }
        dropInComponentDelegate?.didComplete(from: component, in: dropInComponent)
    }

    internal func didFail(with error: any Error, from component: any ActionComponent) {
        endSubmission()

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
        guard let dropInFlowRouter else { return }

        // The action module dismisses the drop in through its listener,
        // so only the merchant needs to be notified on cancellation.
        let paymentActionRouter = paymentActionAssembler.resolvePaymentActionRouter(
            for: viewController,
            listener: dropInFlowRouter,
            onCancel: { [weak self] in
                self?.cancelDropIn()
            }
        )

        dropInFlowRouter.present(paymentActionRouter: paymentActionRouter)
    }
}
