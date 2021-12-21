//

import Adyen
import Foundation

final class PresentationDelegateMock: PresentationDelegate {

    // MARK: - presentComponent

    var presentComponentCallsCount = 0
    var presentComponentCalled: Bool {
        return presentComponentCallsCount > 0
    }
    var presentComponentReceivedComponent: PresentableComponent?
    var doPresent: ((_ component: PresentableComponent) -> Void)?

    func present(component: PresentableComponent) {
        presentComponentCallsCount += 1
        presentComponentReceivedComponent = component
        doPresent?(component)
    }

}
