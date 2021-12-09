//

@testable import Adyen
@testable import AdyenComponents

class BACSConfirmationPresenterProtocolMock: BACSConfirmationPresenterProtocol {

    // MARK: - startLoading

    var startLoadingCallsCount = 0
    var startLoadingCalled: Bool {
        return startLoadingCallsCount > 0
    }

    func startLoading() {
        startLoadingCallsCount += 1
    }

    // MARK: - stopLoading

    var stopLoadingCallsCount = 0
    var stopLoadingCalled: Bool {
        return stopLoadingCallsCount > 0
    }

    func stopLoading() {
        stopLoadingCallsCount += 1
    }
}
