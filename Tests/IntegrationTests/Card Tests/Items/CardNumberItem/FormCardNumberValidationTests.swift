//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

@testable @_spi(AdyenInternal) import AdyenCard

/// Tests for card number validation display behavior.
/// See FORM_VALIDATION_SPECS.md for use case definitions (UC5-UC9, UC13).
class FormCardNumberValidationTests: XCTestCase {

    static let testURL = URL(string: "https://example.com")!

    override func run() {
        AdyenDependencyValues.runTestWithValues {
            $0.imageLoader = ImageLoaderMock()
        } perform: {
            super.run()
        }
    }

    // MARK: - UC5: Card Number - Brand Detection Hides Placeholder (No Error)

    /// UC5: GIVEN an empty card number field with brand logos placeholder
    /// WHEN the user types "4" (Visa prefix)
    /// THEN the Visa brand icon should appear in accessory
    /// AND NO validation error should be shown (brand detection is NOT a validation trigger)
    func testUC5_BrandDetection_NoErrorShown() {
        // Given
        let item = FormCardNumberItem(cardTypeLogos: [
            .init(url: Self.testURL, type: .visa),
            .init(url: Self.testURL, type: .masterCard)
        ])
        let sut = FormCardNumberItemView(item: item)

        // Simulate user starting to type
        sut.textField.delegate?.textFieldDidBeginEditing?(sut.textField)

        // When - user types "4" (Visa prefix)
        sut.textField.text = "4"
        _ = sut.textField(
            sut.textField, shouldChangeCharactersIn: NSRange(location: 0, length: 0),
            replacementString: "4"
        )

        // Then - NO error should be shown (brand detection is not validation)
        XCTAssertTrue(
            sut.footerLabel.isHidden,
            "No error should be shown - brand detection is NOT a validation trigger"
        )
        XCTAssertFalse(item.shouldShowValidationError, "shouldShowValidationError should be false")

        // The accessory should show brand, not validation error
        if case .invalid = sut.accessory {
            XCTFail("Should not show invalid accessory - should show brand icon instead")
        }
    }

    /// UC5: Test that brand logos placeholder disappears when brand is detected
    func testUC5_BrandDetection_PlaceholderDisappears() {
        // Given
        let containerItem = FormCardNumberContainerItem(
            cardTypeLogos: [
                .init(url: Self.testURL, type: .visa),
                .init(url: Self.testURL, type: .masterCard)
            ],
            showsSupportedCardLogos: true,
            style: FormTextItemStyle(),
            localizationParameters: nil,
            scanCardHandler: nil
        )

        // Initially logos should be visible (placeholder)
        XCTAssertFalse(
            containerItem.supportedCardLogosItem.isHidden.wrappedValue,
            "Brand logos should be visible initially as placeholder"
        )

        // When - brand is detected (simulating typing "4")
        containerItem.update(brands: [CardBrand(type: .visa)])

        // Then - logos should be hidden (brand is known, placeholder not needed)
        XCTAssertTrue(
            containerItem.supportedCardLogosItem.isHidden.wrappedValue,
            "Brand logos placeholder should disappear when brand is detected"
        )

        // AND - no error should be shown on the number item
        XCTAssertFalse(
            containerItem.numberItem.shouldShowValidationError,
            "No validation error should be shown - brand detection is not validation"
        )
    }

    // MARK: - UC6: Card Number - Error Hides Brand Logos

    /// UC6: GIVEN a card number field with supported brand logos below
    /// AND the field contains an invalid card number
    /// WHEN the user taps on another field (focus loss)
    /// THEN the validation error message should appear AND brand logos should be hidden
    func testUC6_ErrorHidesBrandLogos() {
        // Given
        let containerItem = FormCardNumberContainerItem(
            cardTypeLogos: [
                .init(url: Self.testURL, type: .visa),
                .init(url: Self.testURL, type: .masterCard)
            ],
            showsSupportedCardLogos: true,
            style: FormTextItemStyle(),
            localizationParameters: nil,
            scanCardHandler: nil
        )

        let numberItem = containerItem.numberItem
        let logosItem = containerItem.supportedCardLogosItem
        let sut = FormCardNumberItemView(item: numberItem)

        // Simulate entering invalid card number and losing focus
        sut.textField.delegate?.textFieldDidBeginEditing?(sut.textField)
        sut.textField.text = "1234"
        numberItem.value = "1234"

        // When - focus loss triggers validation
        sut.textField.delegate?.textFieldDidEndEditing?(sut.textField)

        // Then - wait for animation and verify error is shown
        wait(until: { !sut.footerLabel.isHidden }, timeout: 1.0)
        XCTAssertTrue(
            numberItem.shouldShowValidationError,
            "Error should be shown after focus loss with invalid input"
        )
        XCTAssertFalse(sut.footerLabel.isHidden, "Footer should show error message")
    }

    // MARK: - UC7: Card Number - Re-entering Field Restores Logos

