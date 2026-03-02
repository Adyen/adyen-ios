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
@testable import AdyenCheckout
@testable import AdyenDropIn






















class ActionPresenterMock: ActionPresenter {




    //MARK: - present

    var presentActionComponentCallsCount = 0
    var presentActionComponentCalled: Bool {
        return presentActionComponentCallsCount > 0
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

    //MARK: - didCancel

    var didCancelActionComponentCallsCount = 0
    var didCancelActionComponentCalled: Bool {
        return didCancelActionComponentCallsCount > 0
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




    //MARK: - resolveComponentContainerRouter

    var resolveComponentContainerRouterForDelegateOnCancelCallsCount = 0
    var resolveComponentContainerRouterForDelegateOnCancelCalled: Bool {
        return resolveComponentContainerRouterForDelegateOnCancelCallsCount > 0
    }
    var resolveComponentContainerRouterForDelegateOnCancelReturnValue: Router!
    var resolveComponentContainerRouterForDelegateOnCancelClosure: ((PresentableComponent, ComponentContainerRouterListener, (() -> Void)?) -> Router)?

    func resolveComponentContainerRouter(for component: PresentableComponent, delegate: ComponentContainerRouterListener, onCancel: (() -> Void)?) -> Router {
        resolveComponentContainerRouterForDelegateOnCancelCallsCount += 1
        if let resolveComponentContainerRouterForDelegateOnCancelClosure = resolveComponentContainerRouterForDelegateOnCancelClosure {
            return resolveComponentContainerRouterForDelegateOnCancelClosure(component, delegate, onCancel)
        } else {
            return resolveComponentContainerRouterForDelegateOnCancelReturnValue
        }
    }

}
class ComponentContainerRouterListenerMock: ComponentContainerRouterListener {




    //MARK: - didDismissComponentContainer

    var didDismissComponentContainerCompletionCallsCount = 0
    var didDismissComponentContainerCompletionCalled: Bool {
        return didDismissComponentContainerCompletionCallsCount > 0
    }
    var didDismissComponentContainerCompletionClosure: (((() -> Void)?) -> Void)?

    func didDismissComponentContainer(completion: (() -> Void)?) {
        didDismissComponentContainerCompletionCallsCount += 1
        didDismissComponentContainerCompletionClosure?(completion)
    }

}
class ComponentContainerRoutingMock: ComponentContainerRouting {




    //MARK: - present

    var presentPaymentComponentCallsCount = 0
    var presentPaymentComponentCalled: Bool {
        return presentPaymentComponentCallsCount > 0
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

    //MARK: - present

    var presentActionComponentOnCancelCallsCount = 0
    var presentActionComponentOnCancelCalled: Bool {
        return presentActionComponentOnCancelCallsCount > 0
    }
    var presentActionComponentOnCancelClosure: ((PresentableComponent, (() -> Void)?) -> Void)?

    func present(actionComponent: PresentableComponent, onCancel: (() -> Void)?) {
        presentActionComponentOnCancelCallsCount += 1
        presentActionComponentOnCancelClosure?(actionComponent, onCancel)
    }

    //MARK: - dismiss

    var dismissCompletionCallsCount = 0
    var dismissCompletionCalled: Bool {
        return dismissCompletionCallsCount > 0
    }
    var dismissCompletionClosure: (((() -> Void)?) -> Void)?

    func dismiss(completion: (() -> Void)?) {
        dismissCompletionCallsCount += 1
        dismissCompletionClosure?(completion)
    }

}
class ComponentContainerViewModelProtocolMock: ComponentContainerViewModelProtocol {


    var componentViewController: UIViewController {
        get { return underlyingComponentViewController }
        set(value) { underlyingComponentViewController = value }
    }
    var underlyingComponentViewController: UIViewController!


    //MARK: - cancel

    var cancelCallsCount = 0
    var cancelCalled: Bool {
        return cancelCallsCount > 0
    }
    var cancelClosure: (() -> Void)?

    func cancel() {
        cancelCallsCount += 1
        cancelClosure?()
    }

}
class DropInFlowManagingMock: DropInFlowManaging {




    //MARK: - submit

    var submitFromActionPresenterCallsCount = 0
    var submitFromActionPresenterCalled: Bool {
        return submitFromActionPresenterCallsCount > 0
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

    //MARK: - fail

    var failWithFromCallsCount = 0
    var failWithFromCalled: Bool {
        return failWithFromCallsCount > 0
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

    //MARK: - cancel

    var cancelComponentCallsCount = 0
    var cancelComponentCalled: Bool {
        return cancelComponentCallsCount > 0
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

    //MARK: - handle

    var handleActionCallsCount = 0
    var handleActionCalled: Bool {
        return handleActionCallsCount > 0
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




    //MARK: - resolvePaymentMethodListRouter

    var resolvePaymentMethodListRouterDelegateCallsCount = 0
    var resolvePaymentMethodListRouterDelegateCalled: Bool {
        return resolvePaymentMethodListRouterDelegateCallsCount > 0
    }
    var resolvePaymentMethodListRouterDelegateReceivedDelegate: PaymentMethodListRouterListener?
    var resolvePaymentMethodListRouterDelegateReceivedInvocations: [PaymentMethodListRouterListener?] = []
    var resolvePaymentMethodListRouterDelegateReturnValue: Router!
    var resolvePaymentMethodListRouterDelegateClosure: ((PaymentMethodListRouterListener?) -> Router)?

    func resolvePaymentMethodListRouter(delegate: PaymentMethodListRouterListener?) -> Router {
        resolvePaymentMethodListRouterDelegateCallsCount += 1
        resolvePaymentMethodListRouterDelegateReceivedDelegate = delegate
        resolvePaymentMethodListRouterDelegateReceivedInvocations.append(delegate)
        if let resolvePaymentMethodListRouterDelegateClosure = resolvePaymentMethodListRouterDelegateClosure {
            return resolvePaymentMethodListRouterDelegateClosure(delegate)
        } else {
            return resolvePaymentMethodListRouterDelegateReturnValue
        }
    }

}
class PaymentMethodListRouterListenerMock: PaymentMethodListRouterListener {




    //MARK: - didDismissPaymentMethodList

    var didDismissPaymentMethodListCompletionCallsCount = 0
    var didDismissPaymentMethodListCompletionCalled: Bool {
        return didDismissPaymentMethodListCompletionCallsCount > 0
    }
    var didDismissPaymentMethodListCompletionClosure: (((() -> Void)?) -> Void)?

    func didDismissPaymentMethodList(completion: (() -> Void)?) {
        didDismissPaymentMethodListCompletionCallsCount += 1
        didDismissPaymentMethodListCompletionClosure?(completion)
    }

}
class PaymentMethodListRoutingMock: PaymentMethodListRouting {




    //MARK: - present

    var presentComponentOnCancelCallsCount = 0
    var presentComponentOnCancelCalled: Bool {
        return presentComponentOnCancelCallsCount > 0
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

    //MARK: - present

    var presentActionComponentOnCancelCallsCount = 0
    var presentActionComponentOnCancelCalled: Bool {
        return presentActionComponentOnCancelCallsCount > 0
    }
    var presentActionComponentOnCancelClosure: ((any PresentableComponent, (() -> Void)?) -> Void)?

    func present(actionComponent: any PresentableComponent, onCancel: (() -> Void)?) {
        presentActionComponentOnCancelCallsCount += 1
        presentActionComponentOnCancelClosure?(actionComponent, onCancel)
    }

    //MARK: - dismiss

    var dismissCompletionCallsCount = 0
    var dismissCompletionCalled: Bool {
        return dismissCompletionCallsCount > 0
    }
    var dismissCompletionClosure: (((() -> Void)?) -> Void)?

    func dismiss(completion: (() -> Void)?) {
        dismissCompletionCallsCount += 1
        dismissCompletionClosure?(completion)
    }

}
class PaymentMethodListViewModelProtocolMock: PaymentMethodListViewModelProtocol {


    var context: AdyenContext {
        get { return underlyingContext }
        set(value) { underlyingContext = value }
    }
    var underlyingContext: AdyenContext!
    var title: String {
        get { return underlyingTitle }
        set(value) { underlyingTitle = value }
    }
    var underlyingTitle: String!
    var paymentMethodSections: [PaymentMethodsSection] = []
    var statePublisher: Published<PaymentMethodListState>.Publisher {
        get { return underlyingStatePublisher }
        set(value) { underlyingStatePublisher = value }
    }
    var underlyingStatePublisher: Published<PaymentMethodListState>.Publisher!


    //MARK: - cancel

    var cancelCallsCount = 0
    var cancelCalled: Bool {
        return cancelCallsCount > 0
    }
    var cancelClosure: (() -> Void)?

    func cancel() {
        cancelCallsCount += 1
        cancelClosure?()
    }

    //MARK: - didLoad

    var didLoadCallsCount = 0
    var didLoadCalled: Bool {
        return didLoadCallsCount > 0
    }
    var didLoadClosure: (() -> Void)?

    func didLoad() {
        didLoadCallsCount += 1
        didLoadClosure?()
    }

    //MARK: - listItemIdentifier

    var listItemIdentifierForCallsCount = 0
    var listItemIdentifierForCalled: Bool {
        return listItemIdentifierForCallsCount > 0
    }
    var listItemIdentifierForReceivedPaymentMethod: PaymentMethod?
    var listItemIdentifierForReceivedInvocations: [PaymentMethod] = []
    var listItemIdentifierForReturnValue: String!
    var listItemIdentifierForClosure: ((PaymentMethod) -> String)?

    func listItemIdentifier(for paymentMethod: PaymentMethod) -> String {
        listItemIdentifierForCallsCount += 1
        listItemIdentifierForReceivedPaymentMethod = paymentMethod
        listItemIdentifierForReceivedInvocations.append(paymentMethod)
        if let listItemIdentifierForClosure = listItemIdentifierForClosure {
            return listItemIdentifierForClosure(paymentMethod)
        } else {
            return listItemIdentifierForReturnValue
        }
    }

}
class PreselectedPaymentMethodAssemblerProtocolMock: PreselectedPaymentMethodAssemblerProtocol {




    //MARK: - resolvePreselectedPaymentMethodRouter

    var resolvePreselectedPaymentMethodRouterDelegateComponentTitleCallsCount = 0
    var resolvePreselectedPaymentMethodRouterDelegateComponentTitleCalled: Bool {
        return resolvePreselectedPaymentMethodRouterDelegateComponentTitleCallsCount > 0
    }
    var resolvePreselectedPaymentMethodRouterDelegateComponentTitleReceivedArguments: (delegate: PreselectedPaymentMethodRouterListener?, component: PaymentComponent, title: String)?
    var resolvePreselectedPaymentMethodRouterDelegateComponentTitleReceivedInvocations: [(delegate: PreselectedPaymentMethodRouterListener?, component: PaymentComponent, title: String)] = []
    var resolvePreselectedPaymentMethodRouterDelegateComponentTitleReturnValue: Router!
    var resolvePreselectedPaymentMethodRouterDelegateComponentTitleClosure: ((PreselectedPaymentMethodRouterListener?, PaymentComponent, String) -> Router)?

    func resolvePreselectedPaymentMethodRouter(delegate: PreselectedPaymentMethodRouterListener?, component: PaymentComponent, title: String) -> Router {
        resolvePreselectedPaymentMethodRouterDelegateComponentTitleCallsCount += 1
        resolvePreselectedPaymentMethodRouterDelegateComponentTitleReceivedArguments = (delegate: delegate, component: component, title: title)
        resolvePreselectedPaymentMethodRouterDelegateComponentTitleReceivedInvocations.append((delegate: delegate, component: component, title: title))
        if let resolvePreselectedPaymentMethodRouterDelegateComponentTitleClosure = resolvePreselectedPaymentMethodRouterDelegateComponentTitleClosure {
            return resolvePreselectedPaymentMethodRouterDelegateComponentTitleClosure(delegate, component, title)
        } else {
            return resolvePreselectedPaymentMethodRouterDelegateComponentTitleReturnValue
        }
    }

}
class PreselectedPaymentMethodRoutingMock: PreselectedPaymentMethodRouting {




    //MARK: - presentPaymentMethodList

    var presentPaymentMethodListCallsCount = 0
    var presentPaymentMethodListCalled: Bool {
        return presentPaymentMethodListCallsCount > 0
    }
    var presentPaymentMethodListClosure: (() -> Void)?

    func presentPaymentMethodList() {
        presentPaymentMethodListCallsCount += 1
        presentPaymentMethodListClosure?()
    }

    //MARK: - present

    var presentComponentOnCancelCallsCount = 0
    var presentComponentOnCancelCalled: Bool {
        return presentComponentOnCancelCallsCount > 0
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

    //MARK: - present

    var presentActionComponentOnCancelCallsCount = 0
    var presentActionComponentOnCancelCalled: Bool {
        return presentActionComponentOnCancelCallsCount > 0
    }
    var presentActionComponentOnCancelClosure: ((any PresentableComponent, (() -> Void)?) -> Void)?

    func present(actionComponent: any PresentableComponent, onCancel: (() -> Void)?) {
        presentActionComponentOnCancelCallsCount += 1
        presentActionComponentOnCancelClosure?(actionComponent, onCancel)
    }

    //MARK: - dismiss

    var dismissCompletionCallsCount = 0
    var dismissCompletionCalled: Bool {
        return dismissCompletionCallsCount > 0
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
        get { return underlyingRootViewController }
        set(value) { underlyingRootViewController = value }
    }
    var underlyingRootViewController: UIViewController!


}
