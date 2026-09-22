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
@testable import AdyenCard
@testable import AdyenCheckout
@testable import AdyenDropIn
@testable import AdyenUI

public class AnyEventAnalyticsProviderMock: AnyEventAnalyticsProvider {

    public init() {}

    public var checkoutAttemptId: String?

    // MARK: - add

    public var addInfoCallsCount = 0
    public var addInfoCalled: Bool {
        addInfoCallsCount > 0
    }

    public var addInfoReceivedInfo: AnalyticsEventInfo?
    public var addInfoReceivedInvocations: [AnalyticsEventInfo] = []
    public var addInfoClosure: ((AnalyticsEventInfo) -> Void)?

    public func add(info: AnalyticsEventInfo) {
        addInfoCallsCount += 1
        addInfoReceivedInfo = info
        addInfoReceivedInvocations.append(info)
        addInfoClosure?(info)
    }

    // MARK: - add

    public var addLogCallsCount = 0
    public var addLogCalled: Bool {
        addLogCallsCount > 0
    }

    public var addLogReceivedLog: AnalyticsEventLog?
    public var addLogReceivedInvocations: [AnalyticsEventLog] = []
    public var addLogClosure: ((AnalyticsEventLog) -> Void)?

    public func add(log: AnalyticsEventLog) {
        addLogCallsCount += 1
        addLogReceivedLog = log
        addLogReceivedInvocations.append(log)
        addLogClosure?(log)
    }

    // MARK: - add

    public var addErrorCallsCount = 0
    public var addErrorCalled: Bool {
        addErrorCallsCount > 0
    }

    public var addErrorReceivedError: AnalyticsEventError?
    public var addErrorReceivedInvocations: [AnalyticsEventError] = []
    public var addErrorClosure: ((AnalyticsEventError) -> Void)?

    public func add(error: AnalyticsEventError) {
        addErrorCallsCount += 1
        addErrorReceivedError = error
        addErrorReceivedInvocations.append(error)
        addErrorClosure?(error)
    }

}

class ComponentContainerAssemblerProtocolMock: ComponentContainerAssemblerProtocol {

    // MARK: - resolveComponentContainerRouter

    var resolveComponentContainerRouterForListenerCallsCount = 0
    var resolveComponentContainerRouterForListenerCalled: Bool {
        resolveComponentContainerRouterForListenerCallsCount > 0
    }

    var resolveComponentContainerRouterForListenerReceivedArguments: (component: PaymentComponent, listener: ComponentContainerRouterListener)?
    var resolveComponentContainerRouterForListenerReceivedInvocations: [(component: PaymentComponent, listener: ComponentContainerRouterListener)] = []
    var resolveComponentContainerRouterForListenerReturnValue: Router!
    var resolveComponentContainerRouterForListenerClosure: ((PaymentComponent, ComponentContainerRouterListener) -> Router)?

