//

@testable import Adyen
@testable import AdyenComponents
import XCTest


class BACSConfirmationPresenterTests: XCTestCase {

    var view: BACSConfirmationViewProtocolMock!
    var router: BACSRouterProtocolMock!
    var itemsFactory: BACSItemsFactoryProtocolMock!
    var sut: BACSConfirmationPresenter!

    override func setUpWithError() throws {
        try super.setUpWithError()

        view = BACSConfirmationViewProtocolMock()
        router = BACSRouterProtocolMock()
        itemsFactory = itemsFactoryMock
        sut = BACSConfirmationPresenter(data: bacsDataMock,
                                        view: view,
                                        router: router,
                                        itemsFactory: itemsFactory)
    }

    override func tearDownWithError() throws {
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
        XCTAssertEqual(itemsFactory.createPaymentButtonCallsCount, 1)
    }

    func testViewDidLoadShouldAddItemsToFormView() throws {
        // When
        sut.viewDidLoad()

        // Then
        XCTAssertEqual(view.addItemCallsCount, 7)
    }

    func testStartLoadingShouldShowActivityIndicatorInPaymentButton() throws {
        // Given
        sut.viewDidLoad()

        // When
        sut.startLoading()

        // Then
        let showsActivityIndicator = try XCTUnwrap(sut.paymentButtonItem?.showsActivityIndicator)
        XCTAssertTrue(showsActivityIndicator)
    }

    func testStartLoadingShouldDisableUsesrInteractionOnView() throws {
        // Given
        sut.viewDidLoad()

        // When
        sut.startLoading()

        // Then
        XCTAssertEqual(view.setUserInteractionEnabledCallsCount, 1)

        let receivedUserInteractionValue = try XCTUnwrap(view.setUserInteractionEnabledReceivedValue)
        XCTAssertFalse(receivedUserInteractionValue)
    }

    func testStopLoadingShouldHideActivityIndicatorInPaymentButton() throws {
        // Given
        sut.viewDidLoad()

        // When
        sut.stopLoading()

        // Then
        let showsActivityIndicator = try XCTUnwrap(sut.paymentButtonItem?.showsActivityIndicator)
        XCTAssertFalse(showsActivityIndicator)
    }

    func testStopLoadingShouldDisableUsesrInteractionOnView() throws {
        // Given
        sut.viewDidLoad()

        // When
        sut.stopLoading()

        // Then
        XCTAssertEqual(view.setUserInteractionEnabledCallsCount, 1)

        let receivedUserInteractionValue = try XCTUnwrap(view.setUserInteractionEnabledReceivedValue)
        XCTAssertTrue(receivedUserInteractionValue)
    }

    // MARK: - Private

    private var bacsDataMock: BACSDirectDebitData {
        BACSDirectDebitData(holderName: "Katrina del Mar",
                            bankAccountNumber: "90583742",
                            bankLocationId: "743082",
                            shopperEmail: "katrina.mar@mail.com")
    }

    private var itemsFactoryMock: BACSItemsFactoryProtocolMock {
        let styleProvider = FormComponentStyle()

        let itemsFactory = BACSItemsFactoryProtocolMock()
        itemsFactory.createHolderNameItemReturnValue = FormTextInputItem()
        itemsFactory.createBankAccountNumberItemReturnValue = FormTextInputItem()
        itemsFactory.createSortCodeItemReturnValue = FormTextInputItem()
        itemsFactory.createEmailItemReturnValue = FormTextInputItem()
        itemsFactory.createPaymentButtonReturnValue = FormButtonItem(style: styleProvider.mainButtonItem)

        return itemsFactory
    }
}
