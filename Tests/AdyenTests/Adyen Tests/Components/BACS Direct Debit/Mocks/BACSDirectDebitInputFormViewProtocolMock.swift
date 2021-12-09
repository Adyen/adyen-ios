//

@testable import Adyen
@testable import AdyenComponents

class BACSDirectDebitInputFormViewProtocolMock: BACSDirectDebitInputFormViewProtocol {

    // MARK: - setupNavigationBar

    var setupNavigationBarCallsCount = 0
    var setupNavigationBarCalled: Bool {
        return setupNavigationBarCallsCount > 0
    }

    func setupNavigationBar() {
        setupNavigationBarCallsCount += 1
    }

    // MARK: - addItem

    var addItemCallsCount = 0
    var addItemCalled: Bool {
        return addItemCallsCount > 0
    }

    func add<T>(item: T?) where T : FormItem {
        addItemCallsCount += 1
    }

    // MARK: - displayValidation

    var displayValidationCallsCount = 0
    var displayValidationCalled: Bool {
        return displayValidationCallsCount > 0
    }

    func displayValidation() {
        displayValidationCallsCount += 1
    }
}
