//
//  UIViewHelpersTests.swift
//  AdyenUIKitTests
//
//  Created by Mohamed Eldoheiri on 4/9/21.
//  Copyright © 2021 Adyen. All rights reserved.
//

import XCTest
@testable import Adyen

class UIViewHelpersTests: XCTestCase {

    func testViewTreeSearch1() throws {
        let rootView = UIScrollView()
        rootView.accessibilityIdentifier = "rootView"
        XCTAssertEqual((rootView.adyen.getTopMostView() as? UIScrollView)?.accessibilityIdentifier, "rootView")
    }

    func testViewTreeSearch2() throws {
        let rootView = UIView()
        rootView.accessibilityIdentifier = "rootView"

        let level11 = UIButton()
        level11.accessibilityIdentifier = "level11"
        rootView.addSubview(level11)

        let level12 = UIButton()
        level12.accessibilityIdentifier = "level12"
        rootView.addSubview(level12)

        let level22 = UIButton()
        level22.accessibilityIdentifier = "level22"
        level12.addSubview(level22)

        let foundView: UIButton? = rootView.adyen.getTopMostView()
        XCTAssertEqual(foundView?.accessibilityIdentifier, "level11")
    }

    func testViewTreeSearch3() throws {
        let rootView = UIView()
        rootView.accessibilityIdentifier = "rootView"

        let level11 = UIButton()
        level11.accessibilityIdentifier = "level11"
        rootView.addSubview(level11)

        let level12 = UIButton()
        level12.accessibilityIdentifier = "level12"
        rootView.addSubview(level12)

        let level21 = UIButton()
        level21.accessibilityIdentifier = "level21"
        level11.addSubview(level21)

        let foundView: UIButton? = rootView.adyen.getTopMostView()
        XCTAssertEqual(foundView?.accessibilityIdentifier, "level11")
    }

    func testViewTreeSearch4() throws {
        let rootView = UIView()
        rootView.accessibilityIdentifier = "rootView"

        let level11 = UIView()
        level11.accessibilityIdentifier = "level11"
        rootView.addSubview(level11)

        let level12 = UIButton()
        level12.accessibilityIdentifier = "level12"
        rootView.addSubview(level12)

        let level21 = UIButton()
        level21.accessibilityIdentifier = "level21"
        level11.addSubview(level21)

        let foundView: UIButton? = rootView.adyen.getTopMostView()
        XCTAssertEqual(foundView?.accessibilityIdentifier, "level12")
    }

    func testViewTreeSearch5() throws {
        let rootView = UIView()
        rootView.accessibilityIdentifier = "rootView"

        let level11 = UIView()
        level11.accessibilityIdentifier = "level11"
        rootView.addSubview(level11)

        let level12 = UIView()
        level12.accessibilityIdentifier = "level12"
        rootView.addSubview(level12)

        let level21 = UIButton()
        level21.accessibilityIdentifier = "level21"
        level11.addSubview(level21)

        let foundView: UIButton? = rootView.adyen.getTopMostView()
        XCTAssertEqual(foundView?.accessibilityIdentifier, "level21")
    }

    func testViewTreeSearch6() throws {
        let rootView = UIView()
        rootView.accessibilityIdentifier = "rootView"

        let level11 = UIView()
        level11.accessibilityIdentifier = "level11"
        rootView.addSubview(level11)

        let level12 = UIView()
        level12.accessibilityIdentifier = "level12"
        rootView.addSubview(level12)

        let level13 = UIView()
        level13.accessibilityIdentifier = "level13"
        rootView.addSubview(level13)

        let level23 = UIButton()
        level23.accessibilityIdentifier = "level23"
        level13.addSubview(level23)

        let foundView: UIButton? = rootView.adyen.getTopMostView()
        XCTAssertEqual(foundView?.accessibilityIdentifier, "level23")
    }

}
