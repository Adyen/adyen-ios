//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents
import XCTest

class PayToComponentTests: XCTestCase {

    func test_init() throws {
        let sut = try PayToComponent(
            paymentMethod: AdyenCoder.decode(payto),
            context: Dummy.context
        )

        XCTAssertNotNil(sut)
    }

    func test_paymentMethodType_isPayto() throws {
        let sut = try PayToComponent(
            paymentMethod: AdyenCoder.decode(payto),
            context: Dummy.context
        )

        XCTAssertEqual(sut.paymentMethod.type, .payto)
    }

    func test_flowSelection_titleLabel_exists() throws {
        // Given
        let sut = try PayToComponent(
            paymentMethod: AdyenCoder.decode(payto),
            context: Dummy.context
        )

        setupRootViewController(sut.viewController)

        // Check by accessibility identifier
        let flowSelectionTitleLabelItem = sut.viewController.view.findView(with: "AdyenComponents.PayToComponent.flowSelectionTitleLabel") as? UILabel

        // Then
        XCTAssertNotNil(flowSelectionTitleLabelItem, "Flow selection title label should exist")
    }

    func test_flowSelectionItem_exists() throws {
        // Given
        let sut = try PayToComponent(
            paymentMethod: AdyenCoder.decode(payto),
            context: Dummy.context
        )

        setupRootViewController(sut.viewController)

        // Check by accessibility identifier
        let flowSelectionItem = sut.viewController.view.findView(with: "AdyenComponents.PayToComponent.flowSelectionSegmentedControl") as? UISegmentedControl
        flowSelectionItem?.selectedSegmentIndex = 1

        // Then
        XCTAssertNotNil(flowSelectionItem, "Flow selection item should exist")
    }

    func test_continueButton_exists() throws {
        // Given
        let sut = try PayToComponent(
            paymentMethod: AdyenCoder.decode(payto),
            context: Dummy.context
        )

        setupRootViewController(sut.viewController)

        // Check by accessibility identifier
        let continueButton: FormButtonItemView = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.PayToComponent.continueButton"))

        // Then
        XCTAssertNotNil(continueButton, "ContinueButton should exist")
    }

}
