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
@testable import AdyenComponents
@testable import AdyenDropIn
@testable import AdyenUI

@MainActor
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

@MainActor
package class BACSDirectDebitComponentTrackerProtocolMock: BACSDirectDebitComponentTrackerProtocol {

    // MARK: - sendInitialAnalytics

    package var sendInitialAnalyticsCallsCount = 0
    package var sendInitialAnalyticsCalled: Bool {
        sendInitialAnalyticsCallsCount > 0
    }

    package var sendInitialAnalyticsClosure: (() -> Void)?

    package func sendInitialAnalytics() {
        sendInitialAnalyticsCallsCount += 1
        sendInitialAnalyticsClosure?()
    }

    // MARK: - sendDidLoadEvent

    package var sendDidLoadEventCallsCount = 0
    package var sendDidLoadEventCalled: Bool {
        sendDidLoadEventCallsCount > 0
    }

    package var sendDidLoadEventClosure: (() -> Void)?

    package func sendDidLoadEvent() {
        sendDidLoadEventCallsCount += 1
        sendDidLoadEventClosure?()
    }

}

@MainActor
class ComponentContainerRouterListenerMock: ComponentContainerRouterListener {

    // MARK: - didDismissComponentContainer

    var didDismissComponentContainerCompletionCallsCount = 0
    var didDismissComponentContainerCompletionCalled: Bool {
        didDismissComponentContainerCompletionCallsCount > 0
    }

    var didDismissComponentContainerCompletionClosure: (((@MainActor @Sendable () -> Void)?) -> Void)?

    func didDismissComponentContainer(completion: (@MainActor @Sendable () -> Void)?) {
        didDismissComponentContainerCompletionCallsCount += 1
        didDismissComponentContainerCompletionClosure?(completion)
    }

}

@MainActor
class ComponentContainerRoutingMock: ComponentContainerRouting {

    var childRouter: Router?
    var rootViewController: UIViewController {
        get { underlyingRootViewController }
        set(value) { underlyingRootViewController = value }
    }

    var underlyingRootViewController: UIViewController!

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

    // MARK: - dismiss

    var dismissCompletionCallsCount = 0
    var dismissCompletionCalled: Bool {
        dismissCompletionCallsCount > 0
    }

    var dismissCompletionClosure: (((@MainActor @Sendable () -> Void)?) -> Void)?

    func dismiss(completion: (@MainActor @Sendable () -> Void)?) {
        dismissCompletionCallsCount += 1
        dismissCompletionClosure?(completion)
    }

}

@MainActor
class DropInDismissingMock: DropInDismissing {

    // MARK: - dismissDropIn

    var dismissDropInCompletionCallsCount = 0
    var dismissDropInCompletionCalled: Bool {
        dismissDropInCompletionCallsCount > 0
    }

    var dismissDropInCompletionClosure: (((@MainActor @Sendable () -> Void)?) -> Void)?

    func dismissDropIn(completion: (@MainActor @Sendable () -> Void)?) {
        dismissDropInCompletionCallsCount += 1
        dismissDropInCompletionClosure?(completion)
    }

}

@MainActor
class DropInFlowRoutingMock: DropInFlowRouting {

    // MARK: - dismissDropIn

    var dismissDropInCompletionCallsCount = 0
    var dismissDropInCompletionCalled: Bool {
        dismissDropInCompletionCallsCount > 0
    }

    var dismissDropInCompletionClosure: (((@MainActor @Sendable () -> Void)?) -> Void)?

    func dismissDropIn(completion: (@MainActor @Sendable () -> Void)?) {
        dismissDropInCompletionCallsCount += 1
        dismissDropInCompletionClosure?(completion)
    }

    // MARK: - present

    var presentPaymentActionRouterCallsCount = 0
    var presentPaymentActionRouterCalled: Bool {
        presentPaymentActionRouterCallsCount > 0
    }

    var presentPaymentActionRouterReceivedPaymentActionRouter: Router?
    var presentPaymentActionRouterReceivedInvocations: [Router] = []
    var presentPaymentActionRouterClosure: ((Router) -> Void)?

