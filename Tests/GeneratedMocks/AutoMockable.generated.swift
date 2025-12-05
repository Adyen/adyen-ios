//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
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
@testable import AdyenActions
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

public class DropInComponentDelegateMock: DropInComponentDelegate {

    public init() {}

    // MARK: - didSubmit

    public var didSubmitFromInCallsCount = 0
    public var didSubmitFromInCalled: Bool {
        didSubmitFromInCallsCount > 0
    }

    public var didSubmitFromInReceivedArguments: (data: PaymentComponentData, component: PaymentComponent, dropInComponent: AnyDropInComponent)?
    public var didSubmitFromInReceivedInvocations: [(data: PaymentComponentData, component: PaymentComponent, dropInComponent: AnyDropInComponent)] = []
    public var didSubmitFromInClosure: ((PaymentComponentData, PaymentComponent, AnyDropInComponent) -> Void)?

    public func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent, in dropInComponent: AnyDropInComponent) {
        didSubmitFromInCallsCount += 1
        didSubmitFromInReceivedArguments = (data: data, component: component, dropInComponent: dropInComponent)
        didSubmitFromInReceivedInvocations.append((data: data, component: component, dropInComponent: dropInComponent))
        didSubmitFromInClosure?(data, component, dropInComponent)
    }

    // MARK: - didFail

    public var didFailWithFromInCallsCount = 0
    public var didFailWithFromInCalled: Bool {
        didFailWithFromInCallsCount > 0
    }

    public var didFailWithFromInReceivedArguments: (error: Error, component: PaymentComponent, dropInComponent: AnyDropInComponent)?
    public var didFailWithFromInReceivedInvocations: [(error: Error, component: PaymentComponent, dropInComponent: AnyDropInComponent)] = []
    public var didFailWithFromInClosure: ((Error, PaymentComponent, AnyDropInComponent) -> Void)?

    public func didFail(with error: Error, from component: PaymentComponent, in dropInComponent: AnyDropInComponent) {
        didFailWithFromInCallsCount += 1
        didFailWithFromInReceivedArguments = (error: error, component: component, dropInComponent: dropInComponent)
        didFailWithFromInReceivedInvocations.append((error: error, component: component, dropInComponent: dropInComponent))
        didFailWithFromInClosure?(error, component, dropInComponent)
    }

    // MARK: - didProvide

    public var didProvideFromInCallsCount = 0
    public var didProvideFromInCalled: Bool {
        didProvideFromInCallsCount > 0
    }

    public var didProvideFromInReceivedArguments: (data: ActionComponentData, component: ActionComponent, dropInComponent: AnyDropInComponent)?
    public var didProvideFromInReceivedInvocations: [(data: ActionComponentData, component: ActionComponent, dropInComponent: AnyDropInComponent)] = []
    public var didProvideFromInClosure: ((ActionComponentData, ActionComponent, AnyDropInComponent) -> Void)?

    public func didProvide(_ data: ActionComponentData, from component: ActionComponent, in dropInComponent: AnyDropInComponent) {
        didProvideFromInCallsCount += 1
        didProvideFromInReceivedArguments = (data: data, component: component, dropInComponent: dropInComponent)
        didProvideFromInReceivedInvocations.append((data: data, component: component, dropInComponent: dropInComponent))
        didProvideFromInClosure?(data, component, dropInComponent)
    }

    // MARK: - didComplete

    public var didCompleteFromInCallsCount = 0
    public var didCompleteFromInCalled: Bool {
        didCompleteFromInCallsCount > 0
    }

    public var didCompleteFromInReceivedArguments: (component: ActionComponent, dropInComponent: AnyDropInComponent)?
    public var didCompleteFromInReceivedInvocations: [(component: ActionComponent, dropInComponent: AnyDropInComponent)] = []
    public var didCompleteFromInClosure: ((ActionComponent, AnyDropInComponent) -> Void)?

    public func didComplete(from component: ActionComponent, in dropInComponent: AnyDropInComponent) {
        didCompleteFromInCallsCount += 1
        didCompleteFromInReceivedArguments = (component: component, dropInComponent: dropInComponent)
        didCompleteFromInReceivedInvocations.append((component: component, dropInComponent: dropInComponent))
        didCompleteFromInClosure?(component, dropInComponent)
    }

    // MARK: - didFail

