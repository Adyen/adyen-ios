//

@testable import Adyen
@testable import AdyenComponents

class BACSItemsFactoryProtocolMock: BACSItemsFactoryProtocol {

    // MARK: - createHolderNameItem

    var createHolderNameItemCallsCount = 0
    var createHolderNameItemCalled: Bool {
        return createHolderNameItemCallsCount > 0
    }
    var createHolderNameItemReturnValue: FormTextInputItem!

    func createHolderNameItem() -> FormTextInputItem {
        createHolderNameItemCallsCount += 1
        return createHolderNameItemReturnValue
    }

    // MARK: - createBankAccountNumberItem

    var createBankAccountNumberItemCallsCount = 0
    var createBankAccountNumberItemCalled: Bool {
        return createBankAccountNumberItemCallsCount > 0
    }
    var createBankAccountNumberItemReturnValue: FormTextInputItem!

    func createBankAccountNumberItem() -> FormTextInputItem {
        createBankAccountNumberItemCallsCount += 1
        return createBankAccountNumberItemReturnValue
    }

    // MARK: - createSortCodeItem

    var createSortCodeItemCallsCount = 0
    var createSortCodeItemCalled: Bool {
        return createSortCodeItemCallsCount > 0
    }
    var createSortCodeItemReturnValue: FormTextInputItem!

    func createSortCodeItem() -> FormTextInputItem {
        createSortCodeItemCallsCount += 1
        return createSortCodeItemReturnValue
    }

    // MARK: - createEmailItem

    var createEmailItemCallsCount = 0
    var createEmailItemCalled: Bool {
        return createEmailItemCallsCount > 0
    }
    var createEmailItemReturnValue: FormTextInputItem!

    func createEmailItem() -> FormTextInputItem {
        createEmailItemCallsCount += 1
        return createEmailItemReturnValue
    }

    // MARK: - createContinueButton

    var createContinueButtonCallsCount = 0
    var createContinueButtonCalled: Bool {
        return createContinueButtonCallsCount > 0
    }
    var createContinueButtonReturnValue: FormButtonItem!

    func createContinueButton() -> FormButtonItem {
        createContinueButtonCallsCount += 1
        return createContinueButtonReturnValue
    }

    // MARK: - createPaymentButton

    var createPaymentButtonCallsCount = 0
    var createPaymentButtonCalled: Bool {
        return createPaymentButtonCallsCount > 0
    }
    var createPaymentButtonReturnValue: FormButtonItem!

    func createPaymentButton() -> FormButtonItem {
        createPaymentButtonCallsCount += 1
        return createPaymentButtonReturnValue
    }

    // MARK: - createAmountConsentToggle

    var createAmountConsentToggleCallsCount = 0
    var createAmountConsentToggleCalled: Bool {
        return createAmountConsentToggleCallsCount > 0
    }
    var createAmountConsentToggleReturnValue: FormToggleItem!

    func createAmountConsentToggle() -> FormToggleItem {
        createAmountConsentToggleCallsCount += 1
        return createAmountConsentToggleReturnValue
    }

    // MARK: - createLegalConsentToggle

    var createLegalConsentToggleCallsCount = 0
    var createLegalConsentToggleCalled: Bool {
        return createLegalConsentToggleCallsCount > 0
    }
    var createLegalConsentToggleReturnValue: FormToggleItem!
    func createLegalConsentToggle() -> FormToggleItem {
        createLegalConsentToggleCallsCount += 1
        return createLegalConsentToggleReturnValue
    }
}
