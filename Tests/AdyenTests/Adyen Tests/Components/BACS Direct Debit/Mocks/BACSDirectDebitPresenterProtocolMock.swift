//

@testable import Adyen
@testable import AdyenComponents

class BACSDirectDebitPresenterProtocolMock: BACSDirectDebitInputPresenterProtocol {

    // MARK: - viewDidLoad

    var viewDidLoadCallsCount = 0
    var viewDidLoadCalled: Bool {
        viewDidLoadCallsCount > 0
    }

    func viewDidLoad() {
        viewDidLoadCallsCount += 1
    }

    // MARK: - didCancel

    var didCancelCallCount = 0
    var didCancelCalled: Bool {
        didCancelCallCount > 0
    }

    func didCancel() {
        didCancelCallCount += 1
    }
}
