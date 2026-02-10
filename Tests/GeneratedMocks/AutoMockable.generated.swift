//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable line_length
// swiftlint:disable variable_name

import Foundation
#if os(iOS) || os(tvOS) || os(watchOS)
    import UIKit
#elseif os(OSX)
    import AppKit
#endif

@testable import Adyen
@testable import AdyenCheckout
@testable import AdyenDropIn

class ActionPresenterMock: ActionPresenter {

    // MARK: - present

    var presentActionComponentCallsCount = 0
    var presentActionComponentCalled: Bool {
        presentActionComponentCallsCount > 0
    }

    var presentActionComponentReceivedActionComponent: PresentableComponent?
    var presentActionComponentReceivedInvocations: [PresentableComponent] = []
    var presentActionComponentClosure: ((PresentableComponent) -> Void)?

    func present(actionComponent: PresentableComponent) {
        presentActionComponentCallsCount += 1
        presentActionComponentReceivedActionComponent = actionComponent
        presentActionComponentReceivedInvocations.append(actionComponent)
        presentActionComponentClosure?(actionComponent)
    }

    // MARK: - didCancel

    var didCancelActionComponentCallsCount = 0
    var didCancelActionComponentCalled: Bool {
        didCancelActionComponentCallsCount > 0
    }

    var didCancelActionComponentReceivedActionComponent: ActionComponent?
    var didCancelActionComponentReceivedInvocations: [ActionComponent] = []
    var didCancelActionComponentClosure: ((ActionComponent) -> Void)?

    func didCancel(actionComponent: ActionComponent) {
        didCancelActionComponentCallsCount += 1
        didCancelActionComponentReceivedActionComponent = actionComponent
        didCancelActionComponentReceivedInvocations.append(actionComponent)
        didCancelActionComponentClosure?(actionComponent)
    }

}

class ComponentContainerAssemblerProtocolMock: ComponentContainerAssemblerProtocol {

    // MARK: - resolveComponentContainerRouter

    var resolveComponentContainerRouterForDelegateOnCancelCallsCount = 0
    var resolveComponentContainerRouterForDelegateOnCancelCalled: Bool {
        resolveComponentContainerRouterForDelegateOnCancelCallsCount > 0
    }

    var resolveComponentContainerRouterForDelegateOnCancelReturnValue: Router!
    var resolveComponentContainerRouterForDelegateOnCancelClosure: ((PresentableComponent, ComponentContainerRouterListener, (() -> Void)?) -> Router)?

    func resolveComponentContainerRouter(for component: PresentableComponent, delegate: ComponentContainerRouterListener, onCancel: (() -> Void)?) -> Router {
        resolveComponentContainerRouterForDelegateOnCancelCallsCount += 1
        if let resolveComponentContainerRouterForDelegateOnCancelClosure {
            return resolveComponentContainerRouterForDelegateOnCancelClosure(component, delegate, onCancel)
        } else {
            return resolveComponentContainerRouterForDelegateOnCancelReturnValue
        }
    }

}

class ComponentContainerRouterListenerMock: ComponentContainerRouterListener {

    // MARK: - didDismissComponentContainer

    var didDismissComponentContainerCompletionCallsCount = 0
    var didDismissComponentContainerCompletionCalled: Bool {
        didDismissComponentContainerCompletionCallsCount > 0
    }

    var didDismissComponentContainerCompletionClosure: (((() -> Void)?) -> Void)?

    func didDismissComponentContainer(completion: (() -> Void)?) {
        didDismissComponentContainerCompletionCallsCount += 1
        didDismissComponentContainerCompletionClosure?(completion)
    }

}

class ComponentContainerRoutingMock: ComponentContainerRouting {

    // MARK: - present

    var presentPaymentComponentCallsCount = 0
    var presentPaymentComponentCalled: Bool {
        presentPaymentComponentCallsCount > 0
    }

    var presentPaymentComponentReceivedPaymentComponent: PresentableComponent?
    var presentPaymentComponentReceivedInvocations: [PresentableComponent] = []
    var presentPaymentComponentClosure: ((PresentableComponent) -> Void)?

