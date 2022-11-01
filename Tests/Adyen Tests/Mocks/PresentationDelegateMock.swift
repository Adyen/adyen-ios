//

@_spi(AdyenInternal) import Adyen
@testable import AdyenDropIn
import Foundation

final class PresentationDelegateMock: NavigationDelegate {

    var doDismiss: (((() -> Void)?) -> Void)?

    func dismiss(completion: (() -> Void)?) {
        doDismiss?(completion)
    }

    // MARK: - presentComponent

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
