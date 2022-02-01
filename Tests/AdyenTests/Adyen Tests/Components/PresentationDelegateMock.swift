//

import Adyen
@testable import AdyenDropIn
import Foundation

final class PresentationDelegateMock: NavigationDelegate {

    // MARK: - presentComponent

    var dismissComponentCallsCount = 0
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

    var doDismiss: (() -> Void)?

    func dismiss() {
        dismissComponentCallsCount += 1
        doDismiss?()
    }

}
