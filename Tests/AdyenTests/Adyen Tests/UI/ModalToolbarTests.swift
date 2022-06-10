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

        XCTAssertNotNil(sut.constraints.first { $0.secondAnchor == sut.cancelButton.leftAnchor })
        XCTAssertNil(sut.constraints.first { $0.secondAnchor == sut.cancelButton.rightAnchor })
    }

    func testRightCenteredMode() {
        var style = NavigationStyle()
        style.barTitle.textAlignment = .center
        style.toolbarMode = .rightCancel

        sut = ModalToolbar(title: "SomeTitle", style: style)

        XCTAssertNil(sut.constraints.first { $0.secondAnchor == sut.cancelButton.leftAnchor })
        XCTAssertNotNil(sut.constraints.first { $0.secondAnchor == sut.cancelButton.rightAnchor })
    }

    func testLeftMode() {
        var style = NavigationStyle()
        style.barTitle.textAlignment = .natural
        style.toolbarMode = .leftCancel

        sut = ModalToolbar(title: "SomeTitle", style: style)

        XCTAssertEqual(sut.stackView.arrangedSubviews.last, sut.cancelButton)
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

        if #available(iOS 13.0, *) {
            XCTAssertNotEqual(sut.cancelButton.title(for: .normal), "Cancel")
            XCTAssertNotNil(sut.cancelButton.image(for: .normal))
        } else {
            XCTAssertEqual(sut.cancelButton.title(for: .normal), "Cancel")
            XCTAssertNil(sut.cancelButton.image(for: .normal))
        }
        XCTAssertNotEqual(sut.cancelButton.image(for: .normal), UIImage(named: "shopping-cart"))
    }

    func testCustomButtonStyle() {
        var style = NavigationStyle()
        style.cancelButton = .custom(UIImage(named: "shopping-cart")!)

        sut = ModalToolbar(title: "SomeTitle", style: style)

        XCTAssertNotEqual(sut.cancelButton.title(for: .normal), "Cancel")
        XCTAssertEqual(sut.cancelButton.image(for: .normal), UIImage(named: "shopping-cart"))
    }

}
