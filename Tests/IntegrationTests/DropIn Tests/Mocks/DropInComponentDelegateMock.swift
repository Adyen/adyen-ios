//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenActions
@testable import AdyenDropIn

class DropInComponentDelegateMock: DropInComponentDelegate {

    init() {}

    // MARK: - didSubmit

    var didSubmitFromInCallsCount = 0
    var didSubmitFromInCalled: Bool {
        didSubmitFromInCallsCount > 0
    }

    var didSubmitFromInReceivedArguments: (data: PaymentComponentData, component: PaymentComponent, dropInComponent: AnyDropInComponent)?
    var didSubmitFromInReceivedInvocations: [(data: PaymentComponentData, component: PaymentComponent, dropInComponent: AnyDropInComponent)] = []
    var didSubmitFromInClosure: ((PaymentComponentData, PaymentComponent, AnyDropInComponent) -> Void)?

    func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent, in dropInComponent: AnyDropInComponent) {
        didSubmitFromInCallsCount += 1
        didSubmitFromInReceivedArguments = (data: data, component: component, dropInComponent: dropInComponent)
        didSubmitFromInReceivedInvocations.append((data: data, component: component, dropInComponent: dropInComponent))
        didSubmitFromInClosure?(data, component, dropInComponent)
    }

    // MARK: - didFail

    var didFailWithFromInCallsCount = 0
    var didFailWithFromInCalled: Bool {
        didFailWithFromInCallsCount > 0
    }

    var didFailWithFromInReceivedArguments: (error: Error, component: PaymentComponent, dropInComponent: AnyDropInComponent)?
    var didFailWithFromInReceivedInvocations: [(error: Error, component: PaymentComponent, dropInComponent: AnyDropInComponent)] = []
    var didFailWithFromInClosure: ((Error, PaymentComponent, AnyDropInComponent) -> Void)?

    func didFail(with error: Error, from component: PaymentComponent, in dropInComponent: AnyDropInComponent) {
        didFailWithFromInCallsCount += 1
        didFailWithFromInReceivedArguments = (error: error, component: component, dropInComponent: dropInComponent)
        didFailWithFromInReceivedInvocations.append((error: error, component: component, dropInComponent: dropInComponent))
        didFailWithFromInClosure?(error, component, dropInComponent)
    }

    // MARK: - didProvide

    var didProvideFromInCallsCount = 0
    var didProvideFromInCalled: Bool {
        didProvideFromInCallsCount > 0
    }

    var didProvideFromInReceivedArguments: (data: ActionComponentData, component: ActionComponent, dropInComponent: AnyDropInComponent)?
    var didProvideFromInReceivedInvocations: [(data: ActionComponentData, component: ActionComponent, dropInComponent: AnyDropInComponent)] = []
    var didProvideFromInClosure: ((ActionComponentData, ActionComponent, AnyDropInComponent) -> Void)?

    func didProvide(_ data: ActionComponentData, from component: ActionComponent, in dropInComponent: AnyDropInComponent) {
        didProvideFromInCallsCount += 1
        didProvideFromInReceivedArguments = (data: data, component: component, dropInComponent: dropInComponent)
        didProvideFromInReceivedInvocations.append((data: data, component: component, dropInComponent: dropInComponent))
        didProvideFromInClosure?(data, component, dropInComponent)
    }

    // MARK: - didComplete

    var didCompleteFromInCallsCount = 0
    var didCompleteFromInCalled: Bool {
        didCompleteFromInCallsCount > 0
    }

    var didCompleteFromInReceivedArguments: (component: ActionComponent, dropInComponent: AnyDropInComponent)?
    var didCompleteFromInReceivedInvocations: [(component: ActionComponent, dropInComponent: AnyDropInComponent)] = []
    var didCompleteFromInClosure: ((ActionComponent, AnyDropInComponent) -> Void)?

    func didComplete(from component: ActionComponent, in dropInComponent: AnyDropInComponent) {
        didCompleteFromInCallsCount += 1
        didCompleteFromInReceivedArguments = (component: component, dropInComponent: dropInComponent)
        didCompleteFromInReceivedInvocations.append((component: component, dropInComponent: dropInComponent))
        didCompleteFromInClosure?(component, dropInComponent)
    }

    // MARK: - didFailAction

    var didFailActionWithFromInCallsCount = 0
    var didFailActionWithFromInCalled: Bool {
        didFailWithFromInCallsCount > 0
    }

    var didFailActionWithFromInReceivedArguments: (error: Error, component: ActionComponent, dropInComponent: AnyDropInComponent)?
    var didFailActionWithFromInReceivedInvocations: [(error: Error, component: ActionComponent, dropInComponent: AnyDropInComponent)] = []
    var didFailActionWithFromInClosure: ((Error, ActionComponent, AnyDropInComponent) -> Void)?

    func didFail(with error: Error, from component: ActionComponent, in dropInComponent: AnyDropInComponent) {
        didFailActionWithFromInCallsCount += 1
        didFailActionWithFromInReceivedArguments = (error: error, component: component, dropInComponent: dropInComponent)
        didFailActionWithFromInReceivedInvocations.append((error: error, component: component, dropInComponent: dropInComponent))
        didFailActionWithFromInClosure?(error, component, dropInComponent)
    }

    // MARK: - didOpenExternalApplication

    var didOpenExternalApplicationComponentInCallsCount = 0
    var didOpenExternalApplicationComponentInCalled: Bool {
        didOpenExternalApplicationComponentInCallsCount > 0
    }

    var didOpenExternalApplicationComponentInReceivedArguments: (component: ActionComponent, dropInComponent: AnyDropInComponent)?
    var didOpenExternalApplicationComponentInReceivedInvocations: [(component: ActionComponent, dropInComponent: AnyDropInComponent)] = []
    var didOpenExternalApplicationComponentInClosure: ((ActionComponent, AnyDropInComponent) -> Void)?

    func didOpenExternalApplication(component: ActionComponent, in dropInComponent: AnyDropInComponent) {
        didOpenExternalApplicationComponentInCallsCount += 1
        didOpenExternalApplicationComponentInReceivedArguments = (component: component, dropInComponent: dropInComponent)
        didOpenExternalApplicationComponentInReceivedInvocations.append((component: component, dropInComponent: dropInComponent))
        didOpenExternalApplicationComponentInClosure?(component, dropInComponent)
    }

    // MARK: - didFail

    var didFailWithFromCallsCount = 0
    var didFailWithFromCalled: Bool {
        didFailWithFromCallsCount > 0
    }

    var didFailWithFromReceivedArguments: (error: Error, dropInComponent: AnyDropInComponent)?
    var didFailWithFromReceivedInvocations: [(error: Error, dropInComponent: AnyDropInComponent)] = []
    var didFailWithFromClosure: ((Error, AnyDropInComponent) -> Void)?

    func didFail(with error: Error, from dropInComponent: AnyDropInComponent) {
        didFailWithFromCallsCount += 1
        didFailWithFromReceivedArguments = (error: error, dropInComponent: dropInComponent)
        didFailWithFromReceivedInvocations.append((error: error, dropInComponent: dropInComponent))
        didFailWithFromClosure?(error, dropInComponent)
    }

    // MARK: - didCancel

    var didCancelComponentFromCallsCount = 0
    var didCancelComponentFromCalled: Bool {
        didCancelComponentFromCallsCount > 0
    }

    var didCancelComponentFromReceivedArguments: (component: PaymentComponent, dropInComponent: AnyDropInComponent)?
    var didCancelComponentFromReceivedInvocations: [(component: PaymentComponent, dropInComponent: AnyDropInComponent)] = []
    var didCancelComponentFromClosure: ((PaymentComponent, AnyDropInComponent) -> Void)?

    func didCancel(component: PaymentComponent, from dropInComponent: AnyDropInComponent) {
        didCancelComponentFromCallsCount += 1
        didCancelComponentFromReceivedArguments = (component: component, dropInComponent: dropInComponent)
        didCancelComponentFromReceivedInvocations.append((component: component, dropInComponent: dropInComponent))
        didCancelComponentFromClosure?(component, dropInComponent)
    }

}
