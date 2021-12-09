//

@testable import Adyen
@testable import AdyenComponents
import XCTest

class BACSInputPresenterTests: XCTestCase {

    var view: BACSInputFormViewProtocolMock!
    var router: BACSRouterProtocolMock!
    var itemsFactory: BACSItemsFactoryProtocolMock!
    var sut: BACSDirectDebitPresenter!

    override func setUpWithError() throws {
        try super.setUpWithError()

        view = BACSInputFormViewProtocolMock()
        router = BACSRouterProtocolMock()
        itemsFactory = itemsFactoryMock

        sut = BACSDirectDebitPresenter(view: view,
                                       router: router,
                                       itemsFactory: itemsFactory)
    }

    override func tearDownWithError() throws {
        view = nil
        router = nil
        itemsFactory = nil
        sut = nil
        try super.tearDownWithError()
    }

    func testItemsShouldBeSetupOnInitialization() throws {
        // Then
        XCTAssertEqual(itemsFactory.createHolderNameItemCallsCount, 1)
        XCTAssertEqual(itemsFactory.createBankAccountNumberItemCallsCount, 1)
        XCTAssertEqual(itemsFactory.createSortCodeItemCallsCount, 1)
        XCTAssertEqual(itemsFactory.createEmailItemCallsCount, 1)
        XCTAssertEqual(itemsFactory.createContinueButtonCallsCount, 1)
        XCTAssertEqual(itemsFactory.createAmountConsentToggleCallsCount, 1)
        XCTAssertEqual(itemsFactory.createLegalConsentToggleCallsCount, 1)
    }

    func testSetupViewShouldAddItemsToFormViewOnInitialization() throws {
        // When
        XCTAssertEqual(view.addItemCallsCount, 11)
    }

    func testContinuePaymentWhenButtonTappedShouldDisplayValidationOnView() throws {
        // When
        sut.continueButtonItem?.buttonSelectionHandler?()

        // The
        XCTAssertEqual(view.displayValidationCallsCount, 1)
    }

    func testContinuePaymentWhenAnyTextItemIsNotValidShouldNotCallRouterPresentConfirmation() throws {
        // Given
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

    func testContinuePaymentWhenAmountConsentItemIsDisabledShouldNotCallRouterPresentConfirmation() throws {
        // Given
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

    func testContinuePaymentWhenItemsAreValidShouldCallRouterPresentConfirmation() throws {
        // Given
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
        let expectedBacsData = bacsDataMock

        sut.amountConsentToggleItem?.value = true
        sut.legalConsentToggleItem?.value = true

        sut.holderNameItem?.value = expectedBacsData.holderName
        sut.bankAccountNumberItem?.value = expectedBacsData.bankAccountNumber
        sut.sortCodeItem?.value = expectedBacsData.bankLocationId
        sut.emailItem?.value = expectedBacsData.shopperEmail

        // Then
        sut.continueButtonItem?.buttonSelectionHandler?()
        sut.viewWillAppear()

        // Then
        let amountConsentValue = try XCTUnwrap(sut.amountConsentToggleItem?.value)
        let legalConsentValue = try XCTUnwrap(sut.legalConsentToggleItem?.value)
        XCTAssertFalse(amountConsentValue)
        XCTAssertFalse(legalConsentValue)
        XCTAssertEqual(expectedBacsData.holderName, sut.holderNameItem?.value)
        XCTAssertEqual(expectedBacsData.bankAccountNumber, sut.bankAccountNumberItem?.value)
        XCTAssertEqual(expectedBacsData.bankLocationId, sut.sortCodeItem?.value)
        XCTAssertEqual(expectedBacsData.shopperEmail, sut.emailItem?.value)
    }

    // MARK: - Private

    private var itemsFactoryMock: BACSItemsFactoryProtocolMock {
        let styleProvider = FormComponentStyle()

        let itemsFactory = BACSItemsFactoryProtocolMock()
        itemsFactory.createHolderNameItemReturnValue = FormTextInputItem()
        itemsFactory.createBankAccountNumberItemReturnValue = FormTextInputItem()
        itemsFactory.createSortCodeItemReturnValue = FormTextInputItem()
        itemsFactory.createEmailItemReturnValue = FormTextInputItem()
        itemsFactory.createContinueButtonReturnValue = FormButtonItem(style: styleProvider.mainButtonItem)
        itemsFactory.createAmountConsentToggleReturnValue = FormToggleItem()
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
