//

@testable import Adyen
@testable import AdyenComponents

class BACSInputPresenterProtocolMock: BACSInputPresenterProtocol {

    // MARK: - viewDidLoad

    var viewDidLoadCallsCount = 0
    var viewDidLoadCalled: Bool {
        viewDidLoadCallsCount > 0
    }

    func viewDidLoad() {
        viewDidLoadCallsCount += 1
    }

    // MARK: - viewWillAppear

    var viewWillAppearCallsCount = 0
    var viewWillAppearCalled: Bool {
        viewWillAppearCallsCount > 0
    }

    func viewWillAppear() {
        viewWillAppearCallsCount += 1
    }
}
