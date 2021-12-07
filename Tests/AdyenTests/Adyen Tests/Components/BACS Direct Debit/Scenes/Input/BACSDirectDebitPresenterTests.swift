//

@testable import Adyen
@testable import AdyenComponents
import XCTest

class BACSDirectDebitPresenterTests: XCTestCase {

    var view: BACSDirectDebitInputFormViewProtocolMock!
    var router: BACSDirectDebitRouterProtocolMock!
    var itemsFactory: BACSDirectDebitItemsFactoryProtocolMock!
    var sut: BACSDirectDebitPresenter!

    override func setUpWithError() throws {
        try super.setUpWithError()

        view = BACSDirectDebitInputFormViewProtocolMock()
        router = BACSDirectDebitRouterProtocolMock()
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

    func testViewDidLoadShouldCallViewSetupNavigationBar() throws {
        // When
        sut.viewDidLoad()

        // Then
        XCTAssertEqual(view.setupNavigationBarCallsCount, 1)
    }

    func testDidCancelShouldCallRouterCancelPayment() throws {
        // When
        sut.didCancel()

        // Then
        XCTAssertEqual(router.cancelPaymentCallsCount, 1)
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

    // MARK: - Private

    private var itemsFactoryMock: BACSDirectDebitItemsFactoryProtocolMock {
        let styleProvider = FormComponentStyle()

        let itemsFactory = BACSDirectDebitItemsFactoryProtocolMock()
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
