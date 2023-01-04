//

import Adyen
@testable import AdyenDropIn
import Foundation

final class PresentationDelegateMock: NavigationDelegate {

    // MARK: - dismiss Component

    var dismissComponentCallsCount = 0
    var dismissComponentCalled: Bool {
        dismissComponentCallsCount > 0
    }

    var doDismiss: (((() -> Void)?) -> Void)?

    func dismiss(completion: (() -> Void)?) {
        dismissComponentCallsCount += 1
        doDismiss?(completion)
    }

    // MARK: - present Component

    var presentComponentCallsCount = 0
    var presentComponentCalled: Bool {
        presentComponentCallsCount > 0
    }

    var presentComponentReceivedComponent: PresentableComponent?
    var doPresent: ((_ component: PresentableComponent) -> Void)?

    func present(component: PresentableComponent) {
        presentComponentCallsCount += 1
        presentComponentReceivedComponent = component
        doPresent?(component)
    }

}
