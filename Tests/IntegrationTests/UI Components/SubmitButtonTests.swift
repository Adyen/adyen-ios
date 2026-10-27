//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import XCTest

final class SubmitButtonTests: XCTestCase {
    private enum Constants {
        static let accessibilityFontSize: CGFloat = 48
        static let constrainedWidth: CGFloat = 220
        static let minimumHeight: CGFloat = 50
    }

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
        XCTAssertTrue(sut.titleLabel.alpha == 0.0, "Button title should be hidden after tap")
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

    func testAccessibilityActivationHonorsEnabledAndLoadingStates() throws {
        let (sut, _) = try makeSUT()
        let target = SubmitButtonActionTarget()
        sut.addTarget(target, action: #selector(SubmitButtonActionTarget.submit), for: .touchUpInside)

        XCTAssertTrue(sut.canBecomeFocused)
        XCTAssertTrue(sut.accessibilityActivate())
        XCTAssertEqual(target.count, 1)

        sut.showsActivityIndicator = true
        XCTAssertFalse(sut.canBecomeFocused)
        XCTAssertFalse(sut.accessibilityActivate())
        XCTAssertEqual(target.count, 1)

        sut.showsActivityIndicator = false
        XCTAssertTrue(sut.accessibilityActivate())
        XCTAssertEqual(target.count, 2)

        sut.isUserInteractionEnabled = false
        XCTAssertFalse(sut.canBecomeFocused)
        XCTAssertFalse(sut.accessibilityActivate())
    }

    func testButtonGrowsToFitLargeMultilineText() throws {
        let (sut, _) = try makeSUT("Confirm this payment")
        sut.titleLabel.font = .systemFont(ofSize: Constants.accessibilityFontSize)
        let size = sut.systemLayoutSizeFitting(
            CGSize(width: Constants.constrainedWidth, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )

        XCTAssertGreaterThan(size.height, Constants.minimumHeight)
        XCTAssertEqual(sut.titleLabel.numberOfLines, 0)
        XCTAssertTrue(sut.titleLabel.adjustsFontForContentSizeCategory)
    }

    func testKeyboardSelectActivatesButton() throws {
        let (sut, _) = try makeSUT()
        let target = SubmitButtonActionTarget()
        sut.addTarget(target, action: #selector(SubmitButtonActionTarget.submit), for: .touchUpInside)

        sut.pressesEnded([SubmitButtonSelectPress()], with: nil)
        XCTAssertEqual(target.count, 1)

        sut.isEnabled = false
        sut.pressesEnded([SubmitButtonSelectPress()], with: nil)
        XCTAssertEqual(target.count, 1)
    }

    func makeSUT(_ title: String = "Submit") throws -> (SubmitButton, UIActivityIndicatorView) {
        let sut = SubmitButton(style: style)
        sut.title = title
        let activityIndicatorView: UIActivityIndicatorView = try XCTUnwrap(sut.findView(by: "activityIndicator"))

        return (sut, activityIndicatorView)
    }
}

private final class SubmitButtonActionTarget: NSObject {
    var count = 0

    @objc func submit() {
        count += 1
    }
}

private final class SubmitButtonSelectPress: UIPress {
    override var type: UIPress.PressType {
        .select
    }
}
