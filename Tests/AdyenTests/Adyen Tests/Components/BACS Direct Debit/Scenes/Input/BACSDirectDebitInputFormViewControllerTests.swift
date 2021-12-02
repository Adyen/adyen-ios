//

@testable import Adyen
@testable import AdyenComponents
import XCTest

class BACSDirectDebitInputFormViewControllerTests: XCTestCase {

    var sut: BACSDirectDebitInputFormViewController!
    var presenter: BACSDirectDebitPresenterProtocolMock!

    override func setUpWithError() throws {
        try super.setUpWithError()
        presenter = BACSDirectDebitPresenterProtocolMock()

        let styleProvider = FormComponentStyle()
        sut = BACSDirectDebitInputFormViewController(title: "BACS Direct Debit",
                                                     styleProvider: styleProvider)
        sut.presenter = presenter
    }

    override func tearDownWithError() throws {
        presenter = nil
        sut = nil
        try super.tearDownWithError()
    }

    func testDidTapCancelButtonShouldCallPresenterDidCancel() throws {
        // When
        sut.didTapCancelButton()

        // Then
        XCTAssertEqual(presenter.didCancelCallCount, 1)
    }

    func testViewDidLoadShouldCallPresenterViewDidLoad() throws {
        // When
        sut.viewDidLoad()

        // Then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
}
