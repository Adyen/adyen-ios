//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

class BACSInputFormViewControllerTests: XCTestCase {

    var sut: BACSViewController!
    var presenter: BACSInputPresenterProtocolMock!

    override func setUpWithError() throws {
        try super.setUpWithError()
        presenter = BACSInputPresenterProtocolMock()

        let styleProvider = FormComponentStyle()
        sut = BACSViewController(
            title: "BACS Direct Debit",
            scrollEnabled: true,
            styleProvider: styleProvider
        )
        sut.viewModel = presenter
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

    func testViewDidLoadShouldCallPresenterViewDidLoad() {
        // When
        sut.viewDidLoad()

        // Then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    func testViewWillAppearShouldCallPresenterViewWillAppear() {
        // When
        sut.viewWillAppear(true)

        // Then
        XCTAssertTrue(presenter.viewWillAppearCalled)
    }
}
