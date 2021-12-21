//

@testable import Adyen
@testable import AdyenComponents

class BACSConfirmationViewProtocolMock: BACSConfirmationViewProtocol {

    // MARK: - setUserInteraction

    var setUserInteractionEnabledCallsCount = 0
    var setUserInteractionEnabledCalled: Bool {
        return setUserInteractionEnabledCallsCount > 0
    }
    var setUserInteractionEnabledReceivedValue: Bool?

    func setUserInteraction(enabled: Bool) {
        setUserInteractionEnabledCallsCount += 1
        setUserInteractionEnabledReceivedValue = enabled
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
