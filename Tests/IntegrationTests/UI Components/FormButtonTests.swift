//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

final class FormButtonTests: XCTestCase {

    private let style = ButtonStyle(title: .init(font: .preferredFont(forTextStyle: .body), color: .red))

    func testInitialState() throws {
        let (sut, activityIndicatorView) = try makeSUT()

        XCTAssertFalse(sut.showsActivityIndicator, "Activity indicator should not be showing initially")
        XCTAssertFalse(activityIndicatorView.isAnimating, "Activity indicator should not be animating initially")
        
        XCTAssertTrue(sut.titleLabel.alpha == 1.0, "Button title should be visible initially")
        XCTAssertEqual(sut.titleLabel.text, "Submit", "Button title should be set correctly")
        XCTAssertTrue(sut.isEnabled, "Button should be enabled initially")
    }

    func testButtonTapLoadingState() throws {
        let (sut, activityIndicatorView) = try makeSUT()

        // When: Simulate tap by directly setting showsActivityIndicator to true
        sut.showsActivityIndicator = true

        // Then assert loading state and title visibility
        XCTAssertTrue(sut.showsActivityIndicator, "Activity indicator should be showing after tap")
        XCTAssertTrue(activityIndicatorView.isAnimating, "Activity indicator should be animating after tap")
        XCTAssertTrue(sut.contentStackView.alpha == 0.0, "Button title should be hidden after tap. (Button title is arranged in the stackview).")
        XCTAssertFalse(sut.isEnabled, "Button should be disabled during loading")
    }

    func testActivityIndicatorDisappearsAndTitleComesBack() throws {
        let (sut, activityIndicatorView) = try makeSUT()

        // When we put the button in a loading state
        sut.showsActivityIndicator = true
        XCTAssertTrue(sut.showsActivityIndicator)
        sut.showsActivityIndicator = false
        XCTAssertFalse(sut.showsActivityIndicator)

        // Then assert loading state and title visibility
        XCTAssertFalse(sut.showsActivityIndicator, "Activity indicator should not be showing after setting to false")
        XCTAssertFalse(activityIndicatorView.isAnimating, "Activity indicator should not be animating after setting to false")
        XCTAssertTrue(sut.titleLabel.alpha == 1.0, "Button title should be visible after activity indicator hides")
        XCTAssertTrue(sut.isEnabled, "Button should be enabled after activity indicator hides")
    }

    func makeSUT(_ title: String = "Submit") throws -> (FormButton, UIActivityIndicatorView) {
        let sut = FormButton(style: style)
        sut.title = title
        let activityIndicatorView: UIActivityIndicatorView = try XCTUnwrap(sut.findView(by: "activityIndicator"))

        return (sut, activityIndicatorView)
    }
}
