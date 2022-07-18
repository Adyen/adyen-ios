//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents
import XCTest

class BACSInputPresenterTests: XCTestCase {

    var view: BACSInputFormViewProtocolMock!
    var router: BACSRouterProtocolMock!
    var tracker: BACSDirectDebitComponentTrackerProtocolMock!
    var itemsFactory: BACSItemsFactoryProtocolMock!
    var sut: BACSInputPresenter!

    override func setUpWithError() throws {
        try super.setUpWithError()

        view = BACSInputFormViewProtocolMock()
        router = BACSRouterProtocolMock()
        tracker = BACSDirectDebitComponentTrackerProtocolMock()
        itemsFactory = itemsFactoryMock
        let amount = Amount(value: 105.7, currencyCode: "USD", localeIdentifier: nil)

        sut = BACSInputPresenter(view: view,
                                 router: router,
                                 tracker: tracker,
                                 itemsFactory: itemsFactory)
        sut.amount = amount
    }

    override func tearDownWithError() throws {
        view = nil
        router = nil
        tracker = nil
        itemsFactory = nil
        sut = nil
        try super.tearDownWithError()
    }

    func testViewDidLoadShouldCreateItems() throws {
        // When
        sut.viewDidLoad()

        // Then
        XCTAssertEqual(itemsFactory.createHolderNameItemCallsCount, 1)
        XCTAssertEqual(itemsFactory.createBankAccountNumberItemCallsCount, 1)
        XCTAssertEqual(itemsFactory.createSortCodeItemCallsCount, 1)
        XCTAssertEqual(itemsFactory.createEmailItemCallsCount, 1)
        XCTAssertEqual(itemsFactory.createContinueButtonCallsCount, 1)
        XCTAssertEqual(itemsFactory.createAmountConsentToggleAmountCallsCount, 1)
        XCTAssertEqual(itemsFactory.createLegalConsentToggleCallsCount, 1)
    }

    func testViewDidLoadShouldAddItemsToFormView() throws {
        // When
        sut.viewDidLoad()

        // Then
        XCTAssertEqual(view.addItemCallsCount, 11)
    }

    func testViewDidLoadShouldCallTrackerSendEvent() throws {
        // When
        sut.viewDidLoad()

        // Then
        XCTAssertEqual(tracker.sendTelemetryEventCallsCount, 1)
    }

    func testContinuePaymentWhenButtonTappedShouldDisplayValidationOnView() throws {
        // When
        sut.viewDidLoad()
        sut.continueButtonItem?.buttonSelectionHandler?()

        // Then
        XCTAssertEqual(view.displayValidationCallsCount, 1)
    }

    func testContinuePaymentWhenAnyTextItemIsNotValidShouldNotCallRouterPresentConfirmation() throws {
        // Given
        sut.viewDidLoad()
        sut.amountConsentToggleItem?.value = true
        sut.legalConsentToggleItem?.value = true

        sut.holderNameItem?.value = bacsDataMock.holderName
        sut.bankAccountNumberItem?.value = bacsDataMock.bankAccountNumber
        sut.sortCodeItem?.value = bacsDataMock.bankLocationId
        sut.emailItem?.value = "mail"

        // When
        sut.continueButtonItem?.buttonSelectionHandler?()

        // Then
        XCTAssertEqual(router.presentConfirmationWithDataCallsCount, 0)
    }

    func testContinuePaymentWhenAmountConsentItemIsDisabledShouldNotCallRouterPresentConfirmation() throws {
        // Given
        sut.viewDidLoad()
        sut.amountConsentToggleItem?.value = false
        sut.legalConsentToggleItem?.value = true

        sut.holderNameItem?.value = bacsDataMock.holderName
        sut.bankAccountNumberItem?.value = bacsDataMock.bankAccountNumber
        sut.sortCodeItem?.value = bacsDataMock.bankLocationId
        sut.emailItem?.value = bacsDataMock.shopperEmail

        // When
        sut.continueButtonItem?.buttonSelectionHandler?()

        // Then
        XCTAssertEqual(router.presentConfirmationWithDataCallsCount, 0)
    }

