//

@testable import Adyen
@testable import AdyenComponents
import XCTest

class BACSInputFormViewControllerTests: XCTestCase {

    var sut: BACSInputFormViewController!
    var presenter: BACSPresenterProtocolMock!

    override func setUpWithError() throws {
        try super.setUpWithError()
        presenter = BACSPresenterProtocolMock()

        let styleProvider = FormComponentStyle()
        sut = BACSInputFormViewController(title: "BACS Direct Debit",
                                                     styleProvider: styleProvider)
        sut.presenter = presenter
    }

    override func tearDownWithError() throws {
        presenter = nil
        sut = nil
        try super.tearDownWithError()
    }

    func testTitleIsSetOnCreation() throws {
        // When
        let title = try XCTUnwrap(sut.title)
        XCTAssertFalse(title.isEmpty)
    }

    func testDelegateIsSetOnCreation() throws {
        // When
        XCTAssertNotNil(sut.delegate)
    }

    func testViewWillAppearShouldCallPresenterViewWillAppear() throws {
        // When
        sut.viewWillAppear(viewController: sut)

        // Then
        XCTAssertTrue(presenter.viewWillAppearCalled)
    }
}
