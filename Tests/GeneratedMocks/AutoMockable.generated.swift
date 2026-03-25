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

package class AnyEventAnalyticsProviderMock: AnyEventAnalyticsProvider {

    // MARK: - add

    package var addInfoCallsCount = 0
    package var addInfoCalled: Bool {
        addInfoCallsCount > 0
    }

    package var addInfoReceivedInfo: AnalyticsEventInfo?
    package var addInfoReceivedInvocations: [AnalyticsEventInfo] = []
    package var addInfoClosure: ((AnalyticsEventInfo) -> Void)?

    package func add(info: AnalyticsEventInfo) {
        addInfoCallsCount += 1
        addInfoReceivedInfo = info
        addInfoReceivedInvocations.append(info)
        addInfoClosure?(info)
    }

    // MARK: - add

    package var addLogCallsCount = 0
    package var addLogCalled: Bool {
        addLogCallsCount > 0
    }

    package var addLogReceivedLog: AnalyticsEventLog?
    package var addLogReceivedInvocations: [AnalyticsEventLog] = []
    package var addLogClosure: ((AnalyticsEventLog) -> Void)?

    package func add(log: AnalyticsEventLog) {
        addLogCallsCount += 1
        addLogReceivedLog = log
        addLogReceivedInvocations.append(log)
        addLogClosure?(log)
    }

    // MARK: - add

    package var addErrorCallsCount = 0
    package var addErrorCalled: Bool {
        addErrorCallsCount > 0
    }

    package var addErrorReceivedError: AnalyticsEventError?
    package var addErrorReceivedInvocations: [AnalyticsEventError] = []
    package var addErrorClosure: ((AnalyticsEventError) -> Void)?

    package func add(error: AnalyticsEventError) {
        addErrorCallsCount += 1
        addErrorReceivedError = error
        addErrorReceivedInvocations.append(error)
        addErrorClosure?(error)
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

    var presentComponentOnCancelCallsCount = 0
    var presentComponentOnCancelCalled: Bool {
        presentComponentOnCancelCallsCount > 0
    }

    var presentComponentOnCancelReceivedArguments: (component: PaymentComponent, onCancel: () -> Void)?
    var presentComponentOnCancelReceivedInvocations: [(component: PaymentComponent, onCancel: () -> Void)] = []
    var presentComponentOnCancelClosure: ((PaymentComponent, @escaping () -> Void) -> Void)?

    func present(component: PaymentComponent, onCancel: @escaping () -> Void) {
        presentComponentOnCancelCallsCount += 1
        presentComponentOnCancelReceivedArguments = (component: component, onCancel: onCancel)
        presentComponentOnCancelReceivedInvocations.append((component: component, onCancel: onCancel))
        presentComponentOnCancelClosure?(component, onCancel)
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

    // MARK: - listItemIdentifier

    var listItemIdentifierForCallsCount = 0
    var listItemIdentifierForCalled: Bool {
        listItemIdentifierForCallsCount > 0
    }

    var listItemIdentifierForReceivedPaymentMethod: PaymentMethod?
    var listItemIdentifierForReceivedInvocations: [PaymentMethod] = []
    var listItemIdentifierForReturnValue: String!
    var listItemIdentifierForClosure: ((PaymentMethod) -> String)?

    func listItemIdentifier(for paymentMethod: PaymentMethod) -> String {
        listItemIdentifierForCallsCount += 1
        listItemIdentifierForReceivedPaymentMethod = paymentMethod
        listItemIdentifierForReceivedInvocations.append(paymentMethod)
        if let listItemIdentifierForClosure {
            return listItemIdentifierForClosure(paymentMethod)
        } else {
            return listItemIdentifierForReturnValue
        }
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

    var presentComponentOnCancelCallsCount = 0
    var presentComponentOnCancelCalled: Bool {
        presentComponentOnCancelCallsCount > 0
    }

    var presentComponentOnCancelReceivedArguments: (component: PaymentComponent, onCancel: () -> Void)?
    var presentComponentOnCancelReceivedInvocations: [(component: PaymentComponent, onCancel: () -> Void)] = []
    var presentComponentOnCancelClosure: ((PaymentComponent, @escaping () -> Void) -> Void)?

    func present(component: PaymentComponent, onCancel: @escaping () -> Void) {
        presentComponentOnCancelCallsCount += 1
        presentComponentOnCancelReceivedArguments = (component: component, onCancel: onCancel)
        presentComponentOnCancelReceivedInvocations.append((component: component, onCancel: onCancel))
        presentComponentOnCancelClosure?(component, onCancel)
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

class RouterMock: Router {

    var childRouter: Router?
    var rootViewController: UIViewController {
        get { underlyingRootViewController }
        set(value) { underlyingRootViewController = value }
    }

    var underlyingRootViewController: UIViewController!

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
    var theme: AdyenTheme {
        get { underlyingTheme }
        set(value) { underlyingTheme = value }
    }

    var underlyingTheme: AdyenTheme!
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

    // MARK: - dismiss

    var dismissCallsCount = 0
    var dismissCalled: Bool {
        dismissCallsCount > 0
    }

    var dismissClosure: (() -> Void)?

    @MainActor
    func dismiss() {
        dismissCallsCount += 1
        dismissClosure?()
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