    func present(paymentComponent: PresentableComponent) {
        presentPaymentComponentCallsCount += 1
        presentPaymentComponentReceivedPaymentComponent = paymentComponent
        presentPaymentComponentReceivedInvocations.append(paymentComponent)
        presentPaymentComponentClosure?(paymentComponent)
    }

    // MARK: - present

    var presentActionComponentOnCancelCallsCount = 0
    var presentActionComponentOnCancelCalled: Bool {
        presentActionComponentOnCancelCallsCount > 0
    }

    var presentActionComponentOnCancelClosure: ((PresentableComponent, (() -> Void)?) -> Void)?

    func present(actionComponent: PresentableComponent, onCancel: (() -> Void)?) {
        presentActionComponentOnCancelCallsCount += 1
        presentActionComponentOnCancelClosure?(actionComponent, onCancel)
    }

    // MARK: - dismiss

    var dismissCompletionCallsCount = 0
    var dismissCompletionCalled: Bool {
        dismissCompletionCallsCount > 0
    }

    var dismissCompletionClosure: (((() -> Void)?) -> Void)?

    func dismiss(completion: (() -> Void)?) {
        dismissCompletionCallsCount += 1
        dismissCompletionClosure?(completion)
    }

}

class ComponentContainerViewModelProtocolMock: ComponentContainerViewModelProtocol {

    var componentViewController: UIViewController {
        get { underlyingComponentViewController }
        set(value) { underlyingComponentViewController = value }
    }

    var underlyingComponentViewController: UIViewController!

    // MARK: - cancel

    var cancelCallsCount = 0
    var cancelCalled: Bool {
        cancelCallsCount > 0
    }

    var cancelClosure: (() -> Void)?

    func cancel() {
        cancelCallsCount += 1
        cancelClosure?()
    }

}

class DropInFlowManagingMock: DropInFlowManaging {

    // MARK: - submit

    var submitFromActionPresenterCallsCount = 0
    var submitFromActionPresenterCalled: Bool {
        submitFromActionPresenterCallsCount > 0
    }

    var submitFromActionPresenterReceivedArguments: (data: PaymentComponentData, component: PaymentComponent, actionPresenter: ActionPresenter)?
    var submitFromActionPresenterReceivedInvocations: [(data: PaymentComponentData, component: PaymentComponent, actionPresenter: ActionPresenter)] = []
    var submitFromActionPresenterClosure: ((PaymentComponentData, PaymentComponent, ActionPresenter) -> Void)?

    func submit(_ data: PaymentComponentData, from component: PaymentComponent, actionPresenter: ActionPresenter) {
        submitFromActionPresenterCallsCount += 1
        submitFromActionPresenterReceivedArguments = (data: data, component: component, actionPresenter: actionPresenter)
        submitFromActionPresenterReceivedInvocations.append((data: data, component: component, actionPresenter: actionPresenter))
        submitFromActionPresenterClosure?(data, component, actionPresenter)
    }

    // MARK: - fail

    var failWithFromCallsCount = 0
    var failWithFromCalled: Bool {
        failWithFromCallsCount > 0
    }

    var failWithFromReceivedArguments: (error: Error, component: PaymentComponent)?
    var failWithFromReceivedInvocations: [(error: Error, component: PaymentComponent)] = []
    var failWithFromClosure: ((Error, PaymentComponent) -> Void)?

    func fail(with error: Error, from component: PaymentComponent) {
        failWithFromCallsCount += 1
        failWithFromReceivedArguments = (error: error, component: component)
        failWithFromReceivedInvocations.append((error: error, component: component))
        failWithFromClosure?(error, component)
    }

    // MARK: - cancel

    var cancelComponentCallsCount = 0
    var cancelComponentCalled: Bool {
        cancelComponentCallsCount > 0
    }

    var cancelComponentReceivedComponent: PaymentComponent?
    var cancelComponentReceivedInvocations: [PaymentComponent] = []
    var cancelComponentClosure: ((PaymentComponent) -> Void)?

    func cancel(component: PaymentComponent) {
        cancelComponentCallsCount += 1
        cancelComponentReceivedComponent = component
        cancelComponentReceivedInvocations.append(component)
        cancelComponentClosure?(component)
    }

