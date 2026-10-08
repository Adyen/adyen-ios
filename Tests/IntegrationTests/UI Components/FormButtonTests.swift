//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenUI
import SwiftUI
import XCTest

@MainActor
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

    func testLoadingStateUsesDisabledColors() {
        let buttonStyle = AdyenButtonStyle.primary(for: .default)
        let sut = FormButton(buttonStyle: buttonStyle)

        sut.showsActivityIndicator = true
        XCTAssertEqual(sut.titleLabel.textColor, buttonStyle.disabledTextColor, "Title should use disabled text color while loading")
        XCTAssertEqual(sut.backgroundView.backgroundColor, buttonStyle.disabledBackgroundColor, "Background should be disabled color")

        sut.showsActivityIndicator = false
        XCTAssertEqual(sut.titleLabel.textColor, buttonStyle.textColor, "Title color should be restored after loading")
        XCTAssertEqual(sut.backgroundView.backgroundColor, buttonStyle.backgroundColor, "Background color should be restored after loading")
    }

    func testDisabledStateUsesDisabledColors() {
        let buttonStyle = AdyenButtonStyle.primary(for: .default)
        let sut = FormButton(buttonStyle: buttonStyle)

        sut.isEnabled = false
        XCTAssertEqual(sut.titleLabel.textColor, buttonStyle.disabledTextColor, "Title should use disabled text color when disabled")
        XCTAssertEqual(sut.backgroundView.backgroundColor, buttonStyle.disabledBackgroundColor, "Background should be disabled color")

        sut.isEnabled = true
        XCTAssertEqual(sut.titleLabel.textColor, buttonStyle.textColor, "Title color should be restored when enabled")
        XCTAssertEqual(sut.backgroundView.backgroundColor, buttonStyle.backgroundColor, "Background color should be restored when enabled")
    }

    func testProgressViewReplacesLeadingImageWhileLoading() throws {
        let (sut, progressView) = try makeSUT()
        sut.leadingImage = .systemLock
        XCTAssertFalse(sut.leadingImageView.isHidden, "Leading image should be visible initially")

        sut.showsActivityIndicator = true
        XCTAssertTrue(sut.leadingImageView.isHidden, "Leading image should be hidden while loading")
        XCTAssertFalse(progressView.isHidden, "Progress view should take the place of the leading image")

        sut.showsActivityIndicator = false
        XCTAssertFalse(sut.leadingImageView.isHidden, "Leading image should come back after loading")
        XCTAssertTrue(progressView.isHidden, "Progress view should be hidden after loading")
    }

    /// Verifies that SwiftUI configuration is transferred to the UIKit button.
    func test_configuration_when_renderingRepresentable_then_updatesFormButton() throws {
        let (_, _, sut) = try makeRepresentableSUT(
            title: "Continue",
            isEnabled: false,
            showsActivityIndicator: true
        )

        XCTAssertEqual(sut.title, "Continue")
        XCTAssertEqual(sut.accessibilityIdentifier, "representableButton")
        XCTAssertTrue(sut.showsActivityIndicator)
        XCTAssertFalse(sut.isEnabled)
    }

    /// Verifies that changing SwiftUI input updates the existing UIKit button.
    func test_newConfiguration_whenUpdatingRepresentable_thenRefreshesFormButton() throws {
        let (_, hostingController, sut) = try makeRepresentableSUT()

        hostingController.rootView = makeRepresentable(
            title: "Updated",
            isEnabled: false,
            showsActivityIndicator: false
        )
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.01))
        let updatedButton: FormButton = try XCTUnwrap(hostingController.view.findView(by: "representableButton"))

        XCTAssertTrue(updatedButton === sut)
        XCTAssertEqual(updatedButton.title, "Updated")
        XCTAssertFalse(updatedButton.isEnabled)
        XCTAssertFalse(updatedButton.showsActivityIndicator)
    }

    /// Verifies that tapping the UIKit button forwards the action to SwiftUI.
    func test_formButton_whenTapped_thenForwardsRepresentableAction() throws {
        var isActionCalled = false
        let (_, _, sut) = try makeRepresentableSUT(action: { isActionCalled = true })

        sut.sendActions(for: .touchUpInside)

        XCTAssertTrue(isActionCalled)
    }

    private func makeRepresentableSUT(
        title: String = "Submit",
        isEnabled: Bool = true,
        showsActivityIndicator: Bool = false,
        action: @escaping () -> Void = {}
    ) throws -> (UIWindow, UIHostingController<FormButtonRepresentable>, FormButton) {
        let hostingController = UIHostingController(rootView: makeRepresentable(
            title: title,
            isEnabled: isEnabled,
            showsActivityIndicator: showsActivityIndicator,
            action: action
        ))
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: AdyenUIConstants.submitButtonHeight))
        window.rootViewController = hostingController
        window.makeKeyAndVisible()
        hostingController.view.layoutIfNeeded()
        let button: FormButton = try XCTUnwrap(hostingController.view.findView(by: "representableButton"))
        return (window, hostingController, button)
    }

    private func makeRepresentable(
        title: String,
        isEnabled: Bool,
        showsActivityIndicator: Bool,
        action: @escaping () -> Void = {}
    ) -> FormButtonRepresentable {
        FormButtonRepresentable(
            title: title,
            style: .primary(for: .default),
            isEnabled: isEnabled,
            showsActivityIndicator: showsActivityIndicator,
            accessibilityIdentifier: "representableButton",
            action: action
        )
    }

    func makeSUT(_ title: String = "Submit") throws -> (FormButton, UIView) {
        let sut = FormButton(style: style)
        sut.title = title
        let progressView: UIView = try XCTUnwrap(sut.findView(by: "activityIndicator"))

        return (sut, progressView)
    }
}