    func present(paymentActionRouter: Router) {
        presentPaymentActionRouterCallsCount += 1
        presentPaymentActionRouterReceivedPaymentActionRouter = paymentActionRouter
        presentPaymentActionRouterReceivedInvocations.append(paymentActionRouter)
        presentPaymentActionRouterClosure?(paymentActionRouter)
    }

    // MARK: - didDismissPaymentAction

    var didDismissPaymentActionCompletionCallsCount = 0
    var didDismissPaymentActionCompletionCalled: Bool {
        didDismissPaymentActionCompletionCallsCount > 0
    }

    var didDismissPaymentActionCompletionClosure: (((@MainActor @Sendable () -> Void)?) -> Void)?

    func didDismissPaymentAction(completion: (@MainActor @Sendable () -> Void)?) {
        didDismissPaymentActionCompletionCallsCount += 1
        didDismissPaymentActionCompletionClosure?(completion)
    }

}

@MainActor
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

@MainActor
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

@MainActor
class GenericPaymentMethodRoutingMock: GenericPaymentMethodRouting {

    var childRouter: Router?
    var rootViewController: UIViewController {
        get { underlyingRootViewController }
        set(value) { underlyingRootViewController = value }
    }

    var underlyingRootViewController: UIViewController!

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

@MainActor
class PaymentActionAssemblerProtocolMock: PaymentActionAssemblerProtocol {

    // MARK: - resolvePaymentActionRouter

    var resolvePaymentActionRouterForListenerOnCancelCallsCount = 0
    var resolvePaymentActionRouterForListenerOnCancelCalled: Bool {
        resolvePaymentActionRouterForListenerOnCancelCallsCount > 0
    }

    var resolvePaymentActionRouterForListenerOnCancelReceivedArguments: (actionViewController: UIViewController, listener: PaymentActionRouterListener, onCancel: () -> Void)?
    var resolvePaymentActionRouterForListenerOnCancelReceivedInvocations: [(actionViewController: UIViewController, listener: PaymentActionRouterListener, onCancel: () -> Void)] = []
    var resolvePaymentActionRouterForListenerOnCancelReturnValue: Router!
    var resolvePaymentActionRouterForListenerOnCancelClosure: ((UIViewController, PaymentActionRouterListener, @MainActor @Sendable @escaping () -> Void) -> Router)?

    func resolvePaymentActionRouter(for actionViewController: UIViewController, listener: PaymentActionRouterListener, onCancel: @MainActor @Sendable @escaping () -> Void) -> Router {
        resolvePaymentActionRouterForListenerOnCancelCallsCount += 1
        resolvePaymentActionRouterForListenerOnCancelReceivedArguments = (actionViewController: actionViewController, listener: listener, onCancel: onCancel)
        resolvePaymentActionRouterForListenerOnCancelReceivedInvocations.append((actionViewController: actionViewController, listener: listener, onCancel: onCancel))
        if let resolvePaymentActionRouterForListenerOnCancelClosure {
            return resolvePaymentActionRouterForListenerOnCancelClosure(actionViewController, listener, onCancel)
        } else {
            return resolvePaymentActionRouterForListenerOnCancelReturnValue
        }
    }

}

@MainActor
class PaymentActionPresentingMock: PaymentActionPresenting {

    // MARK: - present

    var presentPaymentActionRouterCallsCount = 0
    var presentPaymentActionRouterCalled: Bool {
        presentPaymentActionRouterCallsCount > 0
    }

    var presentPaymentActionRouterReceivedPaymentActionRouter: Router?
    var presentPaymentActionRouterReceivedInvocations: [Router] = []
    var presentPaymentActionRouterClosure: ((Router) -> Void)?

    func present(paymentActionRouter: Router) {
        presentPaymentActionRouterCallsCount += 1
        presentPaymentActionRouterReceivedPaymentActionRouter = paymentActionRouter
        presentPaymentActionRouterReceivedInvocations.append(paymentActionRouter)
        presentPaymentActionRouterClosure?(paymentActionRouter)
    }

    // MARK: - didDismissPaymentAction

    var didDismissPaymentActionCompletionCallsCount = 0
    var didDismissPaymentActionCompletionCalled: Bool {
        didDismissPaymentActionCompletionCallsCount > 0
    }

