//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents
import XCTest

class BACSInputFormViewControllerTests: XCTestCase {

    var sut: BACSInputFormViewController!
    var presenter: BACSInputPresenterProtocolMock!

    override func setUpWithError() throws {
        try super.setUpWithError()
        presenter = BACSInputPresenterProtocolMock()

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

    func testViewDidLoadShouldCallPresenterViewDidLoad() throws {
        // When
        sut.viewDidLoad()

        // Then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    func testViewWillAppearShouldCallPresenterViewWillAppear() throws {
        // When
        sut.viewWillAppear(true)

        // Then
        XCTAssertTrue(presenter.viewWillAppearCalled)
    }
}
