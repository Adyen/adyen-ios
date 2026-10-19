//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents
@_spi(AdyenInternal) @testable import AdyenUI

class BACSItemsFactoryProtocolMock: BACSItemsFactoryProtocol {

    // MARK: - createHolderNameItem

    var createHolderNameItemCallsCount = 0
    var createHolderNameItemCalled: Bool {
        createHolderNameItemCallsCount > 0
    }

    var createHolderNameItemReturnValue: FormTextInputItem!

    func createHolderNameItem() -> FormTextInputItem {
        createHolderNameItemCallsCount += 1
        return createHolderNameItemReturnValue
    }

    // MARK: - createBankAccountNumberItem

    var createBankAccountNumberItemCallsCount = 0
    var createBankAccountNumberItemCalled: Bool {
        createBankAccountNumberItemCallsCount > 0
    }

    var createBankAccountNumberItemReturnValue: FormTextInputItem!

    func createBankAccountNumberItem() -> FormTextInputItem {
        createBankAccountNumberItemCallsCount += 1
        return createBankAccountNumberItemReturnValue
    }

    // MARK: - createSortCodeItem

    var createSortCodeItemCallsCount = 0
    var createSortCodeItemCalled: Bool {
        createSortCodeItemCallsCount > 0
    }

    var createSortCodeItemReturnValue: FormTextInputItem!

    func createSortCodeItem() -> FormTextInputItem {
        createSortCodeItemCallsCount += 1
        return createSortCodeItemReturnValue
    }

    // MARK: - createEmailItem

    var createEmailItemCallsCount = 0
    var createEmailItemCalled: Bool {
        createEmailItemCallsCount > 0
    }

    var createEmailItemReturnValue: FormTextInputItem!

    func createEmailItem() -> FormTextInputItem {
        createEmailItemCallsCount += 1
        return createEmailItemReturnValue
    }

    // MARK: - createPaymentButton

    var createPaymentButtonCallsCount = 0
    var createPaymentButtonCalled: Bool {
        createPaymentButtonCallsCount > 0
    }

    var createPaymentButtonReturnValue: FormButtonItem!
    var createPaymentButtonReceivedOnSubmit: (() -> Void)?

    func createPaymentButton(_ onSubmit: @escaping () -> Void) -> FormButtonItem {
        createPaymentButtonCallsCount += 1
        createPaymentButtonReceivedOnSubmit = onSubmit
        createPaymentButtonReturnValue.buttonSelectionHandler = onSubmit
        return createPaymentButtonReturnValue
    }

    // MARK: - createAmountConsentToggle

    var createAmountConsentToggleAmountCallsCount = 0
    var createAmountConsentToggleAmountCalled: Bool {
        createAmountConsentToggleAmountCallsCount > 0
    }

    var createAmountConsentToggleAmountReturnValue: FormToggleItem!
    var createAmountConsentToggleReceivedAmount: Amount?

    func createAmountConsentToggle(amount: Amount?) -> FormToggleItem {
        createAmountConsentToggleAmountCallsCount += 1
        createAmountConsentToggleReceivedAmount = amount
        return createAmountConsentToggleAmountReturnValue
    }

    // MARK: - createLegalConsentToggle

    var createLegalConsentToggleCallsCount = 0
    var createLegalConsentToggleCalled: Bool {
        createLegalConsentToggleCallsCount > 0
    }

    var createLegalConsentToggleReturnValue: FormToggleItem!
    func createLegalConsentToggle() -> FormToggleItem {
        createLegalConsentToggleCallsCount += 1
        return createLegalConsentToggleReturnValue
    }
}
