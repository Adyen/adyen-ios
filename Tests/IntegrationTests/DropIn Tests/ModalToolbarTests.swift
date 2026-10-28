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

    func testAllCloseButtonStylesAreLabeled() {
        for buttonStyle in [CancelButtonStyle.system, .legacy, .custom(UIImage())] {
            var style = NavigationStyle()
            style.cancelButton = buttonStyle
            let toolbar = ModalToolbar(title: "Credit Card", style: style)
            let label = toolbar.cancelButton.accessibilityLabel ?? toolbar.cancelButton.title(for: .normal)
            XCTAssertFalse(label?.isEmpty ?? true)

            var cancelled = false
            toolbar.onCancelHandler = { cancelled = true }
            toolbar.cancelButton.sendActions(for: .touchUpInside)
            XCTAssertTrue(cancelled)
        }
    }

    func testLegacyCancelButtonKeepsItsDefaultFontSize() {
        var style = NavigationStyle()
        style.cancelButton = .legacy
        let toolbar = ModalToolbar(title: "Credit Card", style: style)
        let (parent, child) = host(toolbar)
        parent.setOverrideTraitCollection(UITraitCollection(preferredContentSizeCategory: .large), forChild: child)
        child.view.layoutIfNeeded()

        let defaultFontSize = UIButton(type: .system).titleLabel?.font.pointSize ?? 0
        XCTAssertEqual(toolbar.cancelButton.titleLabel?.font.pointSize ?? 0, defaultFontSize, accuracy: 0.1)
        XCTAssertTrue(toolbar.cancelButton.titleLabel?.adjustsFontForContentSizeCategory == true)
    }

    func testTitleKeepsSingleLineAtDefaultTextSize() {
        let toolbar = ModalToolbar(title: "Credit Card", style: NavigationStyle())
        let (parent, child) = host(toolbar)
        parent.setOverrideTraitCollection(UITraitCollection(preferredContentSizeCategory: .large), forChild: child)
        child.view.layoutIfNeeded()

        XCTAssertTrue(toolbar.titleLabel.accessibilityTraits.contains(.header))
        XCTAssertEqual(toolbar.titleLabel.numberOfLines, 1)
        XCTAssertLessThanOrEqual(fittingHeight(of: toolbar), Constants.navigationBarHeight)
    }

    func testTitleWrapsAndHeaderGrowsAtAccessibilityTextSizes() {
        for alignment in [NSTextAlignment.natural, .center] {
            var style = NavigationStyle()
            style.barTitle.textAlignment = alignment
            let toolbar = ModalToolbar(title: "Credit Card", style: style)
            let (parent, child) = host(toolbar)
            let initialFontSize = toolbar.titleLabel.font.pointSize

            parent.setOverrideTraitCollection(
                UITraitCollection(preferredContentSizeCategory: .accessibilityExtraExtraExtraLarge),
                forChild: child
            )
            wait(
                until: { toolbar.titleLabel.font.pointSize > initialFontSize && toolbar.titleLabel.numberOfLines == 0 },
                timeout: Constants.traitChangeTimeout,
                retryInterval: Constants.traitChangeRetryInterval
            )

            XCTAssertGreaterThan(fittingHeight(of: toolbar), Constants.navigationBarHeight)
        }
    }

    func testCenteredTitleAndCloseButtonDoNotOverlapAtAccessibilityTextSizes() {
        var style = NavigationStyle()
        style.barTitle.textAlignment = .center
        style.cancelButton = .legacy
        style.toolbarMode = .rightCancel
        let toolbar = ModalToolbar(title: "Credit Card", style: style)
        let (parent, child) = host(toolbar)
        let initialFontSize = toolbar.titleLabel.font.pointSize

        parent.setOverrideTraitCollection(UITraitCollection(preferredContentSizeCategory: .accessibilityExtraExtraExtraLarge), forChild: child)
        wait(
            until: { toolbar.titleLabel.font.pointSize > initialFontSize },
            timeout: Constants.traitChangeTimeout,
            retryInterval: Constants.traitChangeRetryInterval
        )
        toolbar.frame = CGRect(
            origin: .zero,
            size: CGSize(width: Constants.compactWidth, height: max(Constants.navigationBarHeight, fittingHeight(of: toolbar)))
        )
        toolbar.setNeedsLayout()
        toolbar.layoutIfNeeded()

        XCTAssertFalse(toolbar.titleLabel.frame.intersects(toolbar.cancelButton.frame))
        XCTAssertGreaterThan(toolbar.frame.height, Constants.navigationBarHeight)
    }

    private func host(_ toolbar: ModalToolbar) -> (parent: UIViewController, child: UIViewController) {
        let child = UIViewController()
        child.view.addSubview(toolbar)
        let parent = UIViewController()
        parent.addChild(child)
        parent.view.addSubview(child.view)
        child.didMove(toParent: parent)
        setupRootViewController(parent)
        return (parent, child)
    }

    private func fittingHeight(of toolbar: ModalToolbar) -> CGFloat {
        let size = toolbar.systemLayoutSizeFitting(
            CGSize(width: Constants.compactWidth, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        return size.height - toolbar.safeAreaInsets.top - toolbar.safeAreaInsets.bottom
    }
}