    func testContinuePaymentWhenLegalConsentItemIsDisabledShouldNotCallRouterPresentConfirmation() throws {
        // Given
        sut.viewDidLoad()
        sut.amountConsentToggleItem?.value = true
        sut.legalConsentToggleItem?.value = false

        sut.holderNameItem?.value = bacsDataMock.holderName
        sut.bankAccountNumberItem?.value = bacsDataMock.bankAccountNumber
        sut.sortCodeItem?.value = bacsDataMock.bankLocationId
        sut.emailItem?.value = bacsDataMock.shopperEmail

        // When
        sut.continueButtonItem?.buttonSelectionHandler?()

        // Then
        XCTAssertEqual(router.presentConfirmationWithDataCallsCount, 0)
    }

    func testContinuePaymentWhenAnyItemValueIsNilShouldNotCallRouterPresentConfirmation() throws {
        // Given
        sut.viewDidLoad()
        sut.amountConsentToggleItem?.value = true
        sut.legalConsentToggleItem?.value = false

        // Missing bank holder name value
        sut.bankAccountNumberItem?.value = bacsDataMock.bankAccountNumber
        sut.sortCodeItem?.value = bacsDataMock.bankLocationId
        sut.emailItem?.value = bacsDataMock.shopperEmail

        // When
        sut.continueButtonItem?.buttonSelectionHandler?()

        // Then
        XCTAssertEqual(router.presentConfirmationWithDataCallsCount, 0)
    }

    func testContinuePaymentWhenAllItemsAreValidShouldCallRouterPresentConfirmation() throws {
        // Given
        sut.viewDidLoad()
        sut.amountConsentToggleItem?.value = true
        sut.legalConsentToggleItem?.value = true

        sut.holderNameItem?.value = bacsDataMock.holderName
        sut.bankAccountNumberItem?.value = bacsDataMock.bankAccountNumber
        sut.sortCodeItem?.value = bacsDataMock.bankLocationId
        sut.emailItem?.value = bacsDataMock.shopperEmail

        // When
        sut.continueButtonItem?.buttonSelectionHandler?()

        // Then
        XCTAssertEqual(router.presentConfirmationWithDataCallsCount, 1)
    }

    func testContinuePaymentShouldCreateBacsDataWithCorrectValues() throws {
        // Given
        sut.viewDidLoad()
        let expectedBacsData = bacsDataMock

        sut.amountConsentToggleItem?.value = true
        sut.legalConsentToggleItem?.value = true

        sut.holderNameItem?.value = expectedBacsData.holderName
        sut.bankAccountNumberItem?.value = expectedBacsData.bankAccountNumber
        sut.sortCodeItem?.value = expectedBacsData.bankLocationId
        sut.emailItem?.value = expectedBacsData.shopperEmail

        // When
        sut.continueButtonItem?.buttonSelectionHandler?()

        // Then
        let receivedBacsData = router.presentConfirmationWithDataReceivedData
        XCTAssertNotNil(receivedBacsData)
        XCTAssertEqual(expectedBacsData, receivedBacsData)
    }

