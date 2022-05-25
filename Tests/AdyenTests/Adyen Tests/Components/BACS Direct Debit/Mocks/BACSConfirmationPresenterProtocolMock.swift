//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents

class BACSConfirmationPresenterProtocolMock: BACSConfirmationPresenterProtocol {

    // MARK: - viewDidLoad

    var viewDidLoadCallsCount = 0
    var viewDidLoadCalled: Bool {
        viewDidLoadCallsCount > 0
    }

    func viewDidLoad() {
        viewDidLoadCallsCount += 1
    }

    // MARK: - startLoading

    var startLoadingCallsCount = 0
    var startLoadingCalled: Bool {
        startLoadingCallsCount > 0
    }

    func startLoading() {
        startLoadingCallsCount += 1
    }

    // MARK: - stopLoading

    var stopLoadingCallsCount = 0
    var stopLoadingCalled: Bool {
        stopLoadingCallsCount > 0
    }

    func stopLoading() {
        stopLoadingCallsCount += 1
    }
}
