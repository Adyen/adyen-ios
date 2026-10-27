//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable @_spi(AdyenInternal) import AdyenCard
@testable import AdyenDropIn
import XCTest

class ModalToolbarTests: XCTestCase {
    private enum Constants {
        static let compactWidth: CGFloat = 320
        static let accessibilityFontSize: CGFloat = 64
        static let navigationBarHeight: CGFloat = 63
        static let traitChangeTimeout: TimeInterval = 2
        static let traitChangeRetryInterval: DispatchTimeInterval = .milliseconds(10)
    }

    var sut: ModalToolbar!

    override func tearDown() {
        sut = nil
    }

    func testDefaultStyle() {
        let style = NavigationStyle()
        sut = ModalToolbar(title: "SomeTitle", style: style)

        if !ProcessInfo().isOperatingSystemAtLeast(OperatingSystemVersion(majorVersion: 13, minorVersion: 0, patchVersion: 0)) {
            XCTAssertEqual(self.sut.cancelButton.tintColor.cgColor, UIColor.Adyen.defaultBlue.cgColor)
        }
        XCTAssertEqual(self.sut.titleLabel.textColor, UIColor.Adyen.componentLabel)
        XCTAssertEqual(self.sut.titleLabel.font, UIFont.AdyenCore.barTitle)
        XCTAssertEqual(self.sut.titleLabel.textAlignment, .natural)
        if !ProcessInfo().isOperatingSystemAtLeast(OperatingSystemVersion(majorVersion: 13, minorVersion: 0, patchVersion: 0)) {
            XCTAssertEqual(self.sut.tintColor.cgColor, UIColor.Adyen.defaultBlue.cgColor)
        }
        XCTAssertEqual(self.sut.backgroundColor, UIColor.Adyen.componentBackground)
    }

    func testCustomStyle() {
        var style = NavigationStyle()
        style.tintColor = .white
        style.backgroundColor = .brown
        style.separatorColor = .red
        style.barTitle = .init(font: .italicSystemFont(ofSize: 17), color: .yellow, textAlignment: .center)

        sut = ModalToolbar(title: "SomeTitle", style: style)

        XCTAssertEqual(self.sut.cancelButton.tintColor, .white)
        XCTAssertEqual(self.sut.titleLabel.textColor, .yellow)
        XCTAssertEqual(self.sut.titleLabel.font, .italicSystemFont(ofSize: 17))
        XCTAssertEqual(self.sut.titleLabel.textAlignment, .center)
        XCTAssertEqual(self.sut.backgroundColor, .brown)

    }

    func testLeftCenteredMode() {
        var style = NavigationStyle()
        style.barTitle.textAlignment = .center
        style.toolbarMode = .leftCancel

        sut = ModalToolbar(title: "SomeTitle", style: style)

        let cancelConstraint = sut.constraints.first { $0.secondAnchor == sut.cancelButton.leftAnchor }
        XCTAssertEqual(cancelConstraint?.firstAnchor, sut.safeAreaLayoutGuide.leftAnchor)
        XCTAssertNil(sut.constraints.first { $0.secondAnchor == sut.cancelButton.rightAnchor && $0.relation == .equal })
        XCTAssertNotNil(sut.constraints.first {
            $0.firstAnchor == sut.safeAreaLayoutGuide.centerYAnchor && $0.secondAnchor == sut.cancelButton.centerYAnchor
        })
    }

    func testRightCenteredMode() {
        var style = NavigationStyle()
        style.barTitle.textAlignment = .center
        style.toolbarMode = .rightCancel

        sut = ModalToolbar(title: "SomeTitle", style: style)

        XCTAssertNil(sut.constraints.first { $0.secondAnchor == sut.cancelButton.leftAnchor && $0.relation == .equal })
        let cancelConstraint = sut.constraints.first { $0.secondAnchor == sut.cancelButton.rightAnchor }
        XCTAssertEqual(cancelConstraint?.firstAnchor, sut.safeAreaLayoutGuide.rightAnchor)
        XCTAssertNotNil(sut.constraints.first {
            $0.firstAnchor == sut.safeAreaLayoutGuide.centerYAnchor && $0.secondAnchor == sut.cancelButton.centerYAnchor
        })
    }

    func testLeftMode() {
        var style = NavigationStyle()
        style.barTitle.textAlignment = .natural
        style.toolbarMode = .leftCancel

        sut = ModalToolbar(title: "SomeTitle", style: style)

        XCTAssertEqual(sut.stackView.arrangedSubviews.last, sut.cancelButton)
    }