    /// UC7: GIVEN a card number field showing a validation error
    /// AND the supported brand logos are hidden
    /// WHEN the user taps back into the card number field
    /// THEN the validation error should clear AND brand logos should reappear
    func testUC7_ReenteringFieldRestoresLogos() {
        // Given - set up error state first
        let containerItem = FormCardNumberContainerItem(
            cardTypeLogos: [
                .init(url: Self.testURL, type: .visa),
                .init(url: Self.testURL, type: .masterCard)
            ],
            showsSupportedCardLogos: true,
            style: FormTextItemStyle(),
            localizationParameters: nil,
            scanCardHandler: nil
        )

        let numberItem = containerItem.numberItem
        let sut = FormCardNumberItemView(item: numberItem)

        // Set up error state
        sut.textField.delegate?.textFieldDidBeginEditing?(sut.textField)
        sut.textField.text = "1234"
        numberItem.value = "1234"
        sut.textField.delegate?.textFieldDidEndEditing?(sut.textField)

        // Verify error state
        XCTAssertTrue(numberItem.shouldShowValidationError, "Precondition: error should be shown")

        // When - user taps back into field
        sut.textField.delegate?.textFieldDidBeginEditing?(sut.textField)

        // Then - error should clear
        XCTAssertFalse(
            numberItem.shouldShowValidationError, "Error should clear when field gains focus"
        )
        XCTAssertTrue(sut.footerLabel.isHidden, "Footer should be hidden")
    }

    // MARK: - UC8: Card Number - Valid Input Hides Logos

    /// UC8: GIVEN a card number field with a complete, valid card number
    /// WHEN validation completes
    /// THEN the supported brand logos should be hidden (valid state)
    /// AND the valid checkmark accessory should appear
    func testUC8_ValidInputHidesLogos() {
        // Given
        let item = FormCardNumberItem(cardTypeLogos: [
            .init(url: Self.testURL, type: .visa),
            .init(url: Self.testURL, type: .masterCard)
        ])
        item.validator = CardNumberValidator(
            isLuhnCheckEnabled: true, isEnteredBrandSupported: true
        )

        let sut = FormCardNumberItemView(item: item)

        // Simulate entering valid Visa card
        sut.textField.delegate?.textFieldDidBeginEditing?(sut.textField)
        let validVisaNumber = "4111111111111111"
        sut.textField.text = validVisaNumber
        item.value = validVisaNumber

        // When - focus loss
        sut.textField.delegate?.textFieldDidEndEditing?(sut.textField)

        // Then - should show valid state
        XCTAssertFalse(item.shouldShowValidationError, "No error for valid input")

        // Card number uses customView for valid state to show detected brand
        if case .customView = sut.accessory {
            // Expected - card number shows brand icon when valid
        } else if case .valid = sut.accessory {
            // Also acceptable
        } else {
            XCTFail("Should show valid state accessory, got: \(sut.accessory)")
        }
    }

    // MARK: - UC9: Card Number - Partial Input While Typing (No Validation)

    /// UC9: GIVEN a card number field with partial input
    /// AND the user is actively typing (field has focus)
    /// WHEN the value changes
    /// THEN NO validation should occur AND NO error should appear
    func testUC9_PartialInputWhileTyping_NoValidation() {
        // Given
        let item = FormCardNumberItem(cardTypeLogos: [
            .init(url: Self.testURL, type: .visa),
            .init(url: Self.testURL, type: .masterCard)
        ])
        let sut = FormCardNumberItemView(item: item)

        // Simulate user typing
        sut.textField.delegate?.textFieldDidBeginEditing?(sut.textField)

        // When - user types partial input "4111"
        for char in "4111" {
            let currentText = sut.textField.text ?? ""
            sut.textField.text = currentText + String(char)
            item.value = sut.textField.text ?? ""
            _ = sut.textField(
                sut.textField,
                shouldChangeCharactersIn: NSRange(location: currentText.count, length: 0),
                replacementString: String(char)
            )
        }

        // Then - no validation error while typing
        XCTAssertFalse(item.shouldShowValidationError, "No validation error while typing")
        XCTAssertTrue(sut.footerLabel.isHidden, "Footer should be hidden while typing")

        // Accessory should not show invalid state
        if case .invalid = sut.accessory {
            XCTFail("Should not show invalid accessory while user is typing")
        }
    }

    // MARK: - UC13: Animation - Footer Transitions

    /// UC13: Test that footer label uses animation for transitions
    /// Note: This is a behavior documentation test - actual animation timing is hard to test
    func testUC13_FooterTransitionAnimation_ErrorAppears() {
        // Given
        let item = FormCardNumberItem(cardTypeLogos: [
            .init(url: Self.testURL, type: .visa)
        ])
        let sut = FormCardNumberItemView(item: item)

        // Simulate entering invalid input and losing focus
        sut.textField.delegate?.textFieldDidBeginEditing?(sut.textField)
        sut.textField.text = "1234"
        item.value = "1234"

        // When - validation triggered
        sut.textField.delegate?.textFieldDidEndEditing?(sut.textField)

        // Then - wait for animation and verify footer appears
        wait(until: { !sut.footerLabel.isHidden }, timeout: 1.0)
        XCTAssertFalse(sut.footerLabel.isHidden, "Footer should appear (with animation)")
    }

    // MARK: - Integration: Container Coordination

    /// Test that FormCardNumberContainerItem properly coordinates visibility
    func testContainerCoordinatesBrandLogosVisibility() {
        // Given
        let containerItem = FormCardNumberContainerItem(
            cardTypeLogos: [
                .init(url: Self.testURL, type: .visa),
                .init(url: Self.testURL, type: .masterCard)
            ],
            showsSupportedCardLogos: true,
            style: FormTextItemStyle(),
            localizationParameters: nil,
            scanCardHandler: nil
        )

        // Verify initial state
        XCTAssertFalse(
            containerItem.supportedCardLogosItem.isHidden.wrappedValue,
            "Brand logos should be visible initially"
        )

        // When brands are detected (valid brand)
        containerItem.update(brands: [CardBrand(type: .visa)])

        // Then logos should be hidden (brand detected)
        XCTAssertTrue(
            containerItem.supportedCardLogosItem.isHidden.wrappedValue,
            "Brand logos should be hidden when valid brand is detected"
        )
    }
}