    func resolveComponentContainerRouter(for component: PaymentComponent, listener: ComponentContainerRouterListener) -> Router {
        resolveComponentContainerRouterForListenerCallsCount += 1
        resolveComponentContainerRouterForListenerReceivedArguments = (component: component, listener: listener)
        resolveComponentContainerRouterForListenerReceivedInvocations.append((component: component, listener: listener))
        if let resolveComponentContainerRouterForListenerClosure {
            return resolveComponentContainerRouterForListenerClosure(component, listener)
        } else {
            return resolveComponentContainerRouterForListenerReturnValue
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

    var presentPaymentComponentReceivedPaymentComponent: PaymentComponent?
    var presentPaymentComponentReceivedInvocations: [PaymentComponent] = []
    var presentPaymentComponentClosure: ((PaymentComponent) -> Void)?

    func present(paymentComponent: PaymentComponent) {
        presentPaymentComponentCallsCount += 1
        presentPaymentComponentReceivedPaymentComponent = paymentComponent
        presentPaymentComponentReceivedInvocations.append(paymentComponent)
        presentPaymentComponentClosure?(paymentComponent)
    }

    // MARK: - presentPaymentAction

    var presentPaymentActionForCallsCount = 0
    var presentPaymentActionForCalled: Bool {
        presentPaymentActionForCallsCount > 0
    }

    var presentPaymentActionForReceivedAction: Action?
    var presentPaymentActionForReceivedInvocations: [Action] = []
    var presentPaymentActionForClosure: ((Action) async -> Void)?

    func presentPaymentAction(for action: Action) async {
        presentPaymentActionForCallsCount += 1
        presentPaymentActionForReceivedAction = action
        presentPaymentActionForReceivedInvocations.append(action)
        await presentPaymentActionForClosure?(action)
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

class DropInDismissingMock: DropInDismissing {

    // MARK: - dismissDropIn

    var dismissDropInCompletionCallsCount = 0
    var dismissDropInCompletionCalled: Bool {
        dismissDropInCompletionCallsCount > 0
    }

    var dismissDropInCompletionClosure: (((() -> Void)?) -> Void)?

    func dismissDropIn(completion: (() -> Void)?) {
        dismissDropInCompletionCallsCount += 1
        dismissDropInCompletionClosure?(completion)
    }

}

class DropInFlowManagingMock: DropInFlowManaging {

    var dropInDismisser: DropInDismissing?

    // MARK: - submit

    var submitFromCallsCount = 0
    var submitFromCalled: Bool {
        submitFromCallsCount > 0
    }

    var submitFromReceivedArguments: (data: PaymentComponentData, component: PaymentComponent)?
    var submitFromReceivedInvocations: [(data: PaymentComponentData, component: PaymentComponent)] = []
    var submitFromReturnValue: Action?
    var submitFromClosure: ((PaymentComponentData, PaymentComponent) async -> Action?)?

    func submit(_ data: PaymentComponentData, from component: PaymentComponent) async -> Action? {
        submitFromCallsCount += 1
        submitFromReceivedArguments = (data: data, component: component)
        submitFromReceivedInvocations.append((data: data, component: component))
        if let submitFromClosure {
            return await submitFromClosure(data, component)
        } else {
            return submitFromReturnValue
        }
    }

    // MARK: - receive

    var receiveActionCallsCount = 0
    var receiveActionCalled: Bool {
        receiveActionCallsCount > 0
    }

    var receiveActionReceivedAction: Action?
    var receiveActionReceivedInvocations: [Action] = []
    var receiveActionClosure: ((Action) -> Void)?

    func receive(action: Action) {
        receiveActionCallsCount += 1
        receiveActionReceivedAction = action
        receiveActionReceivedInvocations.append(action)
        receiveActionClosure?(action)
    }

    // MARK: - handle

    var handleActionCallsCount = 0
    var handleActionCalled: Bool {
        handleActionCallsCount > 0
    }

    var handleActionReceivedAction: Action?
    var handleActionReceivedInvocations: [Action] = []
    var handleActionReturnValue: UIViewController?
    var handleActionClosure: ((Action) async -> UIViewController?)?

    func handle(action: Action) async -> UIViewController? {
        handleActionCallsCount += 1
        handleActionReceivedAction = action
        handleActionReceivedInvocations.append(action)
        if let handleActionClosure {
            return await handleActionClosure(action)
        } else {
            return handleActionReturnValue
        }
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

    // MARK: - cancelDropIn

    var cancelDropInCallsCount = 0
    var cancelDropInCalled: Bool {
        cancelDropInCallsCount > 0
    }

    var cancelDropInClosure: (() -> Void)?

    func cancelDropIn() {
        cancelDropInCallsCount += 1
        cancelDropInClosure?()
    }

    // MARK: - finishPendingSubmission

    var finishPendingSubmissionCallsCount = 0
    var finishPendingSubmissionCalled: Bool {
        finishPendingSubmissionCallsCount > 0
    }

    var finishPendingSubmissionClosure: (() -> Void)?

    func finishPendingSubmission() {
        finishPendingSubmissionCallsCount += 1
        finishPendingSubmissionClosure?()
    }

    // MARK: - dismissDropIn

    var dismissDropInCallsCount = 0
    var dismissDropInCalled: Bool {
        dismissDropInCallsCount > 0
    }

    var dismissDropInClosure: (() -> Void)?

    func dismissDropIn() {
        dismissDropInCallsCount += 1
        dismissDropInClosure?()
    }

}

class GenericPaymentMethodAssemblerProtocolMock: GenericPaymentMethodAssemblerProtocol {

    // MARK: - resolveGenericPaymentMethodRouter

    var resolveGenericPaymentMethodRouterForListenerCallsCount = 0
    var resolveGenericPaymentMethodRouterForListenerCalled: Bool {
        resolveGenericPaymentMethodRouterForListenerCallsCount > 0
    }

    var resolveGenericPaymentMethodRouterForListenerReceivedArguments: (component: PaymentComponent, listener: GenericPaymentMethodRouterListener)?
    var resolveGenericPaymentMethodRouterForListenerReceivedInvocations: [(component: PaymentComponent, listener: GenericPaymentMethodRouterListener)] = []
    var resolveGenericPaymentMethodRouterForListenerReturnValue: Router!
    var resolveGenericPaymentMethodRouterForListenerClosure: ((PaymentComponent, GenericPaymentMethodRouterListener) -> Router)?

    func resolveGenericPaymentMethodRouter(for component: PaymentComponent, listener: GenericPaymentMethodRouterListener) -> Router {
        resolveGenericPaymentMethodRouterForListenerCallsCount += 1
        resolveGenericPaymentMethodRouterForListenerReceivedArguments = (component: component, listener: listener)
        resolveGenericPaymentMethodRouterForListenerReceivedInvocations.append((component: component, listener: listener))
        if let resolveGenericPaymentMethodRouterForListenerClosure {
            return resolveGenericPaymentMethodRouterForListenerClosure(component, listener)
        } else {
            return resolveGenericPaymentMethodRouterForListenerReturnValue
        }
    }

}

class GenericPaymentMethodRouterListenerMock: GenericPaymentMethodRouterListener {

    // MARK: - didDismissGenericPaymentMethod

    var didDismissGenericPaymentMethodCallsCount = 0
    var didDismissGenericPaymentMethodCalled: Bool {
        didDismissGenericPaymentMethodCallsCount > 0
    }

    var didDismissGenericPaymentMethodClosure: (() -> Void)?

    func didDismissGenericPaymentMethod() {
        didDismissGenericPaymentMethodCallsCount += 1
        didDismissGenericPaymentMethodClosure?()
    }

}

class GenericPaymentMethodRoutingMock: GenericPaymentMethodRouting {

    // MARK: - presentPaymentAction

    var presentPaymentActionForCallsCount = 0
    var presentPaymentActionForCalled: Bool {
        presentPaymentActionForCallsCount > 0
    }

    var presentPaymentActionForReceivedAction: Action?
    var presentPaymentActionForReceivedInvocations: [Action] = []
    var presentPaymentActionForClosure: ((Action) async -> Void)?

    func presentPaymentAction(for action: Action) async {
        presentPaymentActionForCallsCount += 1
        presentPaymentActionForReceivedAction = action
        presentPaymentActionForReceivedInvocations.append(action)
        await presentPaymentActionForClosure?(action)
    }

    // MARK: - dismiss

    var dismissCallsCount = 0
    var dismissCalled: Bool {
        dismissCallsCount > 0
    }

    var dismissClosure: (() -> Void)?

    func dismiss() {
        dismissCallsCount += 1
        dismissClosure?()
    }

}

class PaymentActionAssemblerProtocolMock: PaymentActionAssemblerProtocol {

    // MARK: - resolvePaymentActionRouter

    var resolvePaymentActionRouterForListenerCallsCount = 0
    var resolvePaymentActionRouterForListenerCalled: Bool {
        resolvePaymentActionRouterForListenerCallsCount > 0
    }

    var resolvePaymentActionRouterForListenerReceivedArguments: (action: Action, listener: PaymentActionRouterListener)?
    var resolvePaymentActionRouterForListenerReceivedInvocations: [(action: Action, listener: PaymentActionRouterListener)] = []
    var resolvePaymentActionRouterForListenerReturnValue: Router?
    var resolvePaymentActionRouterForListenerClosure: ((Action, PaymentActionRouterListener) async -> Router?)?

    func resolvePaymentActionRouter(for action: Action, listener: PaymentActionRouterListener) async -> Router? {
        resolvePaymentActionRouterForListenerCallsCount += 1
        resolvePaymentActionRouterForListenerReceivedArguments = (action: action, listener: listener)
        resolvePaymentActionRouterForListenerReceivedInvocations.append((action: action, listener: listener))
        if let resolvePaymentActionRouterForListenerClosure {
            return await resolvePaymentActionRouterForListenerClosure(action, listener)
        } else {
            return resolvePaymentActionRouterForListenerReturnValue
        }
    }

}

class PaymentActionRouterListenerMock: PaymentActionRouterListener {

    // MARK: - didDismissPaymentAction

    var didDismissPaymentActionCompletionCallsCount = 0
    var didDismissPaymentActionCompletionCalled: Bool {
        didDismissPaymentActionCompletionCallsCount > 0
    }

    var didDismissPaymentActionCompletionClosure: (((() -> Void)?) -> Void)?

    func didDismissPaymentAction(completion: (() -> Void)?) {
        didDismissPaymentActionCompletionCallsCount += 1
        didDismissPaymentActionCompletionClosure?(completion)
    }

}

class PaymentActionRoutingMock: PaymentActionRouting {

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

class PaymentActionViewModelProtocolMock: PaymentActionViewModelProtocol {

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

class PaymentMethodListAssemblerProtocolMock: PaymentMethodListAssemblerProtocol {

    // MARK: - resolvePaymentMethodListRouter

    var resolvePaymentMethodListRouterDelegateCallsCount = 0
    var resolvePaymentMethodListRouterDelegateCalled: Bool {
        resolvePaymentMethodListRouterDelegateCallsCount > 0
    }

    var resolvePaymentMethodListRouterDelegateReceivedDelegate: PaymentMethodListRouterListener?
    var resolvePaymentMethodListRouterDelegateReceivedInvocations: [PaymentMethodListRouterListener?] = []
    var resolvePaymentMethodListRouterDelegateReturnValue: Router!
    var resolvePaymentMethodListRouterDelegateClosure: ((PaymentMethodListRouterListener?) -> Router)?

    func resolvePaymentMethodListRouter(delegate: PaymentMethodListRouterListener?) -> Router {
        resolvePaymentMethodListRouterDelegateCallsCount += 1
        resolvePaymentMethodListRouterDelegateReceivedDelegate = delegate
        resolvePaymentMethodListRouterDelegateReceivedInvocations.append(delegate)
        if let resolvePaymentMethodListRouterDelegateClosure {
            return resolvePaymentMethodListRouterDelegateClosure(delegate)
        } else {
            return resolvePaymentMethodListRouterDelegateReturnValue
        }
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

    var presentComponentCallsCount = 0
    var presentComponentCalled: Bool {
        presentComponentCallsCount > 0
    }

    var presentComponentReceivedComponent: PaymentComponent?
    var presentComponentReceivedInvocations: [PaymentComponent] = []
    var presentComponentClosure: ((PaymentComponent) -> Void)?

    func present(component: PaymentComponent) {
        presentComponentCallsCount += 1
        presentComponentReceivedComponent = component
        presentComponentReceivedInvocations.append(component)
        presentComponentClosure?(component)
    }

    // MARK: - present

    var presentViewControllerCallsCount = 0
    var presentViewControllerCalled: Bool {
        presentViewControllerCallsCount > 0
    }

    var presentViewControllerReceivedViewController: UIViewController?
    var presentViewControllerReceivedInvocations: [UIViewController] = []
    var presentViewControllerClosure: ((UIViewController) -> Void)?

    func present(viewController: UIViewController) {
        presentViewControllerCallsCount += 1
        presentViewControllerReceivedViewController = viewController
        presentViewControllerReceivedInvocations.append(viewController)
        presentViewControllerClosure?(viewController)
    }

    // MARK: - presentPaymentAction

    var presentPaymentActionForCallsCount = 0
    var presentPaymentActionForCalled: Bool {
        presentPaymentActionForCallsCount > 0
    }

    var presentPaymentActionForReceivedAction: Action?
    var presentPaymentActionForReceivedInvocations: [Action] = []
    var presentPaymentActionForClosure: ((Action) async -> Void)?

    func presentPaymentAction(for action: Action) async {
        presentPaymentActionForCallsCount += 1
        presentPaymentActionForReceivedAction = action
        presentPaymentActionForReceivedInvocations.append(action)
        await presentPaymentActionForClosure?(action)
    }

    // MARK: - presentStoredPaymentMethodManagement

    var presentStoredPaymentMethodManagementCallsCount = 0
    var presentStoredPaymentMethodManagementCalled: Bool {
        presentStoredPaymentMethodManagementCallsCount > 0
    }

    var presentStoredPaymentMethodManagementClosure: (() -> Void)?

    func presentStoredPaymentMethodManagement() {
        presentStoredPaymentMethodManagementCallsCount += 1
        presentStoredPaymentMethodManagementClosure?()
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

    var context: AdyenContext {
        get { underlyingContext }
        set(value) { underlyingContext = value }
    }

    var underlyingContext: AdyenContext!
    var title: String {
        get { underlyingTitle }
        set(value) { underlyingTitle = value }
    }

    var underlyingTitle: String!
    var paymentMethodSections: [PaymentMethodsSection] = []
    var statePublisher: Published<PaymentMethodListState>.Publisher {
        get { underlyingStatePublisher }
        set(value) { underlyingStatePublisher = value }
    }

    var underlyingStatePublisher: Published<PaymentMethodListState>.Publisher!
    var theme: CheckoutTheme {
        get { underlyingTheme }
        set(value) { underlyingTheme = value }
    }

    var underlyingTheme: CheckoutTheme!
    var headerTitle: String {
        get { underlyingHeaderTitle }
        set(value) { underlyingHeaderTitle = value }
    }

    var underlyingHeaderTitle: String!
    var subtitle: String {
        get { underlyingSubtitle }
        set(value) { underlyingSubtitle = value }
    }

    var underlyingSubtitle: String!
    var applePayButtonState: PaymentMethodListHeaderViewModel.ApplePayButtonState {
        get { underlyingApplePayButtonState }
        set(value) { underlyingApplePayButtonState = value }
    }

    var underlyingApplePayButtonState: PaymentMethodListHeaderViewModel.ApplePayButtonState!

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

    // MARK: - didLoad

    var didLoadCallsCount = 0
    var didLoadCalled: Bool {
        didLoadCallsCount > 0
    }

    var didLoadClosure: (() -> Void)?

    func didLoad() {
        didLoadCallsCount += 1
        didLoadClosure?()
    }

}

class PreselectedPaymentMethodAssemblerProtocolMock: PreselectedPaymentMethodAssemblerProtocol {

    // MARK: - resolvePreselectedPaymentMethodRouter

    var resolvePreselectedPaymentMethodRouterDelegateComponentTitleCallsCount = 0
    var resolvePreselectedPaymentMethodRouterDelegateComponentTitleCalled: Bool {
        resolvePreselectedPaymentMethodRouterDelegateComponentTitleCallsCount > 0
    }

    var resolvePreselectedPaymentMethodRouterDelegateComponentTitleReceivedArguments: (delegate: PreselectedPaymentMethodRouterListener?, component: PaymentComponent, title: String)?
    var resolvePreselectedPaymentMethodRouterDelegateComponentTitleReceivedInvocations: [(delegate: PreselectedPaymentMethodRouterListener?, component: PaymentComponent, title: String)] = []
    var resolvePreselectedPaymentMethodRouterDelegateComponentTitleReturnValue: Router!
    var resolvePreselectedPaymentMethodRouterDelegateComponentTitleClosure: ((PreselectedPaymentMethodRouterListener?, PaymentComponent, String) -> Router)?

    func resolvePreselectedPaymentMethodRouter(delegate: PreselectedPaymentMethodRouterListener?, component: PaymentComponent, title: String) -> Router {
        resolvePreselectedPaymentMethodRouterDelegateComponentTitleCallsCount += 1
        resolvePreselectedPaymentMethodRouterDelegateComponentTitleReceivedArguments = (delegate: delegate, component: component, title: title)
        resolvePreselectedPaymentMethodRouterDelegateComponentTitleReceivedInvocations.append((delegate: delegate, component: component, title: title))
        if let resolvePreselectedPaymentMethodRouterDelegateComponentTitleClosure {
            return resolvePreselectedPaymentMethodRouterDelegateComponentTitleClosure(delegate, component, title)
        } else {
            return resolvePreselectedPaymentMethodRouterDelegateComponentTitleReturnValue
        }
    }

}

class PreselectedPaymentMethodRoutingMock: PreselectedPaymentMethodRouting {

    // MARK: - presentPaymentMethodList

    var presentPaymentMethodListCallsCount = 0
    var presentPaymentMethodListCalled: Bool {
        presentPaymentMethodListCallsCount > 0
    }

    var presentPaymentMethodListClosure: (() -> Void)?

    func presentPaymentMethodList() {
        presentPaymentMethodListCallsCount += 1
        presentPaymentMethodListClosure?()
    }

    // MARK: - present

    var presentComponentCallsCount = 0
    var presentComponentCalled: Bool {
        presentComponentCallsCount > 0
    }

    var presentComponentReceivedComponent: PaymentComponent?
    var presentComponentReceivedInvocations: [PaymentComponent] = []
    var presentComponentClosure: ((PaymentComponent) -> Void)?

    func present(component: PaymentComponent) {
        presentComponentCallsCount += 1
        presentComponentReceivedComponent = component
        presentComponentReceivedInvocations.append(component)
        presentComponentClosure?(component)
    }

    // MARK: - presentPaymentAction

    var presentPaymentActionForCallsCount = 0
    var presentPaymentActionForCalled: Bool {
        presentPaymentActionForCallsCount > 0
    }

    var presentPaymentActionForReceivedAction: Action?
    var presentPaymentActionForReceivedInvocations: [Action] = []
    var presentPaymentActionForClosure: ((Action) async -> Void)?

    func presentPaymentAction(for action: Action) async {
        presentPaymentActionForCallsCount += 1
        presentPaymentActionForReceivedAction = action
        presentPaymentActionForReceivedInvocations.append(action)
        await presentPaymentActionForClosure?(action)
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

class StoredCardInputViewModelProtocolMock: StoredCardInputViewModelProtocol {

    var cardImageItem: CardImageItem {
        get { underlyingCardImageItem }
        set(value) { underlyingCardImageItem = value }
    }

    var underlyingCardImageItem: CardImageItem!
    var titleText: String {
        get { underlyingTitleText }
        set(value) { underlyingTitleText = value }
    }

    var underlyingTitleText: String!
    var subtitleText: NSAttributedString {
        get { underlyingSubtitleText }
        set(value) { underlyingSubtitleText = value }
    }

    var underlyingSubtitleText: NSAttributedString!
    var securityCodeItem: FormCardSecurityCodeItem {
        get { underlyingSecurityCodeItem }
        set(value) { underlyingSecurityCodeItem = value }
    }

    var underlyingSecurityCodeItem: FormCardSecurityCodeItem!
    var submitButtonTitle: String {
        get { underlyingSubmitButtonTitle }
        set(value) { underlyingSubmitButtonTitle = value }
    }

    var underlyingSubmitButtonTitle: String!
    var theme: CheckoutTheme {
        get { underlyingTheme }
        set(value) { underlyingTheme = value }
    }

    var underlyingTheme: CheckoutTheme!
    var onSecurityCodeValidationRequested: VoidCompletion?
    var inProgressPublisher: Published<Bool>.Publisher {
        get { underlyingInProgressPublisher }
        set(value) { underlyingInProgressPublisher = value }
    }

    var underlyingInProgressPublisher: Published<Bool>.Publisher!

    // MARK: - submit

    var submitCallsCount = 0
    var submitCalled: Bool {
        submitCallsCount > 0
    }

    var submitClosure: (() async -> Void)?

    @MainActor
    func submit() async {
        submitCallsCount += 1
        await submitClosure?()
    }

    // MARK: - viewDidDisappear

    var viewDidDisappearCallsCount = 0
    var viewDidDisappearCalled: Bool {
        viewDidDisappearCallsCount > 0
    }

    var viewDidDisappearClosure: (() -> Void)?

    @MainActor
    func viewDidDisappear() {
        viewDidDisappearCallsCount += 1
        viewDidDisappearClosure?()
    }

    // MARK: - viewDidLoad

    var viewDidLoadCallsCount = 0
    var viewDidLoadCalled: Bool {
        viewDidLoadCallsCount > 0
    }

    var viewDidLoadClosure: (() -> Void)?

    func viewDidLoad() {
        viewDidLoadCallsCount += 1
        viewDidLoadClosure?()
    }

}
