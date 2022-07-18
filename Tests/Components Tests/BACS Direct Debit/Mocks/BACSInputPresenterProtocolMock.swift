//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents

class BACSInputPresenterProtocolMock: BACSInputPresenterProtocol {

    // MARK: - viewDidLoad
    
    var amount: Amount?

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

    // MARK: - resetForm

    var resetFormCallsCount = 0
    var restFormCalled: Bool {
        resetFormCallsCount > 0
    }

    func resetForm() {
        resetFormCallsCount += 1
    }
}
