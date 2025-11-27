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
@testable import AdyenDropIn






















class ComponentContainerRoutingMock: ComponentContainerRouting {




    //MARK: - present

    var presentComponentCallsCount = 0
    var presentComponentCalled: Bool {
        return presentComponentCallsCount > 0
    }
    var presentComponentReceivedComponent: any PresentableComponent?
    var presentComponentReceivedInvocations: [any PresentableComponent] = []
    var presentComponentClosure: ((any PresentableComponent) -> Void)?

    func present(component: any PresentableComponent) {
        presentComponentCallsCount += 1
        presentComponentReceivedComponent = component
        presentComponentReceivedInvocations.append(component)
        presentComponentClosure?(component)
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
