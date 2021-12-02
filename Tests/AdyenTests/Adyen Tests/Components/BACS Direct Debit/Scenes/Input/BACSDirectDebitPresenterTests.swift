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

}