    func testViewWillAppearWhenThereIsDataInputShouldRestoreFields() throws {
        // Given
        sut.viewDidLoad()
        let expectedBacsData = bacsDataMock

        sut.amountConsentToggleItem?.value = true
        sut.legalConsentToggleItem?.value = true

        sut.holderNameItem?.value = expectedBacsData.holderName
        sut.bankAccountNumberItem?.value = expectedBacsData.bankAccountNumber
        sut.sortCodeItem?.value = expectedBacsData.bankLocationId
        sut.emailItem?.value = expectedBacsData.shopperEmail

        // When
        sut.continueButtonItem?.buttonSelectionHandler?()
        sut.viewWillAppear()

        // Then
        let amountConsentValue = try XCTUnwrap(sut.amountConsentToggleItem?.value)
        let legalConsentValue = try XCTUnwrap(sut.legalConsentToggleItem?.value)
        XCTAssertTrue(amountConsentValue)
        XCTAssertTrue(legalConsentValue)
        XCTAssertEqual(expectedBacsData.holderName, sut.holderNameItem?.value)
        XCTAssertEqual(expectedBacsData.bankAccountNumber, sut.bankAccountNumberItem?.value)
        XCTAssertEqual(expectedBacsData.bankLocationId, sut.sortCodeItem?.value)
        XCTAssertEqual(expectedBacsData.shopperEmail, sut.emailItem?.value)
    }

    func testResetFormShouldResetFormItems() throws {
        // Given
        sut.viewDidLoad()
        sut.amountConsentToggleItem?.value = true
        sut.legalConsentToggleItem?.value = true

        sut.holderNameItem?.value = bacsDataMock.holderName
        sut.bankAccountNumberItem?.value = bacsDataMock.bankAccountNumber
        sut.sortCodeItem?.value = bacsDataMock.bankLocationId
        sut.emailItem?.value = bacsDataMock.shopperEmail

        // When
        sut.resetForm()

        // Then
        let holderName = try XCTUnwrap(sut.holderNameItem?.value)
        XCTAssertTrue(holderName.isEmpty)

        let bankAccountNumber = try XCTUnwrap(sut.bankAccountNumberItem?.value)
        XCTAssertTrue(bankAccountNumber.isEmpty)

        let sortCode = try XCTUnwrap(sut.sortCodeItem?.value)
        XCTAssertTrue(sortCode.isEmpty)

        let email = try XCTUnwrap(sut.emailItem?.value)
        XCTAssertTrue(email.isEmpty)

        let amountConsentValue = try XCTUnwrap(sut.amountConsentToggleItem?.value)
        XCTAssertFalse(amountConsentValue)

        let legalConsentValue = try XCTUnwrap(sut.legalConsentToggleItem?.value)
        XCTAssertFalse(legalConsentValue)
    }

    // MARK: - Private

    private var itemsFactoryMock: BACSItemsFactoryProtocolMock {
        let styleProvider = FormComponentStyle()

        let itemsFactory = BACSItemsFactoryProtocolMock()

        let holderNameItem = FormTextInputItem()
        holderNameItem.validator = LengthValidator(minimumLength: 1, maximumLength: 70)
        itemsFactory.createHolderNameItemReturnValue = holderNameItem

        let bankAccountNumberItem = FormTextInputItem()
        bankAccountNumberItem.validator = NumericStringValidator(minimumLength: 1, maximumLength: 8)
        itemsFactory.createBankAccountNumberItemReturnValue = bankAccountNumberItem

        let sortCodeItem = FormTextInputItem()
        sortCodeItem.validator = NumericStringValidator(minimumLength: 1, maximumLength: 6)
        itemsFactory.createSortCodeItemReturnValue = sortCodeItem

        let emailItem = FormTextInputItem()
        emailItem.validator = EmailValidator()
        itemsFactory.createEmailItemReturnValue = emailItem

        itemsFactory.createContinueButtonReturnValue = FormButtonItem(style: styleProvider.mainButtonItem)
        itemsFactory.createAmountConsentToggleAmountReturnValue = FormToggleItem()
        itemsFactory.createLegalConsentToggleReturnValue = FormToggleItem()

        return itemsFactory
    }

    private var bacsDataMock: BACSDirectDebitData {
        BACSDirectDebitData(holderName: "Katrina del Mar",
                            bankAccountNumber: "90583742",
                            bankLocationId: "743082",
                            shopperEmail: "katrina.mar@mail.com")
    }

}
