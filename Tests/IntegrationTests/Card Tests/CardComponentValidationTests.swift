//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest
@testable @_spi(AdyenInternal) import AdyenCard
@testable import AdyenDropIn
@testable import AdyenEncryption

class CardComponentValidationTests: XCTestCase {

    var context: AdyenContext {
        Dummy.context
    }

    var method: CardPaymentMethod {
        .init(
            type: .bcmc,
            name: "Test name",
            fundingSource: .credit,
            brands: [.visa, .americanExpress, .masterCard]
        )
    }

    override func run() {
        AdyenDependencyValues.runTestWithValues {
            $0.imageLoader = ImageLoaderMock()
        } perform: {
            super.run()
        }
    }

    // MARK: - UC10: Pay Button Validates All Fields

    /// UC10: GIVEN a form with multiple fields AND some fields have invalid input
    /// WHEN the user taps the Pay button (validation triggered)
    /// THEN ALL invalid fields should show their validation errors simultaneously
    /// AND the form should NOT submit
    func testUC10_PayButton_ValidatesAllFieldsSimultaneously() {
        // Given - form with multiple fields
        var configuration = CardComponentConfiguration()
        configuration.showsHolderNameField = true
        configuration.showsSubmitButton = true

        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: configuration
        )

        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate

        sut.viewController.loadViewIfNeeded()

        let cardViewController = sut.cardViewController
        let items = cardViewController.items

        // Set invalid values in multiple fields
        items.numberContainerItem.numberItem.value = "1234"
        items.expiryDateItem.value = "13/99"
        items.securityCodeItem.value = "12"
        items.holderNameItem.value = ""

        // Verify no errors are shown initially
        XCTAssertFalse(
            items.numberContainerItem.numberItem.validationState.shouldShowError,
            "Card number error should not be shown initially"
        )
        XCTAssertFalse(
            items.expiryDateItem.validationState.shouldShowError,
            "Expiry date error should not be shown initially"
        )
        XCTAssertFalse(
            items.securityCodeItem.validationState.shouldShowError,
            "Security code error should not be shown initially"
        )
        XCTAssertFalse(
            items.holderNameItem.validationState.shouldShowError,
            "Holder name error should not be shown initially"
        )

        // When - Pay button is tapped (triggers validation)
        let isValid = cardViewController.validate()

        // Then - form should NOT be valid
        XCTAssertFalse(isValid, "Form should not be valid with invalid inputs")

        // AND - ALL invalid fields should show their validation errors simultaneously
        XCTAssertTrue(
            items.numberContainerItem.numberItem.validationState.shouldShowError,
            "Card number should show validation error after Pay button tap"
        )
        XCTAssertTrue(
            items.expiryDateItem.validationState.shouldShowError,
            "Expiry date should show validation error after Pay button tap"
        )
        XCTAssertTrue(
            items.securityCodeItem.validationState.shouldShowError,
            "Security code should show validation error after Pay button tap"
        )
        XCTAssertTrue(
            items.holderNameItem.validationState.shouldShowError,
            "Holder name should show validation error after Pay button tap"
        )

        // AND - form should NOT submit
        XCTAssertNil(delegate.onDidSubmit, "Form should not submit with invalid inputs")
    }
}