    // MARK: - handle

    var handleActionCallsCount = 0
    var handleActionCalled: Bool {
        handleActionCallsCount > 0
    }

    var handleActionReceivedAction: Action?
    var handleActionReceivedInvocations: [Action] = []
    var handleActionClosure: ((Action) -> Void)?

    func handle(action: Action) {
        handleActionCallsCount += 1
        handleActionReceivedAction = action
        handleActionReceivedInvocations.append(action)
        handleActionClosure?(action)
    }

}

class PaymentMethodListRouterListenerMock: PaymentMethodListRouterListener {

    // MARK: - didDismissPaymentMethodList

    var didDismissPaymentMethodListCompletionCallsCount = 0
    var didDismissPaymentMethodListCompletionCalled: Bool {
        didDismissPaymentMethodListCompletionCallsCount > 0
    }

    var didDismissPaymentMethodListCompletionClosure: (((() -> Void)?) -> Void)?

    func didDismissPaymentMethodList(completion: (() -> Void)?) {
        didDismissPaymentMethodListCompletionCallsCount += 1
        didDismissPaymentMethodListCompletionClosure?(completion)
    }

}

class PaymentMethodListRoutingMock: PaymentMethodListRouting {

    // MARK: - present

    var presentPaymentComponentOnCancelCallsCount = 0
    var presentPaymentComponentOnCancelCalled: Bool {
        presentPaymentComponentOnCancelCallsCount > 0
    }

    var presentPaymentComponentOnCancelReceivedArguments: (paymentComponent: PresentableComponent, onCancel: () -> Void)?
    var presentPaymentComponentOnCancelReceivedInvocations: [(paymentComponent: PresentableComponent, onCancel: () -> Void)] = []
    var presentPaymentComponentOnCancelClosure: ((PresentableComponent, @escaping () -> Void) -> Void)?

    func present(paymentComponent: PresentableComponent, onCancel: @escaping () -> Void) {
        presentPaymentComponentOnCancelCallsCount += 1
        presentPaymentComponentOnCancelReceivedArguments = (paymentComponent: paymentComponent, onCancel: onCancel)
        presentPaymentComponentOnCancelReceivedInvocations.append((paymentComponent: paymentComponent, onCancel: onCancel))
        presentPaymentComponentOnCancelClosure?(paymentComponent, onCancel)
    }

    // MARK: - present

    var presentActionComponentOnCancelCallsCount = 0
    var presentActionComponentOnCancelCalled: Bool {
        presentActionComponentOnCancelCallsCount > 0
    }

    var presentActionComponentOnCancelClosure: ((any PresentableComponent, (() -> Void)?) -> Void)?

    func present(actionComponent: any PresentableComponent, onCancel: (() -> Void)?) {
        presentActionComponentOnCancelCallsCount += 1
        presentActionComponentOnCancelClosure?(actionComponent, onCancel)
    }

    // MARK: - dismiss

    var dismissCompletionCallsCount = 0
    var dismissCompletionCalled: Bool {
        dismissCompletionCallsCount > 0
    }

    var dismissCompletionClosure: (((() -> Void)?) -> Void)?

    func dismiss(completion: (() -> Void)?) {
        dismissCompletionCallsCount += 1
        dismissCompletionClosure?(completion)
    }

}

class PaymentMethodListViewModelProtocolMock: PaymentMethodListViewModelProtocol {

    var paymentMethodListView: UIViewController {
        get { underlyingPaymentMethodListView }
        set(value) { underlyingPaymentMethodListView = value }
    }

    var underlyingPaymentMethodListView: UIViewController!

    // MARK: - cancel

    var cancelCallsCount = 0
    var cancelCalled: Bool {
        cancelCallsCount > 0
    }

    var cancelClosure: (() -> Void)?

    func cancel() {
        cancelCallsCount += 1
        cancelClosure?()
    }

}

class RouterMock: Router {

    var childRouter: Router?
    var rootViewController: UIViewController {
        get { underlyingRootViewController }
        set(value) { underlyingRootViewController = value }
    }

    var underlyingRootViewController: UIViewController!

}
