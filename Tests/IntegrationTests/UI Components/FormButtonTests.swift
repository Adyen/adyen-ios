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
        let (sut, progressView) = try makeSUT()

        XCTAssertFalse(sut.showsActivityIndicator, "Activity indicator should not be showing initially")
        XCTAssertTrue(progressView.isHidden, "Progress view should be hidden initially")
        XCTAssertTrue(progressView.subviews.isEmpty, "Progress view should not host a spinner initially")
        
        XCTAssertTrue(sut.titleLabel.alpha == 1.0, "Button title should be visible initially")
        XCTAssertEqual(sut.titleLabel.text, "Submit", "Button title should be set correctly")
        XCTAssertTrue(sut.isEnabled, "Button should be enabled initially")
    }

    func testButtonTapLoadingState() throws {
        let (sut, progressView) = try makeSUT()

        // When: Simulate tap by directly setting showsActivityIndicator to true
        sut.showsActivityIndicator = true

        // Then assert loading state and title visibility
        XCTAssertTrue(sut.showsActivityIndicator, "Activity indicator should be showing after tap")
        XCTAssertFalse(progressView.isHidden, "Progress view should be visible after tap")
        XCTAssertFalse(progressView.subviews.isEmpty, "Progress view should host the circular spinner after tap")
        XCTAssertTrue(sut.contentStackView.alpha == 1.0, "Button title should stay visible while loading")
        XCTAssertTrue(sut.contentStackView.arrangedSubviews.first === progressView, "Spinner should be before the title")
        XCTAssertFalse(sut.isEnabled, "Button should be disabled during loading")
    }

    func testActivityIndicatorDisappearsAndTitleComesBack() throws {
        let (sut, progressView) = try makeSUT()

        // When we put the button in a loading state
        sut.showsActivityIndicator = true
        XCTAssertTrue(sut.showsActivityIndicator)
        sut.showsActivityIndicator = false
        XCTAssertFalse(sut.showsActivityIndicator)

        // Then assert loading state and title visibility
        XCTAssertFalse(sut.showsActivityIndicator, "Activity indicator should not be showing after setting to false")
        XCTAssertTrue(progressView.isHidden, "Progress view should be hidden after setting to false")
        XCTAssertTrue(progressView.subviews.isEmpty, "Circular spinner should be removed after setting to false")
        XCTAssertTrue(sut.titleLabel.alpha == 1.0, "Button title should be visible after activity indicator hides")
        XCTAssertTrue(sut.isEnabled, "Button should be enabled after activity indicator hides")
    }

    func testLoadingStateUsesLoadingColors() {
        let buttonStyle = AdyenButtonStyle.primary(for: .default)
        let sut = FormButton(buttonStyle: buttonStyle, titleStyle: CheckoutTheme.default.elements.labels.bodyEmphasized)

        sut.showsActivityIndicator = true
        XCTAssertEqual(sut.titleLabel.textColor, buttonStyle.loadingTextColor, "Title should use loading text color while loading")
        XCTAssertEqual(sut.backgroundView.backgroundColor, buttonStyle.loadingBackgroundColor, "Background should be loading color")

        sut.showsActivityIndicator = false
        XCTAssertEqual(sut.titleLabel.textColor, buttonStyle.textColor, "Title color should be restored after loading")
        XCTAssertEqual(sut.backgroundView.backgroundColor, buttonStyle.backgroundColor, "Background color should be restored after loading")
    }

    func testDisabledStateUsesDisabledColors() {
        let buttonStyle = AdyenButtonStyle.primary(for: .default)
        let sut = FormButton(buttonStyle: buttonStyle, titleStyle: CheckoutTheme.default.elements.labels.bodyEmphasized)

        sut.isEnabled = false
        XCTAssertEqual(sut.titleLabel.textColor, buttonStyle.disabledTextColor, "Title should use disabled text color when disabled")
        XCTAssertEqual(sut.backgroundView.backgroundColor, buttonStyle.disabledBackgroundColor, "Background should be disabled color")

        sut.isEnabled = true
        XCTAssertEqual(sut.titleLabel.textColor, buttonStyle.textColor, "Title color should be restored when enabled")
        XCTAssertEqual(sut.backgroundView.backgroundColor, buttonStyle.backgroundColor, "Background color should be restored when enabled")
    }

    func testProgressViewReplacesLeadingImageWhileLoading() throws {
        let (sut, progressView) = try makeSUT()
        sut.leadingImage = UIImage(systemName: "star")
        XCTAssertFalse(sut.leadingImageView.isHidden, "Leading image should be visible initially")

        sut.showsActivityIndicator = true
        XCTAssertTrue(sut.leadingImageView.isHidden, "Leading image should be hidden while loading")
        XCTAssertFalse(progressView.isHidden, "Progress view should take the place of the leading image")

        sut.showsActivityIndicator = false
        XCTAssertFalse(sut.leadingImageView.isHidden, "Leading image should come back after loading")
        XCTAssertTrue(progressView.isHidden, "Progress view should be hidden after loading")
    }

    func makeSUT(_ title: String = "Submit") throws -> (FormButton, UIView) {
        let sut = FormButton(style: style)
        sut.title = title
        let progressView: UIView = try XCTUnwrap(sut.findView(by: "activityIndicator"))

        return (sut, progressView)
    }
}