//    public var didFailWithFromInCallsCount = 0
//    public var didFailWithFromInCalled: Bool {
//        didFailWithFromInCallsCount > 0
//    }
//
//    public var didFailWithFromInReceivedArguments: (error: Error, component: ActionComponent, dropInComponent: AnyDropInComponent)?
//    public var didFailWithFromInReceivedInvocations: [(error: Error, component: ActionComponent, dropInComponent: AnyDropInComponent)] = []
//    public var didFailWithFromInClosure: ((Error, ActionComponent, AnyDropInComponent) -> Void)?

    public func didFail(with error: Error, from component: ActionComponent, in dropInComponent: AnyDropInComponent) {
//        didFailWithFromInCallsCount += 1
//        didFailWithFromInReceivedArguments = (error: error, component: component, dropInComponent: dropInComponent)
//        didFailWithFromInReceivedInvocations.append((error: error, component: component, dropInComponent: dropInComponent))
//        didFailWithFromInClosure?(error, component, dropInComponent)
    }

    // MARK: - didOpenExternalApplication

    public var didOpenExternalApplicationComponentInCallsCount = 0
    public var didOpenExternalApplicationComponentInCalled: Bool {
        didOpenExternalApplicationComponentInCallsCount > 0
    }

    public var didOpenExternalApplicationComponentInReceivedArguments: (component: ActionComponent, dropInComponent: AnyDropInComponent)?
    public var didOpenExternalApplicationComponentInReceivedInvocations: [(component: ActionComponent, dropInComponent: AnyDropInComponent)] = []
    public var didOpenExternalApplicationComponentInClosure: ((ActionComponent, AnyDropInComponent) -> Void)?

    public func didOpenExternalApplication(component: ActionComponent, in dropInComponent: AnyDropInComponent) {
        didOpenExternalApplicationComponentInCallsCount += 1
        didOpenExternalApplicationComponentInReceivedArguments = (component: component, dropInComponent: dropInComponent)
        didOpenExternalApplicationComponentInReceivedInvocations.append((component: component, dropInComponent: dropInComponent))
        didOpenExternalApplicationComponentInClosure?(component, dropInComponent)
    }

    // MARK: - didFail

    public var didFailWithFromCallsCount = 0
    public var didFailWithFromCalled: Bool {
        didFailWithFromCallsCount > 0
    }

    public var didFailWithFromReceivedArguments: (error: Error, dropInComponent: AnyDropInComponent)?
    public var didFailWithFromReceivedInvocations: [(error: Error, dropInComponent: AnyDropInComponent)] = []
    public var didFailWithFromClosure: ((Error, AnyDropInComponent) -> Void)?

    public func didFail(with error: Error, from dropInComponent: AnyDropInComponent) {
        didFailWithFromCallsCount += 1
        didFailWithFromReceivedArguments = (error: error, dropInComponent: dropInComponent)
        didFailWithFromReceivedInvocations.append((error: error, dropInComponent: dropInComponent))
        didFailWithFromClosure?(error, dropInComponent)
    }

    // MARK: - didCancel

    public var didCancelComponentFromCallsCount = 0
    public var didCancelComponentFromCalled: Bool {
        didCancelComponentFromCallsCount > 0
    }

    public var didCancelComponentFromReceivedArguments: (component: PaymentComponent, dropInComponent: AnyDropInComponent)?
    public var didCancelComponentFromReceivedInvocations: [(component: PaymentComponent, dropInComponent: AnyDropInComponent)] = []
    public var didCancelComponentFromClosure: ((PaymentComponent, AnyDropInComponent) -> Void)?

    public func didCancel(component: PaymentComponent, from dropInComponent: AnyDropInComponent) {
        didCancelComponentFromCallsCount += 1
        didCancelComponentFromReceivedArguments = (component: component, dropInComponent: dropInComponent)
        didCancelComponentFromReceivedInvocations.append((component: component, dropInComponent: dropInComponent))
        didCancelComponentFromClosure?(component, dropInComponent)
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