    var didDismissPaymentActionCompletionClosure: (((@MainActor @Sendable () -> Void)?) -> Void)?

    func didDismissPaymentAction(completion: (@MainActor @Sendable () -> Void)?) {
        didDismissPaymentActionCompletionCallsCount += 1
        didDismissPaymentActionCompletionClosure?(completion)
    }

}

@MainActor
class PaymentActionRouterListenerMock: PaymentActionRouterListener {

    // MARK: - didDismissPaymentAction

    var didDismissPaymentActionCompletionCallsCount = 0
    var didDismissPaymentActionCompletionCalled: Bool {
        didDismissPaymentActionCompletionCallsCount > 0
    }

    var didDismissPaymentActionCompletionClosure: (((@MainActor @Sendable () -> Void)?) -> Void)?

    func didDismissPaymentAction(completion: (@MainActor @Sendable () -> Void)?) {
        didDismissPaymentActionCompletionCallsCount += 1
        didDismissPaymentActionCompletionClosure?(completion)
    }

}

@MainActor
class PaymentActionRoutingMock: PaymentActionRouting {

    // MARK: - dismiss

    var dismissCompletionCallsCount = 0
    var dismissCompletionCalled: Bool {
        dismissCompletionCallsCount > 0
    }

    var dismissCompletionClosure: (((@MainActor @Sendable () -> Void)?) -> Void)?

    func dismiss(completion: (@MainActor @Sendable () -> Void)?) {
        dismissCompletionCallsCount += 1
        dismissCompletionClosure?(completion)
    }

}

@MainActor
class PaymentActionViewModelProtocolMock: PaymentActionViewModelProtocol {

    var theme: CheckoutTheme {
        get { underlyingTheme }
        set(value) { underlyingTheme = value }
    }

    var underlyingTheme: CheckoutTheme!

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

@MainActor
class PaymentMethodListAssemblerProtocolMock: PaymentMethodListAssemblerProtocol {

    // MARK: - resolvePaymentMethodListRouter

    var resolvePaymentMethodListRouterListenerCallsCount = 0
    var resolvePaymentMethodListRouterListenerCalled: Bool {
        resolvePaymentMethodListRouterListenerCallsCount > 0
    }

    var resolvePaymentMethodListRouterListenerReceivedListener: PaymentMethodListRouterListener?
    var resolvePaymentMethodListRouterListenerReceivedInvocations: [PaymentMethodListRouterListener?] = []
    var resolvePaymentMethodListRouterListenerReturnValue: Router!
    var resolvePaymentMethodListRouterListenerClosure: ((PaymentMethodListRouterListener?) -> Router)?

    func resolvePaymentMethodListRouter(listener: PaymentMethodListRouterListener?) -> Router {
        resolvePaymentMethodListRouterListenerCallsCount += 1
        resolvePaymentMethodListRouterListenerReceivedListener = listener
        resolvePaymentMethodListRouterListenerReceivedInvocations.append(listener)
        if let resolvePaymentMethodListRouterListenerClosure {
            return resolvePaymentMethodListRouterListenerClosure(listener)
        } else {
            return resolvePaymentMethodListRouterListenerReturnValue
        }
    }

}

@MainActor
class PaymentMethodListRouterListenerMock: PaymentMethodListRouterListener {

    // MARK: - didDismissPaymentMethodList

    var didDismissPaymentMethodListCompletionCallsCount = 0
    var didDismissPaymentMethodListCompletionCalled: Bool {
        didDismissPaymentMethodListCompletionCallsCount > 0
    }

    var didDismissPaymentMethodListCompletionClosure: (((@MainActor @Sendable () -> Void)?) -> Void)?

    func didDismissPaymentMethodList(completion: (@MainActor @Sendable () -> Void)?) {
        didDismissPaymentMethodListCompletionCallsCount += 1
        didDismissPaymentMethodListCompletionClosure?(completion)
    }

}

@MainActor
class PaymentMethodListRoutingMock: PaymentMethodListRouting {

    var childRouter: Router?
    var rootViewController: UIViewController {
        get { underlyingRootViewController }
        set(value) { underlyingRootViewController = value }
    }