    func testDefaultLayoutUsesSafeArea() {
        sut = ModalToolbar(title: "SomeTitle", style: NavigationStyle())

        XCTAssertNotNil(sut.constraints.first {
            $0.firstAnchor == sut.stackView.topAnchor && $0.secondAnchor == sut.safeAreaLayoutGuide.topAnchor
        })
        XCTAssertNotNil(sut.constraints.first {
            $0.firstAnchor == sut.stackView.leadingAnchor && $0.secondAnchor == sut.safeAreaLayoutGuide.leadingAnchor
        })
        XCTAssertNotNil(sut.constraints.first {
            $0.firstAnchor == sut.safeAreaLayoutGuide.bottomAnchor && $0.secondAnchor == sut.stackView.bottomAnchor
        })
        XCTAssertNotNil(sut.constraints.first {
            $0.firstAnchor == sut.safeAreaLayoutGuide.trailingAnchor && $0.secondAnchor == sut.stackView.trailingAnchor
        })
    }

    func testLegacyButtonStyle() {
        var style = NavigationStyle()
        style.cancelButton = .legacy

        sut = ModalToolbar(title: "SomeTitle", style: style)

        XCTAssertEqual(sut.cancelButton.title(for: .normal), "Cancel")
        XCTAssertNil(sut.cancelButton.image(for: .normal))
    }

    func testSystemButtonStyle() {
        var style = NavigationStyle()
        style.cancelButton = .system

        sut = ModalToolbar(title: "SomeTitle", style: style)

        XCTAssertNotEqual(sut.cancelButton.title(for: .normal), "Cancel")
        XCTAssertNotNil(sut.cancelButton.image(for: .normal))
        
        XCTAssertNotEqual(sut.cancelButton.image(for: .normal), UIImage(systemName: "cart"))
    }

    func testCustomButtonStyle() throws {
        var style = NavigationStyle()
        
        let customImage = try XCTUnwrap(UIImage(systemName: "cart"))
        style.cancelButton = .custom(customImage)

        sut = ModalToolbar(title: "SomeTitle", style: style)

        XCTAssertNotEqual(sut.cancelButton.title(for: .normal), "Cancel")
        XCTAssertEqual(sut.cancelButton.image(for: .normal), customImage)
    }

    func testAllCloseButtonStylesAreLabeledAndFocusable() {
        for buttonStyle in [CancelButtonStyle.system, .legacy, .custom(UIImage())] {
            var style = NavigationStyle()
            style.cancelButton = buttonStyle
            let toolbar = ModalToolbar(title: "Credit Card", style: style)
            XCTAssertTrue(toolbar.cancelButton.canBecomeFocused)
            let label = toolbar.cancelButton.accessibilityLabel ?? toolbar.cancelButton.title(for: .normal)
            XCTAssertFalse(label?.isEmpty ?? true)

            var cancelled = false
            toolbar.onCancelHandler = { cancelled = true }
            toolbar.cancelButton.sendActions(for: .touchUpInside)
            XCTAssertTrue(cancelled)
            toolbar.cancelButton.isEnabled = false
            XCTAssertFalse(toolbar.cancelButton.canBecomeFocused)
        }
    }

    func testTitleIsADynamicTypeHeadingAndHeaderCanGrow() {
        let toolbar = ModalToolbar(title: "Credit Card", style: NavigationStyle())
        toolbar.bounds.size.width = Constants.compactWidth
        XCTAssertTrue(toolbar.titleLabel.accessibilityTraits.contains(.header))
        XCTAssertTrue(toolbar.titleLabel.adjustsFontForContentSizeCategory)
        toolbar.titleLabel.font = .systemFont(ofSize: Constants.accessibilityFontSize)

        XCTAssertGreaterThan(toolbar.intrinsicContentSize.height, Constants.navigationBarHeight)
    }

    func testCenteredTitleAndCloseButtonDoNotOverlapAtAccessibilityTextSizes() {
        var style = NavigationStyle()
        style.barTitle.textAlignment = .center
        style.cancelButton = .legacy
        style.toolbarMode = .rightCancel
        let toolbar = ModalToolbar(title: "Credit Card", style: style)
        let child = UIViewController()
        child.view.addSubview(toolbar)
        let parent = UIViewController()
        parent.addChild(child)
        parent.view.addSubview(child.view)
        child.didMove(toParent: parent)
        setupRootViewController(parent)
        let initialFontSize = toolbar.titleLabel.font.pointSize

        parent.setOverrideTraitCollection(UITraitCollection(preferredContentSizeCategory: .accessibilityExtraExtraExtraLarge), forChild: child)
        wait(
            until: { toolbar.titleLabel.font.pointSize > initialFontSize },
            timeout: Constants.traitChangeTimeout,
            retryInterval: Constants.traitChangeRetryInterval
        )
        toolbar.bounds.size.width = Constants.compactWidth
        toolbar.frame = CGRect(
            origin: .zero,
            size: CGSize(width: Constants.compactWidth, height: max(Constants.navigationBarHeight, toolbar.intrinsicContentSize.height))
        )
        toolbar.setNeedsLayout()
        toolbar.layoutIfNeeded()

        XCTAssertFalse(toolbar.titleLabel.frame.intersects(toolbar.cancelButton.frame))
        XCTAssertGreaterThan(toolbar.frame.height, Constants.navigationBarHeight)
    }
}
