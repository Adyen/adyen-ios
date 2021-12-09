//

@testable import Adyen
@testable import AdyenComponents

class BACSPresenterProtocolMock: BACSInputPresenterProtocol {

    // MARK: - viewWillAppear

    var viewWillAppearCallsCount = 0
    var viewWillAppearCalled: Bool {
        viewWillAppearCallsCount > 0
    }

    func viewWillAppear() {
        viewWillAppearCallsCount += 1
    }
}