    var underlyingRootViewController: UIViewController!

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

    var dismissCompletionClosure: (((@MainActor @Sendable () -> Void)?) -> Void)?

    func dismiss(completion: (@MainActor @Sendable () -> Void)?) {
        dismissCompletionCallsCount += 1
        dismissCompletionClosure?(completion)
    }

}

@MainActor
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
    var applePayViewController: UIViewController?

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

@MainActor
class PreselectedPaymentMethodAssemblerProtocolMock: PreselectedPaymentMethodAssemblerProtocol {

    // MARK: - resolvePreselectedPaymentMethodRouter

    var resolvePreselectedPaymentMethodRouterListenerComponentTitleCallsCount = 0
    var resolvePreselectedPaymentMethodRouterListenerComponentTitleCalled: Bool {
        resolvePreselectedPaymentMethodRouterListenerComponentTitleCallsCount > 0
    }

    var resolvePreselectedPaymentMethodRouterListenerComponentTitleReceivedArguments: (listener: PreselectedPaymentMethodRouterListener?, component: PaymentComponent, title: String)?
    var resolvePreselectedPaymentMethodRouterListenerComponentTitleReceivedInvocations: [(listener: PreselectedPaymentMethodRouterListener?, component: PaymentComponent, title: String)] = []
    var resolvePreselectedPaymentMethodRouterListenerComponentTitleReturnValue: Router!
    var resolvePreselectedPaymentMethodRouterListenerComponentTitleClosure: ((PreselectedPaymentMethodRouterListener?, PaymentComponent, String) -> Router)?

    func resolvePreselectedPaymentMethodRouter(listener: PreselectedPaymentMethodRouterListener?, component: PaymentComponent, title: String) -> Router {
        resolvePreselectedPaymentMethodRouterListenerComponentTitleCallsCount += 1
        resolvePreselectedPaymentMethodRouterListenerComponentTitleReceivedArguments = (listener: listener, component: component, title: title)
        resolvePreselectedPaymentMethodRouterListenerComponentTitleReceivedInvocations.append((listener: listener, component: component, title: title))
        if let resolvePreselectedPaymentMethodRouterListenerComponentTitleClosure {
            return resolvePreselectedPaymentMethodRouterListenerComponentTitleClosure(listener, component, title)
        } else {
            return resolvePreselectedPaymentMethodRouterListenerComponentTitleReturnValue
        }
    }

}

@MainActor
class PreselectedPaymentMethodRouterListenerMock: PreselectedPaymentMethodRouterListener {

    // MARK: - didDismissPreselectedPaymentMethod

    var didDismissPreselectedPaymentMethodCompletionCallsCount = 0
    var didDismissPreselectedPaymentMethodCompletionCalled: Bool {
        didDismissPreselectedPaymentMethodCompletionCallsCount > 0
    }

    var didDismissPreselectedPaymentMethodCompletionClosure: (((@MainActor @Sendable () -> Void)?) -> Void)?

    func didDismissPreselectedPaymentMethod(completion: (@MainActor @Sendable () -> Void)?) {
        didDismissPreselectedPaymentMethodCompletionCallsCount += 1
        didDismissPreselectedPaymentMethodCompletionClosure?(completion)
    }

}

@MainActor
class PreselectedPaymentMethodRoutingMock: PreselectedPaymentMethodRouting {

    var childRouter: Router?
    var rootViewController: UIViewController {
        get { underlyingRootViewController }
        set(value) { underlyingRootViewController = value }
    }

    var underlyingRootViewController: UIViewController!

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

    // MARK: - dismiss

    var dismissCompletionCallsCount = 0
    var dismissCompletionCalled: Bool {
        dismissCompletionCallsCount > 0
    }

    var dismissCompletionClosure: (((@MainActor @Sendable () -> Void)?) -> Void)?

    func dismiss(completion: (@MainActor @Sendable () -> Void)?) {
        dismissCompletionCallsCount += 1
        dismissCompletionClosure?(completion)
    }

}

@MainActor
class StoredCardInputViewModelProtocolMock: StoredCardInputViewModelProtocol {

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
