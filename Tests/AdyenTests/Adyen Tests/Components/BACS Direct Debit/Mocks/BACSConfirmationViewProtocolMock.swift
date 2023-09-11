//

@testable import Adyen
@testable import AdyenComponents

class BACSConfirmationViewProtocolMock: BACSConfirmationViewProtocol {

    // MARK: - setUserInteraction

    var setUserInteractionEnabledCallsCount = 0
    var setUserInteractionEnabledCalled: Bool {
        setUserInteractionEnabledCallsCount > 0
    }

    var setUserInteractionEnabledReceivedValue: Bool?

    func setUserInteraction(enabled: Bool) {
        setUserInteractionEnabledCallsCount += 1
        setUserInteractionEnabledReceivedValue = enabled
    }

    // MARK: - addItem

    var addItemCallsCount = 0
    var addItemCalled: Bool {
        addItemCallsCount > 0
    }

    func add(item: (some FormItem)?) {
        addItemCallsCount += 1
    }

    // MARK: - displayValidation

    var displayValidationCallsCount = 0
    var displayValidationCalled: Bool {
        displayValidationCallsCount > 0
    }

    func displayValidation() {
        displayValidationCallsCount += 1
    }
}
